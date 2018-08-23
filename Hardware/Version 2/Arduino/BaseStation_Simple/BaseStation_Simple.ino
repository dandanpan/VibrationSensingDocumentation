/*
   Base Station:
   controls the tag to range in a round robin manner
*/

#include <SPI.h>
#include <DW1000.h>
#include "Footstep.h"
#define DEVICE_ID         1
#define DEBUG             1

// pin for Zero
//#define RESET_PIN           9
//#define CS_PIN              10
//#define IRQ_PIN             2

// pin for Due
#define CS_PIN              52
#define RESET_PIN           5
#define IRQ_PIN             3

// message flow state
// message sent/received state
volatile boolean sentAck = false;
volatile boolean receivedAck = false;
volatile byte msgId = 0;
volatile byte msgFrom = 0;
volatile byte msgTo = 0;

byte data[LEN_DATA];
unsigned long lastActivity;
unsigned long resetPeriod = 100000;//3000;
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
  transmitReset();
  noteActivity();
}

void handleSent() {
  // status change on sent success
  sentAck = true;
}

void handleReceived() {
  // status change on received success
  receivedAck = true;
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
  data[4] = (timestamp >> 8) & 0xFF;
  data[5] = (timestamp >> 16) & 0xFF;
  data[6] = (timestamp >> 24) & 0xFF;
  DW1000.setData(data, LEN_DATA);
  SerialUSB.println("set data");
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
  
//  digitalPinToInterrupt(IRQ_PIN);
  
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
  transmitSync();
  noteActivity();
}

void loop() {
  if (!sentAck) {
    // check if inactive
    if (millis() - lastActivity > resetPeriod) {
      resetInactive();
      SerialUSB.println("reset");
    }
  } else {
    // continue on any success confirmation
    if (sentAck) {
      SerialUSB.println("sent");
      sentAck = false;
      msgId = data[0];
      if (msgId == SYNC_REQ) {
        // once finish the sync, start a new poll
        delay(BS_INTERVAL);
        transmitSync();
      }
      noteActivity();
    }
  }
}


