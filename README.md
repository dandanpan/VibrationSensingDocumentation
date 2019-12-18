# VibrationSensingDocumentation

## Hardware Version 2 Installation
The setup guide for Arduino Zero can be found here:
https://learn.sparkfun.com/tutorials/samd21-minidev-breakout-hookup-guide/setting-up-arduino

The DW1000 Arduino library can be found here:
https://github.com/thotro/arduino-dw1000

The modified DW1000 library is DW1000-20191218T032326Z-001.zip, the file Footstep.h has network setting that needs to be re-configured for the system

#define NETWORK_ID      	10\\
#define ANCHOR_NUM		  	1

#define TAG_NUM				    0

#define ANCHOR_ID_OFFSET    1

#define TAG_ID_OFFSET       10

#define RADIO_RESET_COUNT	10

## Localization through Vibration Sensing
