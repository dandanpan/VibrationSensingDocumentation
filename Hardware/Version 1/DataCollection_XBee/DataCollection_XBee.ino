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
#define BUFFER_SIZE           512
#define TIME_SYNC_RATE        300
#define SD_CARD_USE           1
#define SAMPLE_RATE           1000
#define OPEN_NEW_FILE_RATE    268435456  // about 1.6M data
#define DEBUG                 1

int amplitude0 = -1;
int amplitude1 = -1;
int amplitude2 = -1;
int dataFileNum = 0;
int bufferIndex = 0;
int sampleCount = 0;
int shutdown = 0;
long writeCount = 0;
long timestamp = -1;
byte buffer1[BUFFER_SIZE];
byte buffer2[BUFFER_SIZE];
File dataFile;
boolean LED_ON = HIGH;
boolean SELECT_RTC = LOW;
volatile boolean writeLoc = false;
volatile boolean flip = true;
volatile boolean working = false;
volatile boolean detect = false;

XBee xbee = XBee();
XBeeResponse response = XBeeResponse();
Rx16Response rx16 = Rx16Response();
uint8_t option = 0;
uint8_t pktLen = 0;
uint16_t data = 0;
uint16_t commandId = 0;
uint16_t commandSeq = 0;
uint8_t payload[] = { 'O', 'K', 0 };
Tx16Request tx = Tx16Request(0x0001, payload, sizeof(payload));//0x0001 is destination

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

  // SD card
  if (SD_CARD_USE) {
    SD_preset();
    SD_init();
  }

  // timer
  startTimer(TC1, 0, TC3_IRQn, SAMPLE_RATE);
}

void loop() {
  readXBee();
  writeSDCard();
  checkShutdown();
}

void checkShutdown(){
  if (detect) {
    detect = false;
    LED_ON = !LED_ON;
    digitalWrite(LED1_PIN, LED_ON);
    shutdown = detectShutdown(shutdown);
  }
}

void readXBee(){
  xbee.readPacket();
  if (xbee.getResponse().isAvailable()) {
    if (xbee.getResponse().isError()){
      xbee.getResponse().getErrorCode();
      SerialUSB.println("XBee receiving error...");
    } else {
      if (xbee.getResponse().getApiId() == RX_16_RESPONSE) {
        xbee.getResponse().getRx16Response(rx16);
        option = rx16.getOption();
        pktLen = rx16.getDataLength();
        if (pktLen == 2){
          commandId = rx16.getData(0);
          commandSeq = rx16.getData(1);
          payload[2] = commandSeq;

          // If received 's', start a new file, 
          // If received 'e', end current file
          if (commandId == 115){ 
            SerialUSB.println("begin");
            if (!working){
              SDGenerateNewFile(commandSeq);
              SerialUSB.println("start new file");
            }
          } else if (commandId == 101){
            if (working){
              SerialUSB.println("end");
              SDCloseFile();
              SerialUSB.println("stop sd");
            }
          }
        }

        xbee.send(tx);
      }
    }
  } 
}

void writeSDCard(){
  if (writeLoc) {
    writeLoc = false;
    if (!flip) {
      dataFile.write(buffer1, BUFFER_SIZE);
    } else {
      dataFile.write(buffer2, BUFFER_SIZE);
    }
  }
  dataFile.flush();
}

//void writeANewFile(){
//  writeCount = writeCount + 1;
//  if (writeCount == OPEN_NEW_FILE_RATE) {
//    writeCount = 0;
//    SDCloseFile();
//    SDGenerateNewFile();
//  }
//}

void speakerRing(int duration) {
  // duration in second
  int iterNum = duration / 2 * 1000;
  for (int i  = 0; i < iterNum; i++) {
    delay(1);
    digitalWrite(SPEAKER_PIN, LOW);
    delay(1);
    digitalWrite(SPEAKER_PIN, HIGH);
  }
}

void SD_preset() {
  SPI.setClockDivider(SD_CS_PIN, 2);
  SPI.setBitOrder(SD_CS_PIN, MSBFIRST);
  SPI.setDataMode(SD_CS_PIN, SPI_MODE0);
}

void SD_end() {
  SPI.end(SD_CS_PIN);
}

void SD_init() {
  if (!SD.begin(SD_CS_PIN, 2)) {
    SerialUSB.println("Card failed, or not present");
    return;
  } else {
    SerialUSB.println("card initialized.");
  }
}

void SDGenerateNewFile(uint16_t commandSeq) {
  char * dataFileString = (char *)malloc(50);
  char * strInt = (char *)malloc(10);
  char * strSeq = (char *)malloc(10);
  strcpy(dataFileString, "data_1.txt");
  while (SD.exists(dataFileString))
  {
    dataFileNum++;
    sprintf(strInt, "%d", dataFileNum);
    sprintf(strSeq, "%d", commandSeq);
    strcpy(dataFileString, "data_");
    strncat(dataFileString, strInt, strlen(strInt));
//    strncat(dataFileString, "_", 1);
//    strncat(dataFileString, strSeq, strlen(strSeq));
    strncat(dataFileString, ".txt", 5);
    SerialUSB.print("curData string: ");
    SerialUSB.println(dataFileString);
  }
  free(strInt);
  dataFile = SD.open(dataFileString, FILE_WRITE);
  if (!dataFile) {
    SerialUSB.println("fail to open file");
  }
  SerialUSB.print("current File name: ");
  SerialUSB.println(dataFileString);
  free(dataFileString);
  working = true;
  SerialUSB.println("open file");
}

void SDCloseFile(){
  working = false;
  dataFile.close();
  SerialUSB.println("close file");
  LED_ON = HIGH;
  digitalWrite(LED1_PIN, LED_ON);
}

void ERTC_preset() {
  SPI.begin(RTC_CS_PIN);
  SPI.setClockDivider(RTC_CS_PIN, 162);
  SPI.setBitOrder(RTC_CS_PIN, MSBFIRST);
  SPI.setDataMode(RTC_CS_PIN, SPI_MODE3);
}

void ERTC_end() {
  SPI.end(RTC_CS_PIN);
}

void ERTC_init() {
  SPI.transfer(RTC_CS_PIN, 0x8E, SPI_CONTINUE);
  delay(10);
  SPI.transfer(RTC_CS_PIN, 0x60); //60= disable Osciallator and Battery SQ wave @1hz, temp compensation, Alarms disabled
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

void TC3_Handler() {
  TC_GetStatus(TC1, 0);
  readData();
}

void startTimer(Tc *tc, uint32_t channel, IRQn_Type irq, uint32_t frequency) {
  pmc_set_writeprotect(false);
  pmc_enable_periph_clk((uint32_t)irq);
  TC_Configure(tc, channel, TC_CMR_WAVE | TC_CMR_WAVSEL_UP_RC | TC_CMR_TCCLKS_TIMER_CLOCK4);
  uint32_t rc = VARIANT_MCK / 128 / frequency; //128 because we selected TIMER_CLOCK4 above
  TC_SetRA(tc, channel, rc / 2); //50% high, 50% low
  TC_SetRC(tc, channel, rc);
  TC_Start(tc, channel);
  tc->TC_CHANNEL[channel].TC_IER = TC_IER_CPCS;
  tc->TC_CHANNEL[channel].TC_IDR = ~TC_IER_CPCS;
  NVIC_EnableIRQ(irq);
}

void readData() {
  if (working) {
    amplitude0 = analogRead(A0);
    amplitude1 = analogRead(A1);
    amplitude2 = analogRead(A2);
    sampleCount = sampleCount + 1;
    if (sampleCount == SAMPLE_RATE) {
      sampleCount = 0;
      detect = true;      
    }
    fillBlock(amplitude0, amplitude1, amplitude2);
    checkBlock();
  }
}

void fillBlock(int num1, int num2, int num3){
  if (flip) {
    buffer1[bufferIndex] = -1;
    bufferIndex += 1;
    buffer1[bufferIndex] = num1 & 0x00FF;
    bufferIndex += 1;
    num1 >>= 8;
    buffer1[bufferIndex] = num1;
    bufferIndex += 1;
    buffer1[bufferIndex] = num2 & 0x00FF;
    bufferIndex += 1;
    num2 >>= 8;
    buffer1[bufferIndex] = num2;
    bufferIndex += 1;
    buffer1[bufferIndex] = num3 & 0x00FF;
    bufferIndex += 1;
    num3 >>= 8;
    buffer1[bufferIndex] = num3;
    bufferIndex += 1;
    buffer1[bufferIndex] = -2;
    bufferIndex += 1;
  } else {
    buffer2[bufferIndex] = -1;
    bufferIndex += 1;
    buffer2[bufferIndex] = num1 & 0x00FF;
    bufferIndex += 1;
    num1 >>= 8;
    buffer2[bufferIndex] = num1;
    bufferIndex += 1;
    buffer2[bufferIndex] = num2 & 0x00FF;
    bufferIndex += 1;
    num2 >>= 8;
    buffer2[bufferIndex] = num2;
    bufferIndex += 1;
    buffer2[bufferIndex] = num3 & 0x00FF;
    bufferIndex += 1;
    num3 >>= 8;
    buffer2[bufferIndex] = num3;
    bufferIndex += 1;
    buffer2[bufferIndex] = -2;
    bufferIndex += 1;
  }
}

void checkBlock(){
  if (bufferIndex == BUFFER_SIZE) {
    flip = !flip;
    bufferIndex = 0;
    writeLoc = true;
  }
}

int detectShutdown(int shutdown) {
  //check buttons
  if (digitalRead(PWR_START_BTN) == HIGH) { //if power button is pressed
    shutdown += 1;
    if (shutdown == 3)  {        //shutdown if pressed long enough
      working = false;
      dataFile.close();
      SerialUSB.println("close file");
      digitalWrite(LED2_PIN, HIGH);
      digitalWrite(POWERON_PIN, LOW);
    } else if (shutdown > 3) {
      digitalWrite(LED2_PIN, HIGH);
      digitalWrite(POWERON_PIN, LOW);
    }    //debounce.
  } else if (shutdown <= 3) {    //if button let go before the timeout reset debounce counter
    shutdown = 0;
  }
  return shutdown;
}

