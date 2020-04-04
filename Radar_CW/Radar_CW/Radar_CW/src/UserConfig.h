/************************************************************************
 *
 * UserConfig.h
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

#ifndef __USERCONFIG_H__
#define __USERCONFIG_H__

/*************************************************************************************************************************
									Macros
**************************************************************************************************************************/
#define DEBUG
#ifdef DEBUG
	#include "debug.h"
#endif


#define DBG_PRINT 1 // 0-Disable Printf, 1-Enable Printf


/* Do Not Change below parameters*/

// No of Data Cubes
#define INFINITE_CUBES
#ifndef INFINITE_CUBES
	#define NUM_DATA_CUBES 10 // Can be from 1 to 2^31-1
#endif

//#define ENABLE_BF70x_FFT  // If defined FFT is done on BF70x

#define OUTPUT_TIME_DOMAIN //Output Time domain data
//#define OUTPUT_FREQ_DOMAIN //Output Time domain data

//#define  CONV2DRDY_DELAY 1215
#define  CONV2DRDY_DELAY 500	//ADAR7251 ConvertStart to DataReady delay

#define  EXTRA_A4RAMP_END 20 //Initial Non-linear part of Up-ramp
#define  EXTRA_B4RAMP_END 7 //No of Samples in Down-ramp + Final Non-linear part of Up-ramp

#define	 NUM_FMCW_CUBES	10
#define	 NUM_CW_CUBES	5

#define  ADC_FS_MBPS  8 //In MBps; 8MBps = (1 Msps * 4 Channels * 2 Bytes)
#define  SCLK0_FREQ  100.00 //In MHz

#define  NO_ROWS 128	// Number of ramps per chirp
#define  NO_COLS 256	// Number of samples per ramp (in terms of short int)
#define  NO_CHANNEL 4	// No of Rx/ADC channels

#define  INITIAL_SKIP EXTRA_A4RAMP_END
#define  BETWEEN_RAMP_SKIP  (EXTRA_B4RAMP_END + EXTRA_A4RAMP_END) //Total extra samples per ramp period

#define  BUFFER_SIZE_IN_SAMPLES	(NO_ROWS*(NO_COLS+EXTRA_B4RAMP_END+EXTRA_A4RAMP_END)*NO_CHANNEL) // Each Sample is 2 Bytes
#define  BUFFER_SIZE_IN_BYTES	(BUFFER_SIZE_IN_SAMPLES*2) // Each Sample is 2 Bytes

#define  BUFUOT_SIZE_IN_BYTES	(NO_ROWS*NO_COLS*NO_CHANNEL*4/2)//Used by USB; 4 because of real imaginary; divide by 2 because of 128 Row truncation
//#define BUFIN_SIZE_IN_SAMPLES   (NO_ROWS*NO_COLS*NO_CHANNEL) + (BETWEEN_RAMP_SKIP*NO_CHANNEL) // Used by SPI DMA after data trim. Each Sample is 2 Bytes
#define  BUFIN_SIZE_IN_SAMPLES   (NO_ROWS*NO_COLS*NO_CHANNEL)  // Used by SPI DMA after data trim. Each Sample is 2 Bytes

#define  FFT_UNIT NO_COLS // assuming NO_ROWS < NO_COLS

#endif /* __USERCONFIG_H__ */
