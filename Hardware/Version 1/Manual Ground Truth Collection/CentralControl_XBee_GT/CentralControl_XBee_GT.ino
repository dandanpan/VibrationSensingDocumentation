/*
 * THis code is for data collection with single amplifiers
 * the difference between different version of the MultiAmp
 * is mainly the data store format
 */

#include <SD.h>
#include <SPI.h>
#include <stdint.h>
#include <XBee.h>

#define POWERON_PIN           37
#define PWR_START_BTN         38
#define LED1_PIN              32
#define LED2_PIN              33
#define LED3_PIN              34
#define LED4_PIN              29
#define SPEAKER_PIN           66
#define SD_CS_PIN             4
#define RTC_CS_PIN            52
#define PKT_SIZE              2

XBee xbee = XBee();
XBeeResponse response = XBeeResponse();
Rx16Response rx16 = Rx16Response();
uint8_t option = 0;
uint16_t data = 0;
uint8_t pktLen = 0;
uint16_t pktSource = 0;
uint8_t payload[] = { 0, 0 };//, 0, 0, 0, 0, 0, 0 };
Tx16Request tx = Tx16Request(0xFFFF, payload, sizeof(payload));
int bufferIdx = -1;
boolean generatingPkt = 0;

void setup() {
  // POWER
  pinMode(POWERON_PIN, OUTPUT);    // power ON pin
  pinMode(PWR_START_BTN, INPUT);     // power switch sense, high is pushed.
  pinMode(SPEAKER_PIN, OUTPUT);
  digitalWrite(POWERON_PIN, HIGH); // when we get power we keep it on

  // serial
  SerialUSB.begin(115200);
  Serial.begin(9600);
  xbee.setSerial(Serial);

  // LED
  LED_preset();
  LED_init();
}

void loop() {
  delay(100);
  readSerial();
  readXBee();
}

void readSerial(){
  // if there is input from PC
  // store the data and extract information
  while (SerialUSB.available()) {
    uint16_t inputByte = SerialUSB.read();
    SerialUSB.println(inputByte);
    if (inputByte == 33){
      if (bufferIdx == -1){
        // start a new package
        bufferIdx = 0;
        generatingPkt = 1;
      } else {
        // end a package
        bufferIdx = -1;
        generatingPkt = 0;
        xbee.send(tx);
        
        SerialUSB.println("sent:");
        for (int i = 0; i < PKT_SIZE; i++){
          SerialUSB.println(payload[i]);
        }
        SerialUSB.println("#####");
      }
    } else {
      if (generatingPkt == 1 && bufferIdx < PKT_SIZE){
        payload[bufferIdx] = inputByte;
        bufferIdx = bufferIdx + 1;
      }
    }
  }
}

void readXBee(){
  xbee.readPacket();
  if (xbee.getResponse().isAvailable()) {
    SerialUSB.println("Receiving...");
    if (xbee.getResponse().isError()){
      xbee.getResponse().getErrorCode();
    } else {
      if (xbee.getResponse().getApiId() == RX_16_RESPONSE) {
        xbee.getResponse().getRx16Response(rx16);
        option = rx16.getOption();
        pktLen = rx16.getDataLength();
        pktSource = rx16.getRemoteAddress16();
        SerialUSB.print("Got RX pkt from:");
        SerialUSB.println(pktSource);
        // check ok, and find id
        if (pktLen == 2){
          data = rx16.getData(0);
          if (data == 79){
            data = rx16.getData(1);
            if (data == 75){
              SerialUSB.println("OK~");
            }
          }
        } else {
          SerialUSB.println("failed");
        }
      }
    }
  } 
}

void LED_preset() {
  // LED SETTING
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  pinMode(LED3_PIN, OUTPUT);
  pinMode(LED4_PIN, OUTPUT);

  digitalWrite(LED1_PIN, HIGH);
  digitalWrite(LED2_PIN, HIGH);
  digitalWrite(LED3_PIN, HIGH);
  digitalWrite(LED4_PIN, HIGH);
}

void LED_init() {
  // LED indicator
  digitalWrite(LED2_PIN, LOW);
}


