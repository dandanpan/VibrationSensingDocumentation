/*
 * Tag:
 * provides ground truth for the localization system
 */

#include <SPI.h>
#include <DW1000.h>
#include <Wire.h>
#include "Footstep.h"
#define DEVICE_ID       11
#define CLEAR_STEP      true
#define NOT_CLEAR_STEP  false 
#define CLOCK_RATE      48000000
#define SAMPLE_RATE     50
#define BUFFER_SIZE     4
uint8_t dataToRead;
int numStep = 1;
int totalStepCount = 0;
int pressureBuffer[BUFFER_SIZE];

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
volatile int sampleCounter = 0;
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
volatile unsigned long stepTimestamp = 0;
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
    
/*
void ADC_Handler() {
  if (ADC->INTFLAG.reg & 0x01) { // RESRDY interrupt
    uint16_t value = ADC->RESULT.reg;
    readData(value);
  }
}

static __inline__ void ADCsync() __attribute__((always_inline, unused));
static void   ADCsync() {
  while (ADC->STATUS.bit.SYNCBUSY == 1); //Just wait till the ADC is free
}

void adc_init() {
  analogRead(ADCPIN);  // do some pin init  pinPeripheral()
  ADC->CTRLA.bit.ENABLE = 0x00;             // Disable ADC
  ADCsync();
  ADC->INTENSET.reg = 0x01; // enable RESRDY interrupt
  ADC->INPUTCTRL.bit.GAIN = ADC_INPUTCTRL_GAIN_DIV2_Val;  // default
  ADC->REFCTRL.bit.REFSEL = ADC_REFCTRL_REFSEL_INTVCC1_Val;
  ADCsync();    //  ref 31.6.16
  ADC->INPUTCTRL.bit.MUXPOS = g_APinDescription[ADCPIN].ulADCChannelNumber;
  ADCsync();
  ADC->AVGCTRL.reg = 0x00 ;       //no averaging
  ADC->SAMPCTRL.reg = 0x3F;
  //  ADC->SAMPCTRL.reg = 0x00;  ; //sample length in 1/2 CLK_ADC cycles
  ADCsync();
  ADC->CTRLB.reg = ADC_CTRLB_PRESCALER_DIV512 | ADC_CTRLB_FREERUN | ADC_CTRLB_RESSEL_10BIT;//ADC_CTRLB_PRESCALER_DIV256
  ADCsync();
  ADC->CTRLA.bit.ENABLE = 0x01;
  ADCsync();
  NVIC_EnableIRQ( ADC_IRQn ) ;
  NVIC_SetPriority( ADC_IRQn, 0 );
}

void readData(uint16_t vibData) {
  sampleCounter += 1;
  if (sampleCounter == 250){
    magnitude = vibData + 50;
    SerialUSB.println(magnitude);
    if (bufferIdx == 0){
        bufferStartTimestamp = (micros() - localTimestamp) + referenceTimestamp;
    }
    bufferStopTimestamp = (micros() - localTimestamp) + referenceTimestamp;
    accBuffer[bufferIdx] = magnitude & 0xFF;
    bufferIdx += 1;
    accBuffer[bufferIdx] = (magnitude >> 8) & 0xFF;
    bufferIdx += 1;
    if (bufferIdx >= LEN_ACC_DATA) {
      bufferIdx = 0;
      bufferLooping = true;
    }
    sampleCounter = 0;
  }
}
*/

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
//    adc_init();
    lastSample = millis();

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
//    SerialUSB.println("send ack");
    DW1000.newTransmit();
    DW1000.setDefaults();
    data[0] = TOKEN_RELEASE;
    data[1] = DEVICE_ID;
    data[2] = msgToBase;
    // TODO: add the vibration data here
    copyAccBuffer();
    DW1000.setData(data, LEN_DATA);
    DW1000.startTransmit();
}

void copyAccBuffer(){
//    SerialUSB.println("DEBUG: copy acc to data begin");
    for (int i = 0; i < LEN_ACC_DATA; i++){
        data[3+i] = accBuffer[i];
        accBuffer[i] = 0;
    }
//    SerialUSB.println("DEBUG: copy acc to data end");
}

void clearDataBuffer(){
    for (int i = 3; i < LEN_DATA; i++){
        data[i] = 0;  
    }
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

void loop() {
    if (errorAck){
        errorAck = false;
//        SerialUSB.println("detect error");  
    }

    if (receiveErrorAck){
        receiveErrorAck = false;
//        SerialUSB.println("detect receive error");    
    }
    
    if(!sentAck && !receivedAck) {
        // check if inactive
        if(millis() - lastActivity > resetPeriod) {
//            SerialUSB.println("DEBUG: self time out");
            resetInactive();
        } else { 
            if (currentStatus == TAG_WAIT_FOR_ANCHOR && millis() - lastActivity > resetSingleEvent){
                SerialUSB.print("Anchor died:");SerialUSB.println(msgToAnchor);
                // mark the tag and continue
                anchorError[msgToAnchor-ANCHOR_ID_OFFSET-1] += 1;
                msgToAnchor += 1;
                if (msgToAnchor > ANCHOR_ID_OFFSET+ANCHOR_NUM){
//                    SerialUSB.println("DEBUG: release token");
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
    } else {
        timerCheck = 0;
        selfResetCount = 0;
        // continue on any success confirmation
        if(sentAck) {
            sentAck = false;
            msgId = data[0];
//            SerialUSB.print("DEBUG: receive sentAck: ");SerialUSB.println(msgId);
            if(msgId == POLL) {
                currentStatus = TAG_WAIT_FOR_ANCHOR;
//                SerialUSB.print("DEBUG: current status: ");SerialUSB.println(currentStatus);
                DW1000.getTransmitTimestamp(timePollSent);
                //SerialUSB.print("Sent POLL @ "); SerialUSB.println(timePollSent.getAsFloat());
            } else if(msgId == RANGE) {
                currentStatus = TAG_WAIT_FOR_ANCHOR;
                DW1000.getTransmitTimestamp(timeRangeSent);
            } else if (msgId == TOKEN_RELEASE) {
//                SerialUSB.println("DEBUG: token release sent");
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
//                    SerialUSB.print("ERROR: wrong message: ");SerialUSB.println(msgId);
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
//                        SerialUSB.println("receive token");
                        clearErrorFlag();
                        expectedMsgId = POLL_ACK;
                        currentStatus = TAG_IDLE;
                        transmitPoll();
                    } else if(msgId == POLL_ACK && msgFrom == msgToAnchor) {
//                        SerialUSB.println("DEBUG: receive POLL ACK");
                        DW1000.getReceiveTimestamp(timePollAckReceived);
                        expectedMsgId = RANGE_REPORT;
                        transmitRange();       
                    } else if(msgId == RANGE_REPORT && msgFrom == msgToAnchor) {
//                        SerialUSB.println("DEBUG: receive Range Report");
                        currentStatus = TAG_IDLE;
                        float curRange;
                        memcpy(&curRange, data+CONTROL_SIZE, 4);
                        SerialUSB.print(msgFrom);SerialUSB.print(":");SerialUSB.print(curRange);SerialUSB.print("\n");
                        msgToAnchor += 1;
                        if (msgToAnchor > ANCHOR_ID_OFFSET+ANCHOR_NUM){
//                            SerialUSB.println("DEBUG: release token");
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
//                        SerialUSB.println("DEBUG: receive ranging failed");
                        resetInactive();
                    }
//                    SerialUSB.println("end of processing received");
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
    if (millis() - lastSample >= samplePeriod){
        magnitude = analogRead(A1);
        lastSample = millis();
        for (int i = 0; i < BUFFER_SIZE-1; i++){
            pressureBuffer[i] = pressureBuffer[i+1]; 
        }
        pressureBuffer[BUFFER_SIZE-1] = analogRead(A1);
        if (pressureBuffer[BUFFER_SIZE-1] > pressureBuffer[BUFFER_SIZE-2]  
              && pressureBuffer[BUFFER_SIZE-2] > 1 
              && pressureBuffer[BUFFER_SIZE-3] <= 1 
              && pressureBuffer[BUFFER_SIZE-4] <= 1){
              // detect the impact  
              stepTimestamp = (micros() - localTimestamp) + referenceTimestamp;
              SerialUSB.print("step "); SerialUSB.println(stepTimestamp);
              accBuffer[bufferIdx] = stepTimestamp & 0xFF;
              bufferIdx += 1;
              accBuffer[bufferIdx] = (stepTimestamp >> 8) & 0xFF;
              bufferIdx += 1;
              accBuffer[bufferIdx] = (stepTimestamp >> 16) & 0xFF;
              bufferIdx += 1;
              accBuffer[bufferIdx] = (stepTimestamp >> 24) & 0xFF;
              bufferIdx += 1;
              if (bufferIdx >= LEN_ACC_DATA){
                bufferIdx = 0;
              }
        }
    }
    
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


