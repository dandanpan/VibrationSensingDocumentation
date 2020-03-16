/*
 * Base Station:
 * controls the tag to range in a round robin manner
 */

#include <SPI.h>
#include <DW1000.h>
#include "Footstep.h"
#define DEVICE_ID         1
#define DEBUG             1

#define RESET_PIN         9
#define CS_PIN            10
#define IRQ_PIN           2

// message flow state
// volatile byte expectedMsgId = SYNC_ACK;
volatile byte expectedMsgId = POLL_ACK;
volatile byte currentStatus = BS_IDLE;
// message sent/received state
volatile boolean sentAck = false;
volatile boolean receivedAck = false;
volatile byte msgId = 0;
volatile byte msgFrom = 0;
volatile byte msgTo = 0;
volatile byte msgToAnchor = 0;
volatile byte msgToTag = 0;

// timestamps to remember
DW1000Time timePollSent;
DW1000Time timePollAckReceived;
DW1000Time timeRangeSent;

// data buffer
byte data[LEN_DATA];
byte accData[LEN_ACC_DATA];
byte tagError[TAG_NUM];
byte anchorError[ANCHOR_NUM];
byte separator[SEPARATOR_SIZE];
byte separator2[SEPARATOR_SIZE];
// watchdog and reset period
unsigned long lastActivity;
unsigned long resetPeriod = 10000;//3000;
unsigned long resetSingleEvent = 1000;
unsigned long currentTimestamp = 0;
byte timestampInBytes[4];
// reply times (same on both sides for symm. ranging)
unsigned int replyDelayTimeUS = 3000;

void noteActivity() {
    // update activity timestamp, so that we do not reach "resetPeriod"
    lastActivity = millis();
}

void resetInactive() {
    // tag sends POLL and listens for POLL_ACK
//    SerialUSB.println("DEBUG: reset network");
    networkReset();
    transmitReset();
    clearErrorFlag();
    noteActivity();
}

void clearErrorFlag(){
    for (int tagID = 0; tagID < TAG_NUM; tagID++){
        tagError[tagID] = 0;
    }
    for (int anchorID = 0; anchorID < ANCHOR_NUM; anchorID++){
        anchorError[anchorID] = 0;
    }
}

void networkReset(){
    currentStatus = BS_IDLE;
    msgToAnchor = ANCHOR_ID_OFFSET+1;
    msgToTag = TAG_ID_OFFSET+1;
    expectedMsgId = POLL_ACK;  
//    expectedMsgId = POLL_ACK;            
}

void handleSent() {
    // status change on sent success
    sentAck = true;
}

void handleReceived() {
    // status change on received success
    receivedAck = true;
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

void transmitSync() {
//    SerialUSB.println("DEBUG: BROADCAST timestamp");
    DW1000.newTransmit();
    DW1000.setDefaults();
    data[0] = SYNC_REQ;
    data[1] = DEVICE_ID;
    data[2] = 0;
    unsigned long timestamp = micros();
    data[3] = timestamp & 0xFF;
    data[4] = (timestamp>>8) & 0xFF;
    data[5] = (timestamp>>16) & 0xFF;
    data[6] = (timestamp>>24) & 0xFF;
    DW1000.setData(data, LEN_DATA);
    DW1000.startTransmit();
}

void transmitReset() {
    DW1000.newTransmit();
    DW1000.setDefaults();
    data[0] = RESET_NETWORK;
    data[1] = DEVICE_ID;
    data[2] = 0;
    DW1000.setData(data, LEN_DATA);
    DW1000.startTransmit();
}

void transmitToken() {
    DW1000.newTransmit();
    DW1000.setDefaults();
    data[0] = GRANT_TOKEN;
    data[1] = DEVICE_ID;
    data[2] = msgToTag;
    DW1000.setData(data, LEN_DATA);
    DW1000.startTransmit();
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
}

void receiver() {
    DW1000.newReceive();
    DW1000.setDefaults();
    // so we don't need to restart the receiver manually
    DW1000.receivePermanently(true);
    DW1000.startReceive();
}

void setup() {
    // DEBUG monitoring
    SerialUSB.begin(57600);
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
    char msg[256];
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
    // anchor starts by transmitting a POLL message
    receiver();
    msgToAnchor = ANCHOR_ID_OFFSET + 1;
    msgToTag = TAG_ID_OFFSET + 1;
    separator[0] = 0xFF;
    separator[1] = 0xFF;
    separator2[0] = 0xFE;
    separator2[1] = 0xFE;
    transmitSync();
    noteActivity();
}

void loop() {
    if (!sentAck && !receivedAck) {
        // check if inactive
        if(millis() - lastActivity > resetPeriod) {
            resetInactive();
        } else {
            // two scenario that will cause reset
            if (currentStatus == BS_WAIT_FOR_TAG && millis() - lastActivity > resetSingleEvent*3) {
                SerialUSB.write(separator, SEPARATOR_SIZE);
                SerialUSB.write(TAG_DIED);//
                SerialUSB.write(msgToTag);
                SerialUSB.print("Tag died:");SerialUSB.println(msgToTag);
                // mark the tag and continue
                tagError[msgToTag-TAG_ID_OFFSET-1] += 1;
                msgToTag += 1;
                if (msgToTag > TAG_ID_OFFSET+TAG_NUM){
                    // finished with all tags, restart  
                    delay(TAG_INTERVAL);
                    networkReset();
                    transmitSync();
                    noteActivity();
                } else {
                    // copy acc data, move to next tage
                    SerialUSB.write(separator, SEPARATOR_SIZE);
                    SerialUSB.write(msgFrom);
                    SerialUSB.write(separator2, SEPARATOR_SIZE);
                    SerialUSB.write(data+3, LEN_ACC_DATA);
                    expectedMsgId = TOKEN_RELEASE;
                    transmitToken();
                    noteActivity();
                }
            } else if (currentStatus == BS_WAIT_FOR_ANCHOR && millis() - lastActivity >resetSingleEvent){
                
                SerialUSB.write(separator, SEPARATOR_SIZE);
                SerialUSB.write(ANCHOR_DIED);
                SerialUSB.write(msgToAnchor);
                // mark the tag and continue
                anchorError[msgToAnchor-ANCHOR_ID_OFFSET-1] += 1;
                msgToAnchor += 1;
                if (msgToAnchor > ANCHOR_ID_OFFSET+ANCHOR_NUM){
                    msgToAnchor = ANCHOR_ID_OFFSET+1;
                    expectedMsgId = TOKEN_RELEASE;
                    transmitToken();
                    noteActivity();
                } else{
                    // move to next anchor
                    delay(ANCHOR_INTERVAL);
                    expectedMsgId = POLL_ACK;
                    transmitPoll();
                    noteActivity();
                }                
            }
        }
        for (int tagID = 0; tagID < TAG_NUM; tagID++){
            if (tagError[tagID] > BS_TAG_RESET_COUNT) {
                resetInactive();
            }
        } 
        
        for (int anchorID = 0; anchorID < ANCHOR_NUM; anchorID++){
            if (anchorError[anchorID] > BS_TAG_RESET_COUNT) {
                resetInactive();
            }
        }
    } else {
        // continue on any success confirmation
        if (sentAck) {
            currentStatus = BS_IDLE;
            sentAck = false;
            msgId = data[0];
            if (msgId == POLL) {
                currentStatus = BS_WAIT_FOR_ANCHOR;
                DW1000.getTransmitTimestamp(timePollSent);
                //SerialUSB.print("Sent POLL @ "); SerialUSB.println(timePollSent.getAsFloat());
            } else if (msgId == RANGE) {
                currentStatus = BS_WAIT_FOR_ANCHOR;
                DW1000.getTransmitTimestamp(timeRangeSent);
                noteActivity();
            } else if (msgId == SYNC_REQ){
                // once finish the sync, start a new poll
                delay(BS_INTERVAL);
                expectedMsgId = POLL_ACK;
                transmitPoll();
            } else if (msgId == GRANT_TOKEN){
                currentStatus = BS_WAIT_FOR_TAG;
            } else if (msgId == RESET_NETWORK){
                delay(BS_INTERVAL);
                networkReset();
                transmitSync();
            }
            noteActivity();
        }
        if(receivedAck) {
            receivedAck = false;
            // get message and parse
            DW1000.getData(data, LEN_DATA);
            msgId = data[0];
            msgFrom = data[1];
            msgTo = data[2];
            if (msgTo == DEVICE_ID){
                currentStatus = BS_IDLE; 
                if(msgId != expectedMsgId) {
                    // unexpected message, start over again
                    networkReset();
                    transmitReset();
                    return;
                } 
                if (msgId == POLL_ACK && msgFrom == msgToAnchor) {
                    DW1000.getReceiveTimestamp(timePollAckReceived);
                    expectedMsgId = RANGE_REPORT;
                    transmitRange();
                    noteActivity();
                    anchorError[msgToAnchor-ANCHOR_ID_OFFSET-1] = 0;
                } else if(msgId == RANGE_REPORT && msgFrom == msgToAnchor) {
                    float curRange;
                    memcpy(&curRange, data+CONTROL_SIZE, 4);
                    msgToAnchor += 1;
                    if (msgToAnchor > ANCHOR_ID_OFFSET+ANCHOR_NUM){
                      msgToAnchor = ANCHOR_ID_OFFSET+1;
                      // finish anchor round at local
                      // send token to tags       
                      expectedMsgId = TOKEN_RELEASE;
//                      msgToTag = TAG_ID_OFFSET + 1;
                      transmitToken();
                    } else{
                      delay(ANCHOR_INTERVAL);//
                      expectedMsgId = POLL_ACK;
                      transmitPoll();
                    }
                    noteActivity();
                } else if (msgId == TOKEN_RELEASE && msgFrom == msgToTag) {
                    writeAccData();
                    
                    tagError[msgToTag-TAG_ID_OFFSET-1] = 0;
                    msgToTag += 1;
                    if (msgToTag > TAG_ID_OFFSET+TAG_NUM){
                        // finished with all tags  
                        delay(TAG_INTERVAL);
                        networkReset();
                        transmitSync();
                        noteActivity();
                    } else {
                        // copy acc data
                        delay(TAG_INTERVAL);
                        expectedMsgId = TOKEN_RELEASE;
                        transmitToken();
                        noteActivity();
                    }
                }
                else if(msgId == RANGE_FAILED) {
                    networkReset();
                    transmitPoll();
                    noteActivity();
                }
            }
        }
      
    }
}

void writeAccData(){
//    SerialUSB.print("DEBUG: msg from -- ");
//    SerialUSB.println(msgFrom);
//    currentTimestamp = micros();
//    SerialUSB.println(currentTimestamp);
    SerialUSB.write(separator, SEPARATOR_SIZE);
    SerialUSB.write(msgFrom);
    SerialUSB.write(separator2, SEPARATOR_SIZE);
    currentTimestamp = micros();
    timestampInBytes[0] = currentTimestamp & 0xFF;
    timestampInBytes[1] = (currentTimestamp >> 8) & 0xFF;
    timestampInBytes[2] = (currentTimestamp >> 16) & 0xFF;
    timestampInBytes[3] = (currentTimestamp >> 24) & 0xFF;
    SerialUSB.write(timestampInBytes, 4);
    SerialUSB.write(separator2, SEPARATOR_SIZE);
//    SerialUSB.println("#########");
//    SerialUSB.println(msgFrom);
    for (int i = 0; i< LEN_ACC_DATA; i++){
      SerialUSB.write(data[3+i]);  
//      SerialUSB.println(data[3+i]);
      data[3+i] = 0;
    }
}
