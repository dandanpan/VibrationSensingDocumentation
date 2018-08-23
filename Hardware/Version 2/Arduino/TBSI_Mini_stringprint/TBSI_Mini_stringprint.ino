/*
 * Anchor Node: 
 * vibration sensing
 */

#define ADCPIN              A0
#define CLOCK_RATE          48000000
#define BUFFER_SIZE         512
#define SEPARATOR_SIZE      2

// sampling variables
volatile boolean writeLoc = false;
volatile boolean usingBuffA = true;
volatile int bufferIdx = 0;
// data buffer
byte bufferA[BUFFER_SIZE];
byte bufferB[BUFFER_SIZE];
byte separator[SEPARATOR_SIZE] = {0xFF,0xFF};


/*
 * Data write start from here
 */
void ADC_Handler(){
//  __disable_irq();
  if(ADC->INTFLAG.reg & 0x01){  // RESRDY interrupt
    uint16_t value = ADC->RESULT.reg;
    SerialUSB.println(value);
//    readData(value);
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
  //ADC->AVGCTRL.reg = 0x01 ;       //no averaging //changed to 0x01 from 0x00
  ADC->AVGCTRL.bit.SAMPLENUM = 0x01;
  ADC->AVGCTRL.bit.ADJRES = 0x01;
  ADC->SAMPCTRL.reg = 0x10;

//  ADC->SAMPCTRL.reg = 0x11;
//  ADC->SAMPCTRL.reg = 0x00;  ; //sample length in 1/2 CLK_ADC cycles
  ADCsync();
  ADC->CTRLB.reg = ADC_CTRLB_PRESCALER_DIV512 | ADC_CTRLB_FREERUN | ADC_CTRLB_RESSEL_16BIT;//ADC_CTRLB_PRESCALER_DIV256 //changed ADC_CTRLB_RESSEL_10BIT to 16
  ADCsync();
  ADC->CTRLA.bit.ENABLE = 0x01;
  ADCsync();
  NVIC_EnableIRQ( ADC_IRQn ) ;
  NVIC_SetPriority(ADC_IRQn, 0);
}

//void readData(uint16_t vibData) {
//  
//  fillBuffer(vibData);
//  checkBufferSize();
//}

//void fillBuffer(uint16_t vibReading) {
//  if (usingBuffA) {
//    bufferA[bufferIdx] = vibReading & 0x00FF;
//    bufferIdx += 1;
//    vibReading >>= 8;
//    bufferA[bufferIdx] = vibReading & 0x00FF;
//    bufferIdx += 1;
//  } else {
//    bufferB[bufferIdx] = vibReading & 0x00FF;
//    bufferIdx += 1;
//    vibReading >>= 8;
//    bufferB[bufferIdx] = vibReading & 0x00FF;
//    bufferIdx += 1;
//  }
//}

//void checkBufferSize() {
//  if (bufferIdx >= BUFFER_SIZE) {
//    usingBuffA = !usingBuffA;
//    bufferIdx = 0;
//    writeLoc = true;
//  }
//}

//void printVibration() {
//  SerialUSB.write(separator, SEPARATOR_SIZE);
//  if (usingBuffA) {
////    SerialUSB.write(bufferB, BUFFER_SIZE);
//    SerialUSB.println(bufferB)
//  } else {
////    SerialUSB.write(bufferA, BUFFER_SIZE);
//    SerialUSB.println(bufferA)
//  }
//}

void setup() {
    // DEBUG monitoring
    SerialUSB.begin(115200);
    delay(4000);
    adc_init();
}

void loop() {
//    if (writeLoc) {
//      writeLoc = false;
//      printVibration();
//    }
}
