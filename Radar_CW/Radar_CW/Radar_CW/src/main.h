/*****************************************************************************
 *
 * main.h
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

#ifndef __MAIN_H__
#define __MAIN_H__

/*************************************************************************************************************************
									Include Files
**************************************************************************************************************************/
#include <sys/platform.h>
#include "adi_initialize.h"
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "time.h"

#include "UserConfig.h"
#include "memory.h"
#include "cld_bulk_interface.h"
#include "ADAR7251_SPI_quad.h"
#include "ADAR7251_SPI.h"
#include "MDMA_FFT.h"
#include "MMIC.h"
#include "CGUInit.h"

/*************************************************************************************************************************
									Function Declarations
**************************************************************************************************************************/
void Initialize_buffer(void);
void reInit_system( signed short *SPIDataBuf );

/*************************************************************************************************************************
									MACROS Internal
**************************************************************************************************************************/

#define MSEL_DIV 16 // 48*8= 384 //25*16= 400
#define DF_DIV 0
#define CSEL_DIV  1 // CCLK = 384 //400
#define DSEL_DIV 4 // 25*16= 400/4 = 100MHz  */
#define S0SEL_DIV 2 // SCLK0 = SYSCLK/2 =100
#define S1SEL_DIV 2 // SCLK1= SYSCLK/2 =100
#define SYSSEL_DIV 2 // 384/2 =200
#define OSEL_DIV  10

// Macros for Clk out
#define CLKIN               0
#define CCLK_BY_16          1
#define SYSCLK_BY_8         2
#define SCLK0_BY_8          3
#define SCLK1_BY_8          4
#define DCLK_BY_8           5
#define USBCLK              6
#define OUTCLK              7
#define USB_CLKIN           8
#define WOCLK               9
#define PMON                10
#define GND                 11
#define FRO                 13
#define RTC                 14
#define RCU_SYSRES          15

#endif /* __MAIN_H__ */
