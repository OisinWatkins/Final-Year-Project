/************************************************************************
 *
 * ADAR7251_SPI.h
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

#ifndef __ADAR7251_SPI_H__
#define __ADAR7251_SPI_H__

/*************************************************************************************************************************
									Include Files
 **************************************************************************************************************************/
#include <sys/platform.h>
#include <stdio.h>
#include "adi_initialize.h"
#include "UserConfig.h"

/*************************************************************************************************************************
									Macros
 **************************************************************************************************************************/
#define SPI1_CLK_PORTA_MUX	((uint16_t) ((uint16_t)  0<<0))	//PA0 - GPIO Function 0
#define SPI1_MISO_PORTA_MUX	((uint16_t) ((uint16_t)  0<<2))	//PA1 - GPIO Function 0
#define SPI1_MOSI_PORTA_MUX	((uint16_t) ((uint16_t)  0<<4))	//PA2 - GPIO Function 0
#define SPI1_SEL2_PORTA_MUX	((uint16_t) ((uint16_t)  0<<6))	//PA3 - GPIO Function 0

#define SPI1_CLK_PORTA_FER	((uint16_t) ((uint16_t) 1<<0))	//Enable PA0
#define SPI1_MISO_PORTA_FER	((uint16_t) ((uint16_t) 1<<1))	//Enable PA1
#define SPI1_MOSI_PORTA_FER	((uint16_t) ((uint16_t) 1<<2))	//Enable PA2
#define SPI1_SEL2_PORTA_FER	((uint16_t) ((uint16_t) 0<<3))	//Enable PA3

/*************************************************************************************************************************
									Function Declarations
**************************************************************************************************************************/
void init_spi_pinmux(void);
void Init_ADAR7251(void);
void Init_SPI_ADAR7251(void);
void Access_ADAR7251(uint8_t Dataword[],unsigned int count,uint8_t read_reg[]);
unsigned int Init_SPI_Trasfer(unsigned int Dataword);
void gpio_pb1_low(bool flag);
void delay_afe(unsigned int count);

#endif /* __ADAR7251_SPI_H__ */
