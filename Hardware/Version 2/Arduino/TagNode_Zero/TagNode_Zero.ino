/*
   Tag: provides ground truth for the localization system
   Tasks in each cycle (every half second):
   1. write data in buffer into the sd card
   2. check the radio interrupt see if there is timestamp update
   Task in the radio interrupt, update baseline timestamp and reference timestamp
   Task in the data collection interrupt, add data into the buffer
   Alternative data collection (controlled by delay)
*/

#include <SPI.h>
#include <DW1000.h>
#include <SD.h>

#define SDCD_CS_PIN     4
#define RADIO_CS_PIN    10
#define RADIO_RST_PIN   9
#define RADIO_IRQ_PIN   2
#define ADCPIN          A2

#define NETWORK_ID      10
#define DEVICE_ID       14

#define POLL            0
#define POLL_ACK        1
#define RANGE           2
#define RANGE_REPORT    3
#define GRANT_TOKEN     4
#define TOKEN_RELEASE   5
#define RESET_NETWORK   6
#define SYNC_REQ        7
#define SYNC_ACK        8
#define RANGE_FAILED    255

#define DW_MICROSECONDS 1
#define SAMPLE_RATE     1000
#define CLOCK_RATE      48000000
#define BUFFER_SIZE     256
#define TSIZE           5
#define CONTROL_SIZE    5
#define LEN_DATA        123 // MSG_TYPE, DEVICE_ID, TO_DEVICE, TOKEN, RELEASE_TOKEN, TIMESTAMP_NUM*TIMESTAMP_LEN


// message sent/received state
boolean sentAck = false;
boolean receivedAck = false;
byte msgId = 0;
byte msgFrom = 0;
byte msgTo = 0;
// sampling variables
boolean writeLoc = false;
boolean working = false;
boolean detect = false;
boolean usingBuffA = true;
int bufferIdx = 0;
// protocol error state
boolean protocolFailed = false;

// timestamps to remember
DW1000Time timeSystem;
DW1000Time timePollSent;
DW1000Time timePollReceived;
DW1000Time timePollAckSent;
DW1000Time timePollAckReceived;
DW1000Time timeRangeSent;
DW1000Time timeRangeReceived;
DW1000Time timeSyncReceived;
// last computed range/time
DW1000Time timeComputedRange;
// data buffer
byte bufferA[BUFFER_SIZE];
byte bufferB[BUFFER_SIZE];
byte data[LEN_DATA];
byte sysTime[TSIZE];
byte targetTime[TSIZE];
int counter = 0;
// watchdog and reset period
unsigned long lastActivity;
unsigned long resetPeriod = 4000;
unsigned long timestamp = 0;
unsigned long receiveTime = 0;
unsigned long localReferenceTime = 0;
unsigned long bufferTimestamp = 0;
unsigned long sampleTimestamp = 0;
unsigned long lastSampleTime = 0;
boolean updateTimestamp = false;
boolean printTimestamp = false;


int pressureVal = -1;
int pressureBuffer[BUFFER_SIZE];
unsigned int replyDelayTimeUS = 3000;
char msg[256];
char filest[20];
uint16_t amplitude;
int sampleCount = 0;
int resetCount = 0;
boolean LED_ON = HIGH;
int shutdown = 0;
File dataFile;

void noteActivity() {
  // update activity timestamp, so that we do not reach "resetPeriod"
  lastActivity = millis();
}

void resetInactive() {
  // anchor listens for POLL
  noteActivity();
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

void receiver() {
  DW1000.newReceive();
  DW1000.setDefaults();
  // so we don't need to restart the receiver manually
  DW1000.receivePermanently(true);
  DW1000.startReceive();
}

void radioInit() {
  DW1000.select(RADIO_CS_PIN);
  DW1000.newConfiguration();
  DW1000.setDefaults();
  DW1000.setDeviceAddress(DEVICE_ID);
  DW1000.setNetworkId(NETWORK_ID);
  DW1000.enableMode(DW1000.MODE_LONGDATA_FAST_ACCURACY);// change from fast to range
  DW1000.commitConfiguration();
  DW1000.attachSentHandler(handleSent);
  DW1000.attachReceivedHandler(handleReceived);
}

void checkRadioRegisters() {
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
}

void SDInit() {
  int filecount = 1;
  SerialUSB.println("Start initilization of the SD card");
  while (!SD.begin(SDCD_CS_PIN)) {
    SerialUSB.println("Card failed, or not present");
    // don't do anything more:
    delay(100);
  }
  SerialUSB.println("SD Card initiated");

  for (filecount = 1; filecount < 1000; filecount++) {
    sprintf(filest, "%d.txt", filecount);
    if (!SD.exists(filest)) break;
    else {
      SerialUSB.print("test No."); SerialUSB.println(filecount);
    }
  }

  SerialUSB.print("File No."); SerialUSB.println(filecount);

  dataFile = SD.open(filest, O_RDWR | O_CREAT);
  dataFile.close();
}

void setup() {
  // set pin modes
  pinMode(SDCD_CS_PIN, OUTPUT);
  pinMode(RADIO_CS_PIN, OUTPUT);

  // declare pins
  SerialUSB.begin(115200);
  delay(5000);

  // select radio
  digitalWrite(SDCD_CS_PIN, HIGH);
  digitalWrite(RADIO_CS_PIN, LOW);// enable radio
  
  // initialize the radio
  DW1000.begin(digitalPinToInterrupt(RADIO_IRQ_PIN), RADIO_RST_PIN);
  SerialUSB.println("DW1000 initialized ...");
  radioInit();
  checkRadioRegisters();
  receiver();
  noteActivity();

  delay(500);
  // initialize the sd card
  digitalWrite(RADIO_CS_PIN, HIGH);// disable radio
  digitalWrite(SDCD_CS_PIN, LOW);
  SDInit();

  // disable both
  digitalWrite(RADIO_CS_PIN, HIGH);// disable radio
  digitalWrite(SDCD_CS_PIN, HIGH);
  
  lastSampleTime = millis();
}

void loop() {
  // check radio
  radioSync();

  // sample
  sampleAndWrite();
  digitalWrite(RADIO_CS_PIN, LOW);
}

void sampleAndWrite(){
    sampleTimestamp = millis();
    if (sampleTimestamp - lastSampleTime > 10){
        lastSampleTime = millis();
        pressureVal = analogRead(ADCPIN);
        bufferTimestamp = (micros() - localReferenceTime) + timestamp;
        bufferA[bufferIdx] = bufferTimestamp & 0xFF;
        bufferIdx += 1;
        bufferA[bufferIdx] = (bufferTimestamp >> 8) & 0xFF;
        bufferIdx += 1;
        bufferA[bufferIdx] = (bufferTimestamp >> 16) & 0xFF;
        bufferIdx += 1;
        bufferA[bufferIdx] = (bufferTimestamp >> 24) & 0xFF;
        bufferIdx += 1;
        bufferA[bufferIdx] = pressureVal & 0xFF;
        bufferIdx += 1;
        bufferA[bufferIdx] = (pressureVal >> 8) & 0xFF;
        bufferIdx += 1;
        if (bufferIdx >= BUFFER_SIZE - 4) {
            for (int j = bufferIdx; j <= BUFFER_SIZE; j++){
              bufferA[j] = 0xFE;
              bufferIdx += 1;
            }
            bufferIdx = 0;
            digitalWrite(SDCD_CS_PIN, LOW);
            dataFile = SD.open(filest, O_RDWR | O_APPEND);
            dataFile.write(bufferA, BUFFER_SIZE);
            dataFile.close();
            digitalWrite(SDCD_CS_PIN, HIGH);
            SerialUSB.println("flash the data");
        } 
    } 
}

void radioSync() {
  
//  SerialUSB.println("check radio receiving");
  digitalWrite(RADIO_CS_PIN, LOW);
    
  if (receivedAck) {
    SerialUSB.print("receive: ");
    receivedAck = false;
    
    // get message and parse
    DW1000.getData(data, LEN_DATA);
    msgId = data[0];
    msgFrom = data[1];
    msgTo = data[2];
    SerialUSB.println(msgId);

    if (msgTo == 0) {
      if (msgId == RESET_NETWORK) {
        resetInactive();
      } else if (msgId == SYNC_REQ) {
        timestamp = 0;
        timestamp |= data[6];
        timestamp <<= 8;
        timestamp |= data[5];
        timestamp <<= 8;
        timestamp |= data[4];
        timestamp <<= 8;
        timestamp |= data[3];
        localReferenceTime = micros();
        timestamp += localReferenceTime - receiveTime;
        updateTimestamp = true;
        SerialUSB.println("sync");
      }
    }
  }
  digitalWrite(RADIO_CS_PIN, HIGH);
}
