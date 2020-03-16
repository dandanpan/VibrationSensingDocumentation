/*
 * Anchor Node: 
 * vibration sensing and synchronization
 */


#include <SPI.h>
#include <DW1000.h>
#include "Footstep.h"

#define DEVICE_ID 2

#define SDCD_CS_PIN     4
#define RADIO_CS_PIN    10
#define RADIO_RST_PIN   9
#define RADIO_IRQ_PIN   2
#define ADCPIN          A1
#define DW_MICROSECONDS 1

// message flow state
volatile byte expectedMsgId = POLL;
// message sent/received state
volatile boolean sentAck = false;
volatile boolean receivedAck = false;
volatile byte msgId = 0;
volatile byte msgFrom = 0;
volatile byte msgTo = 0;
// sampling variables
volatile boolean writeLoc = false;
volatile boolean usingBuffA = true;
volatile int bufferIdx = 0;
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
byte separator[SEPARATOR_SIZE] = {0xFF,0xFF};
byte separator2[SEPARATOR_SIZE] = {0xFE,0xFE};
int counter = 0;
// watchdog and reset period
unsigned long lastActivity;
unsigned long resetPeriod = 4000;
volatile unsigned long timestamp = 0;
volatile unsigned long receiveTime = 0;
volatile unsigned long localReferenceTime = 0;
volatile unsigned long bufferTimestamp = 0;
volatile unsigned long funTime1 = 0;
volatile unsigned long funTime2 = 0;
volatile boolean updateTimestamp = false;
volatile boolean printTimestamp = false;
// reply times (same on both sides for symm. ranging)
unsigned int replyDelayTimeUS = 3000;
char msg[256];
unsigned int testByte;
int resetCount = 0;

/*
 * Data write start from here
 */

void ADC_Handler(){
//  __disable_irq();
  if(ADC->INTFLAG.reg & 0x01){  // RESRDY interrupt
    uint16_t value = ADC->RESULT.reg;
    readData(value);
  }
//  __enable_irq();
}

static __inline__ void ADCsync() __attribute__((always_inline, unused));
static void   ADCsync() {
  while (ADC->STATUS.bit.SYNCBUSY == 1); //Just wait till the ADC is free
}

void adc_init(){
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
  ADC->SAMPCTRL.reg = 0x11;
//  ADC->SAMPCTRL.reg = 0x00;  ; //sample length in 1/2 CLK_ADC cycles
  ADCsync();
  ADC->CTRLB.reg = ADC_CTRLB_PRESCALER_DIV512 | ADC_CTRLB_FREERUN | ADC_CTRLB_RESSEL_10BIT;//ADC_CTRLB_PRESCALER_DIV256
  ADCsync();
  ADC->CTRLA.bit.ENABLE = 0x01;
  ADCsync();
  NVIC_EnableIRQ( ADC_IRQn ) ;
  NVIC_SetPriority(ADC_IRQn, 0);
}

void readData(uint16_t vibData) {
  fillBuffer(vibData);
  checkBufferSize();
}

void fillBuffer(uint16_t vibReading) {
  if (usingBuffA) {
    bufferA[bufferIdx] = vibReading & 0x00FF;
    bufferIdx += 1;
    vibReading >>= 8;
    bufferA[bufferIdx] = vibReading & 0x00FF;
    bufferIdx += 1;
  } else {
    bufferB[bufferIdx] = vibReading & 0x00FF;
    bufferIdx += 1;
    vibReading >>= 8;
    bufferB[bufferIdx] = vibReading & 0x00FF;
    bufferIdx += 1;
  }
}

void checkBufferSize() {
  if (bufferIdx >= BUFFER_SIZE) {
    usingBuffA = !usingBuffA;
    bufferIdx = 0;
    writeLoc = true;

    if(updateTimestamp){
      bufferTimestamp = (micros() - localReferenceTime) + timestamp;
      updateTimestamp = false;
      printTimestamp = true;
    }
  }
}

void float2Bytes(byte bytes_temp[4],float float_variable){ 
  union {
    float a;
    unsigned char bytes[4];
  } thing;
  thing.a = float_variable;
  memcpy(bytes_temp, thing.bytes, 4);
}

void printDistance(byte nodeID, float distance) {
  DW1000.getSystemTimestamp(sysTime);
  SerialUSB.write(separator, SEPARATOR_SIZE);
  SerialUSB.write(nodeID);
  byte bytesArray[4];
  float2Bytes(bytesArray, distance);
  SerialUSB.write(separator2, SEPARATOR_SIZE);
  SerialUSB.write(bytesArray, 4);
}

void printTheTimestamp(unsigned long t){
  SerialUSB.write(separator, SEPARATOR_SIZE);
  byte tempArray[4];
  tempArray[0] = t & 0xFF;
  tempArray[1] = (t>>8) & 0xFF;
  tempArray[2] = (t>>16) & 0xFF;
  tempArray[3] = (t>>24) & 0xFF;
  SerialUSB.write(tempArray, 4);
}

void printVibration() {
  SerialUSB.write(separator, SEPARATOR_SIZE);
  if (usingBuffA) {
    SerialUSB.write(bufferB, BUFFER_SIZE);
  } else {
    SerialUSB.write(bufferA, BUFFER_SIZE);
  }
  if(printTimestamp){
    printTheTimestamp(bufferTimestamp);
    printTimestamp = false;   
  }
}


/*
 * Data write from here
 */

/*
 * RANGING ALGORITHMS
 * ------------------
 * Either of the below functions can be used for range computation (see line "CHOSEN
 * RANGING ALGORITHM" in the code).
 * - Asymmetric is more computation intense but least error prone
 * - Symmetric is less computation intense but more error prone to clock drifts
 *
 * The anchors and tags of this reference example use the same reply delay times, hence
 * are capable of symmetric ranging (and of asymmetric ranging anyway).
 */

void computeRangeAsymmetric() {
  // asymmetric two-way ranging (more computation intense, less error prone)
  DW1000Time round1 = (timePollAckReceived - timePollSent).wrap();
  DW1000Time reply1 = (timePollAckSent - timePollReceived).wrap();
  DW1000Time round2 = (timeRangeReceived - timePollAckSent).wrap();
  DW1000Time reply2 = (timeRangeSent - timePollAckReceived).wrap();
  DW1000Time tof = (round1 * round2 - reply1 * reply2) / (round1 + round2 + reply1 + reply2);
  // set tof timestamp
  timeComputedRange.setTimestamp(tof);
}

void computeRangeSymmetric() {
  // symmetric two-way ranging (less computation intense, more error prone on clock drift)
  DW1000Time tof = ((timePollAckReceived - timePollSent) - (timePollAckSent - timePollReceived) +
                    (timeRangeReceived - timePollAckSent) - (timeRangeSent - timePollAckReceived)) * 0.25f;
  // set tof timestamp
  timeComputedRange.setTimestamp(tof);
}

/*
 * END RANGING ALGORITHMS
 * ----------------------
 */

/*
 * Radio Control start from here
 */
void noteActivity() {
  // update activity timestamp, so that we do not reach "resetPeriod"
  lastActivity = millis();
}

void resetInactive() {
  // anchor listens for POLL
  expectedMsgId = POLL;
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

void transmitPollAck() {
  DW1000.newTransmit();
  DW1000.setDefaults();
  data[0] = POLL_ACK;
  data[1] = DEVICE_ID;
  data[2] = msgFrom;
  // delay the same amount as ranging tag
  DW1000Time deltaTime = DW1000Time(replyDelayTimeUS, DW_MICROSECONDS);
  DW1000.setDelay(deltaTime);
  DW1000.setData(data, LEN_DATA);
  DW1000.startTransmit();
}

void transmitRangeReport(float curRange) {
  DW1000.newTransmit();
  DW1000.setDefaults();
  data[0] = RANGE_REPORT;
  data[1] = DEVICE_ID;
  data[2] = msgFrom;
  // write final ranging result
  memcpy(data + CONTROL_SIZE, &curRange, 4);
  DW1000.setData(data, LEN_DATA);
  DW1000.startTransmit();
}

void transmitRangeFailed() {
  DW1000.newTransmit();
  DW1000.setDefaults();
  data[0] = RANGE_FAILED;
  data[1] = DEVICE_ID;
  data[2] = msgFrom;
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

void radioInit(){
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

void checkRadioRegisters(){
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

void radioReset(){
//    DW1000.hardReset();
    resetCount = 0;
    radioInit();
    receiver();   
}

/*
 * Radio Control end from here
 */

void setup() {
    // DEBUG monitoring
    SerialUSB.begin(115200);
    delay(4000);
    SerialUSB.println("### DW1000-arduino-ranging-anchor ###");
    // initialize the driver
    DW1000.begin(RADIO_IRQ_PIN, RADIO_RST_PIN);
    SerialUSB.println("DW1000 initialized ...");
    // general configuration
    radioInit();
    checkRadioRegisters();
    receiver();
    noteActivity();
    adc_init();
    funTime1 = millis();
}

void loop() {
/* 
 *  NETWORK PART
 */
    if (!sentAck && !receivedAck) {
        // check if inactive
        if (millis() - lastActivity > resetPeriod) {
            // check SPI
            testByte = DW1000.getShortAddress();
            if (testByte != DEVICE_ID){
                radioReset();
            }
            // check softreset times
            resetCount += 1;
            if (resetCount > 10){
                radioReset(); 
            }
            // softreset
            resetInactive();
        }
    } else {
        resetCount = 0;
        // continue on any success confirmation
        if (sentAck) {
            sentAck = false;
            msgId = data[0];
            if (msgId == POLL_ACK) {
              DW1000.getTransmitTimestamp(timePollAckSent);
              noteActivity();
            }
        }
        if (receivedAck) {
            receivedAck = false;
            // get message and parse
            DW1000.getData(data, LEN_DATA);
            msgId = data[0];
            msgFrom = data[1];
            msgTo = data[2];

            if (msgTo == DEVICE_ID) {
                // it is talking to me
                if (msgId != expectedMsgId) {
                    // unexpected message, start over again (except if already POLL)
                    protocolFailed = true;
                }
                if (msgId == POLL) {
                    // on POLL we (re-)start, so no protocol failure
                    protocolFailed = false;
                    DW1000.getReceiveTimestamp(timePollReceived);
                    expectedMsgId = RANGE;
                    transmitPollAck();
                    noteActivity();
                } else if (msgId == RANGE) {
                    DW1000.getReceiveTimestamp(timeRangeReceived);
                    expectedMsgId = POLL;
                    if (!protocolFailed) {
                        timePollSent.setTimestamp(data + CONTROL_SIZE);
                        timePollAckReceived.setTimestamp(data + CONTROL_SIZE + TSIZE);
                        timeRangeSent.setTimestamp(data + CONTROL_SIZE + TSIZE * 2);
                        // (re-)compute range as two-way ranging is done
                        computeRangeAsymmetric(); // CHOSEN RANGING ALGORITHM
                        float distance = timeComputedRange.getAsMeters();
                        transmitRangeReport(distance);
                        if (msgFrom != 1) {
                            // tag ranging with anchor
                            printDistance(msgFrom, distance);
                        }
                    } else {
                        transmitRangeFailed();
                    }
                    noteActivity();
                }
            } else if (msgTo == 0){
                  if(msgId == RESET_NETWORK) {
                      resetInactive();
                  } else if (msgId == SYNC_REQ) {
                      SerialUSB.println("received SYNC_REQ");
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
                  }
            }
        }
    }

    /*
    * SERIAL OUTPUT PART
    */
//    if (writeLoc) {
//      writeLoc = false;
//      printVibration();
//    }
}
