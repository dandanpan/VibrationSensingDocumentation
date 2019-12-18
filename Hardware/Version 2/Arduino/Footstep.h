/*
 * Footstep project
 */

#ifndef _FOOTSTEP
#define _FOOTSTEP

// messages used in the ranging protocol
#define POLL 				0
#define POLL_ACK 		  	1
#define RANGE 			  	2
#define RANGE_REPORT 	  	3
#define GRANT_TOKEN		    4
#define TOKEN_RELEASE		5
#define RESET_NETWORK		6
#define SYNC_REQ			7
#define SYNC_ACK			8
#define RANGE_FAILED 	  	255

// base station status
#define	BS_IDLE				0
#define BS_WAIT_FOR_TAG		1
#define BS_TAG_TIMEOUT		2 
#define BS_WAIT_FOR_ANCHOR	3
#define BS_ANCHOR_TIMEOUT	4
#define BS_MOVING_ON		5
#define BS_TAG_RESET_COUNT	6
#define BS_INTERVAL			800

// anchor status
#define ANCHOR_INTERVAL		50

// tag status
#define TAG_IDLE			0
#define TAG_WAIT_FOR_ANCHOR 1
#define TAG_INTERVAL		500 

// conditions
#define ANCHOR_DIED			1
#define TAG_DIED			2

// board parameters
#define ADCPIN 				A1
#define RESET_PIN         	9
#define CS_PIN            	10
#define IRQ_PIN           	2
#define CLOCK_RATE        	48000000
#define SAMPLE_RATE       	10000
#define BUFFER_SIZE       	256
#define TSIZE             	5
#define CONTROL_SIZE	  	5 
#define SEPARATOR_SIZE    	2
#define LEN_DATA          	123 // MSG_TYPE, DEVICE_ID, TO_DEVICE, TOKEN, RELEASE_TOKEN, TIMESTAMP_NUM*TIMESTAMP_LEN
#define LEN_ACC_DATA		120 //112 // 120, save 8 bytes for start and stop timestamps

////// change with the useExtendedFrameLength in DW1000.cpp
// #define LEN_DATA          	123 // MSG_TYPE, DEVICE_ID, TO_DEVICE, TOKEN, RELEASE_TOKEN, TIMESTAMP_NUM*TIMESTAMP_LEN
// #define LEN_ACC_DATA		112 

// network setting
#define NETWORK_ID      	10
#define ANCHOR_NUM		  	1
#define TAG_NUM				0//2 
#define ANCHOR_ID_OFFSET    1
#define TAG_ID_OFFSET       10
#define RADIO_RESET_COUNT	10

#endif