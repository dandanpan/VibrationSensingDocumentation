/*
 * Tag: provides ground truth for the localization system
 * Tasks in each cycle (every half second):
 * 1. write data in buffer into the sd card
 * 2. check the radio interrupt see if there is timestamp update
 * Task in the radio interrupt, update baseline timestamp and reference timestamp
 * Task in the data collection interrupt, add data into the buffer
 * Alternative data collection (controlled by delay)
 */

#include <SPI.h>
#include <DW1000.h>
#include <Wire.h> // for accelerometer
#include <SD.h>

#include "Footstep.h"
#define DEVICE_ID       11
#define CLEAR_STEP      true
#define NOT_CLEAR_STEP  false 
#define CLOCK_RATE      48000000
#define SAMPLE_RATE     8

LSM6DS3 myIMU;
uint8_t dataToRead;
int numStep = 1;
int totalStepCount = 0;

// message flow state
volatile byte expectedMsgId = GRANT_TOKEN;
// message sent/received state
volatile boolean sentAck = false;
volatile boolean receivedAck = false;
volatile boolean errorAck = false;
volatile boolean timeoutAck = false;
volatile boolean receiveErrorAck = false;
volatile boolean readDataFlag = false;
volatile boolean alive = false;
volatile byte currentStatus = 0;
volatile byte msgId = 0;
volatile byte msgFrom = 0;
volatile byte msgTo = 0;
volatile byte msgToAnchor = 0;
volatile byte msgToBase = 1;
// data buffer
byte data[LEN_DATA];
volatile byte anchorError[ANCHOR_NUM];
volatile byte accBuffer[LEN_ACC_DATA];
volatile byte bufferIdx = 0;
volatile boolean bufferLooping = false;
// synchronization timestamp
volatile unsigned long referenceTimestamp = 0; // from Basestation
volatile unsigned long localTimestamp = 0; // local time to receive 
volatile unsigned long receiveTime = 0;
volatile unsigned long bufferStartTimestamp = 0;
volatile unsigned long currentStartTimestamp = 0;
volatile unsigned long bufferStopTimestamp = 0;
// timestamps to remember
DW1000Time timePollSent;
DW1000Time timePollAckReceived;
DW1000Time timeRangeSent;
// watchdog and reset period
unsigned long lastActivity;
unsigned long resetPeriod = 10000;
unsigned long resetSingleEvent = 1000;
unsigned long lastSample;
unsigned long deltaSample;
unsigned long samplePeriod = 1000/SAMPLE_RATE;

// reply times (same on both sides for symm. ranging)
unsigned int replyDelayTimeUS = 3000;
int16_t accX = 0;
int16_t accY = 0;
int16_t accZ = 0;
uint16_t magnitude = 0;
boolean fillBuffer = true;
int selfResetCount = 0;
int timerCheck = 0;
char msg[256];
    

void TC3_Handler(){
  TcCount16* TC = (TcCount16*) TC3; // get timer struct
  if (TC->INTFLAG.bit.OVF == 1) {  // A overflow caused the interrupt
    TC->INTFLAG.bit.OVF = 1;    // writing a one clears the flag ovf flag
    readData();
  }
}

void readData() {
    readDataFlag = true;
}

void setupClock(){
    // Enable clock for TC 
    REG_GCLK_CLKCTRL = (uint16_t) (GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID_TCC2_TC3) ;
    while ( GCLK->STATUS.bit.SYNCBUSY == 1 ); // wait for sync 
  
    // The type cast must fit with the selected timer mode 
    TcCount16* TC = (TcCount16*) TC3; // get timer struct
  
    TC->CTRLA.reg &= ~TC_CTRLA_ENABLE;   // Disable TC
    while (TC->STATUS.bit.SYNCBUSY == 1); // wait for sync 
  
    TC->CTRLA.reg |= TC_CTRLA_MODE_COUNT16;  // Set Timer counter Mode to 16 bits
    while (TC->STATUS.bit.SYNCBUSY == 1); // wait for sync 
    TC->CTRLA.reg |= TC_CTRLA_WAVEGEN_NFRQ; // Set TC as normal Normal Frq
    while (TC->STATUS.bit.SYNCBUSY == 1); // wait for sync 
  
    TC->CTRLA.reg |= TC_CTRLA_PRESCALER_DIV256;   // Set perscaler
    while (TC->STATUS.bit.SYNCBUSY == 1); // wait for sync 
    
    // TC->PER.reg = 0xFF;   // Set counter Top using the PER register but the 16/32 bit timer counts allway to max  
    // while (TC->STATUS.bit.SYNCBUSY == 1); // wait for sync 
  
    TC->CC[0].reg = 0xFFF;
    while (TC->STATUS.bit.SYNCBUSY == 1); // wait for sync 
    
    // Interrupts 
    TC->INTENSET.reg = 0;              // disable all interrupts
    TC->INTENSET.bit.OVF = 1;          // enable overfollow
    TC->INTENSET.bit.MC0 = 1;          // enable compare match to CC0
  
    // Enable InterruptVector
    NVIC_EnableIRQ(TC3_IRQn);
  
    // Enable TC
    TC->CTRLA.reg |= TC_CTRLA_ENABLE;
    while (TC->STATUS.bit.SYNCBUSY == 1); // wait for sync 
}

void setup() {
    // DEBUG monitoring
    SerialUSB.begin(115200);
    delay(4000);
    SerialUSB.println("### DW1000-arduino-ranging-tag ###");
    // initialize the driver
    DW1000.begin(IRQ_PIN, RESET_PIN);
    DW1000.select(CS_PIN);
    SerialUSB.println("DW1000 initialized ...");
    // general configuration
    DW1000.newConfiguration();
    DW1000.setDefaults();
    DW1000.setDeviceAddress(DEVICE_ID);
    DW1000.setNetworkId(NETWORK_ID);
    DW1000.enableMode(DW1000.MODE_LONGDATA_FAST_ACCURACY);
    DW1000.commitConfiguration();
    SerialUSB.println("Committed configuration ...");
    // DEBUG chip info and registers pretty printed
    DW1000.getPrintableDeviceIdentifier(msg);
    SerialUSB.print("Device ID: "); SerialUSB.println(msg);
    DW1000.getPrintableExtendedUniqueIdentifier(msg);
    SerialUSB.print("Unique ID: "); SerialUSB.println(msg);
    DW1000.getPrintableNetworkIdAndShortAddress(msg);
    SerialUSB.print("Network ID & Device Address: "); SerialUSB.println(msg);
    DW1000.getPrintableDeviceMode(msg);
    SerialUSB.print("Device mode: "); SerialUSB.println(msg);
    // attach callback for (successfully) sent and received messages
    DW1000.attachSentHandler(handleSent);
    DW1000.attachReceivedHandler(handleReceived);
    DW1000.attachErrorHandler(handleError);
    DW1000.attachReceiveFailedHandler(handleReceiveError);
//    DW1000.attachReceiveTimeoutHandler(handleTimeout);
    // anchor starts by transmitting a POLL message
    receiver();
    msgToAnchor = ANCHOR_ID_OFFSET + 1;
    noteActivity();
    lastSample = millis();
//    setupClock();
}

void noteActivity() {
    // update activity timestamp, so that we do not reach "resetPeriod"
    lastActivity = millis();
}


void clearErrorFlag(){
    for (int anchorID = 0; anchorID < ANCHOR_NUM; anchorID++){
        anchorError[anchorID] = 0;
    }
}

void resetInactive() {
    // tag sends POLL and listens for POLL_ACK
    currentStatus = TAG_IDLE;
    expectedMsgId = GRANT_TOKEN;
    msgToAnchor = ANCHOR_ID_OFFSET + 1;
    clearDataBuffer();
    clearErrorFlag();
    noteActivity();
}

void handleError(){
    errorAck = true;
}

void handleReceiveError(){
    receiveErrorAck = true;
}

void handleTimeout(){
    timeoutAck = true;
}

void handleSent() {
    // status change on sent success
    sentAck = true;
}

void handleReceived() {
    // status change on received success
    receivedAck = true;
    receiveTime = micros();
}

void transmitPoll() {
    DW1000.newTransmit();
    DW1000.setDefaults();
    data[0] = POLL;
    data[1] = DEVICE_ID;
    data[2] = msgToAnchor;
    DW1000.setData(data, LEN_DATA);
    DW1000.startTransmit();
}

void transmitTokenAck() {
    SerialUSB.println("send ack");
    DW1000.newTransmit();
    DW1000.setDefaults();
    data[0] = TOKEN_RELEASE;
    data[1] = DEVICE_ID;
    data[2] = msgToBase;
    // TODO: add the vibration data here
    copyAccBuffer();
    DW1000.setData(data, LEN_DATA);
    DW1000.startTransmit();
    clearAccBuffer();
}

void copyAccBuffer(){
    SerialUSB.println("DEBUG: copy acc to data begin");
    fillBuffer = false;
    if (bufferLooping == true){
      bufferStartTimestamp = bufferStopTimestamp;
    }
    data[3] = bufferStartTimestamp & 0xFF;
    data[4] = (bufferStartTimestamp >> 8) & 0xFF;
    data[5] = (bufferStartTimestamp >> 16) & 0xFF;
    data[6] = (bufferStartTimestamp >> 24) & 0xFF;
    if (bufferLooping == false){
        SerialUSB.print("NOT FULL:");SerialUSB.println(bufferIdx);
        for (int i = 0; i < bufferIdx; i++){
            data[7+i] = accBuffer[i];    
        }  
        for (int i = bufferIdx; i < LEN_ACC_DATA; i++){
            data[7+i] = 0;
        }
    } else {
      
        SerialUSB.println("FULL NOOOOOOOOOO");
        int dataBufferCounter = 7;
        for (int i = bufferIdx; i < LEN_ACC_DATA; i++){
            data[dataBufferCounter] = accBuffer[i];
            dataBufferCounter += 1;  
        }  
        for (int i = 0; i < bufferIdx; i++){
            data[dataBufferCounter] = accBuffer[i];
            dataBufferCounter += 1;
        }
    }
    data[7+LEN_ACC_DATA] = bufferStopTimestamp & 0xFF;
    data[8+LEN_ACC_DATA] = (bufferStopTimestamp >> 8) & 0xFF;
    data[9+LEN_ACC_DATA] = (bufferStopTimestamp >> 16) & 0xFF;
    data[10+LEN_ACC_DATA] = (bufferStopTimestamp >> 24) & 0xFF;
    fillBuffer = true;
    SerialUSB.println("DEBUG: copy acc to data end");
}

void transmitRange() {
    DW1000.newTransmit();
    DW1000.setDefaults();
    data[0] = RANGE;
    data[1] = DEVICE_ID;
    data[2] = msgToAnchor;
    // delay sending the message and remember expected future sent timestamp
    DW1000Time deltaTime = DW1000Time(replyDelayTimeUS, DW_MICROSECONDS);
    timeRangeSent = DW1000.setDelay(deltaTime);
    timePollSent.getTimestamp(data+CONTROL_SIZE);
    timePollAckReceived.getTimestamp(data+CONTROL_SIZE+TSIZE);
    timeRangeSent.getTimestamp(data+CONTROL_SIZE+TSIZE*2);
    DW1000.setData(data, LEN_DATA);
    DW1000.startTransmit();
    //SerialUSB.print("Expect RANGE to be sent @ "); SerialUSB.println(timeRangeSent.getAsFloat());
}

void receiver() {
    DW1000.newReceive();
    DW1000.setDefaults();
    // so we don't need to restart the receiver manually
    DW1000.receivePermanently(true);
    DW1000.startReceive();
}

void clearDataBuffer(){
    for (int i = 3; i < LEN_DATA; i++){
        data[i] = 0;  
    }
}

void clearAccBuffer(){
    bufferLooping = false;
    bufferIdx = 0;
    for (int i = 0; i < LEN_ACC_DATA; i++){
        accBuffer[i] = 0;  
    }
}

void loop() {
    if (errorAck){
        errorAck = false;
//        DW1000.reset();
        SerialUSB.println("detect error");  
    }

    if (receiveErrorAck){
        receiveErrorAck = false;
        SerialUSB.println("detect receive error");    
    }
    
    if(!sentAck && !receivedAck) {
        // check if inactive
        if(millis() - lastActivity > resetPeriod) {
            SerialUSB.println("DEBUG: self time out");
            resetInactive();
        } else { 
            if (currentStatus == TAG_WAIT_FOR_ANCHOR && millis() - lastActivity > resetSingleEvent){
                SerialUSB.print("Anchor died:");SerialUSB.println(msgToAnchor);
                // mark the tag and continue
                anchorError[msgToAnchor-ANCHOR_ID_OFFSET-1] += 1;
                msgToAnchor += 1;
                if (msgToAnchor > ANCHOR_ID_OFFSET+ANCHOR_NUM){
                    SerialUSB.println("DEBUG: release token");
                    currentStatus = TAG_IDLE;
                    transmitTokenAck();
                    msgToAnchor = ANCHOR_ID_OFFSET+1;
                    expectedMsgId = GRANT_TOKEN;
                } else {
                    delay(ANCHOR_INTERVAL);
                    expectedMsgId = POLL_ACK;
                    transmitPoll();
                }  
                noteActivity();
            }
        }
//        for (int anchorID = 0; anchorID < ANCHOR_NUM; anchorID++){
//            if (anchorError[anchorID] > BS_TAG_RESET_COUNT) {
//                resetInactive();
//            }
//        }
    } else {
        timerCheck = 0;
        selfResetCount = 0;
        // continue on any success confirmation
        if(sentAck) {
            sentAck = false;
            msgId = data[0];
            SerialUSB.print("DEBUG: receive sentAck: ");SerialUSB.println(msgId);
            if(msgId == POLL) {
                currentStatus = TAG_WAIT_FOR_ANCHOR;
                SerialUSB.print("DEBUG: current status: ");SerialUSB.println(currentStatus);
                DW1000.getTransmitTimestamp(timePollSent);
                //SerialUSB.print("Sent POLL @ "); SerialUSB.println(timePollSent.getAsFloat());
            } else if(msgId == RANGE) {
                currentStatus = TAG_WAIT_FOR_ANCHOR;
                DW1000.getTransmitTimestamp(timeRangeSent);
            } else if (msgId == TOKEN_RELEASE) {
                SerialUSB.println("DEBUG: token release sent");
                clearDataBuffer();    
            }
            noteActivity();
        }
        if(receivedAck) {
            receivedAck = false;
//            noteActivity();
            // get message and parse
            DW1000.getData(data, LEN_DATA);
            msgId = data[0];
            msgFrom = data[1];
            msgTo = data[2];
//            SerialUSB.print("Msg to: "); SerialUSB.print(msgTo);SerialUSB.print(" from: "); SerialUSB.println(msgFrom);
            if (msgTo == DEVICE_ID){
                if(msgId != expectedMsgId) {
                    // unexpected message, start over again
                    SerialUSB.print("ERROR: wrong message: ");SerialUSB.println(msgId);
                    if (currentStatus == TAG_IDLE){
                        // if current status is ranging, ignore this message
                        resetInactive();
                    } else if (msgId != GRANT_TOKEN) {
                        resetInactive();
                    }
                    
                } else {
                    noteActivity();
                    // if it's expected, proceed    
                    if (msgId == GRANT_TOKEN){
                        SerialUSB.println("receive token");
                        clearErrorFlag();
                        expectedMsgId = POLL_ACK;
                        currentStatus = TAG_IDLE;
                        transmitPoll();
                    } else if(msgId == POLL_ACK && msgFrom == msgToAnchor) {
                        SerialUSB.println("DEBUG: receive POLL ACK");
                        DW1000.getReceiveTimestamp(timePollAckReceived);
                        expectedMsgId = RANGE_REPORT;
                        transmitRange();       
                    } else if(msgId == RANGE_REPORT && msgFrom == msgToAnchor) {
                        SerialUSB.println("DEBUG: receive Range Report");
                        currentStatus = TAG_IDLE;
                        float curRange;
                        memcpy(&curRange, data+CONTROL_SIZE, 4);
                        SerialUSB.print(msgFrom);SerialUSB.print(":");SerialUSB.print(curRange);SerialUSB.print("\n");
                        msgToAnchor += 1;
                        if (msgToAnchor > ANCHOR_ID_OFFSET+ANCHOR_NUM){
                            SerialUSB.println("DEBUG: release token");
                            currentStatus = TAG_IDLE;
                            transmitTokenAck();
                            msgToAnchor = ANCHOR_ID_OFFSET+1;
                            expectedMsgId = GRANT_TOKEN;
                        } else {
                            delay(ANCHOR_INTERVAL);
                            expectedMsgId = POLL_ACK;
                            transmitPoll();
                        }
                        noteActivity();
                    } else if(msgId == RANGE_FAILED) {
                        SerialUSB.println("DEBUG: receive ranging failed");
                        resetInactive();
                    }
                    SerialUSB.println("end of processing received");
                }
                
            } else if (msgTo == 0){
                // broadcast
                if(msgId == RESET_NETWORK) {
                    SerialUSB.println("receive request to reset");
                    // unexpected message, start over again
                    resetInactive();
                } else if (msgId == SYNC_REQ) {
                    syncBSTimestamp(); 
                }
              
            }
        }
    }
    sampleAcc();  
}

void syncBSTimestamp(){
    referenceTimestamp = 0; 
    referenceTimestamp |= data[6];
    referenceTimestamp <<= 8;
    referenceTimestamp |= data[5];
    referenceTimestamp <<= 8;
    referenceTimestamp |= data[4];
    referenceTimestamp <<= 8;
    referenceTimestamp |= data[3];
    localTimestamp = micros();
    referenceTimestamp += localTimestamp - receiveTime;   
}

void sampleAcc(){
    deltaSample = millis() - lastSample; 
    if (deltaSample >= samplePeriod){
        accX = myIMU.readRawAccelX();
        accY = myIMU.readRawAccelY();
        accZ = myIMU.readRawAccelZ();
        magnitude = sqrt(accX*accX+accY*accY+accZ*accZ);
        lastSample = millis();
        if (bufferIdx == 0){
            bufferStartTimestamp = (micros() - localTimestamp) + referenceTimestamp;
        }
        bufferStopTimestamp = (micros() - localTimestamp) + referenceTimestamp;
        
        accBuffer[bufferIdx] = magnitude & 0xFF;
        bufferIdx += 1;
        accBuffer[bufferIdx] = (magnitude >> 8) & 0xFF;
        bufferIdx += 1;
        SerialUSB.println(bufferIdx);
        if (bufferIdx >= LEN_ACC_DATA){
            bufferIdx = 0;
            bufferLooping = true;
            SerialUSB.println("CCCCHHHHAAAANNNNGGGGEEEE");
        }
    }
}


