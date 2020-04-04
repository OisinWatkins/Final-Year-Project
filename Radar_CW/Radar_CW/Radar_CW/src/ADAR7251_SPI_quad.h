/*
 * ADAR7251_SPI_quad.h
 *
 *  Created on: May 31, 2016
 *      Author: tbaruah
 */

#ifndef __ADAR7251_SPI_QUAD_H__
#define __ADAR7251_SPI_QUAD_H__

#include <ccblkfn.h>
#include <sys/exception.h>
#include <services/int/adi_int.h>
#include <stdio.h>
#include <sysreg.h>
#include "UserConfig.h"
#include <services/gpio/adi_gpio.h>

/*************************************************************************************************************************
									Macros
**************************************************************************************************************************/

#define SPI_DMA_CFG_STOP	ENUM_DMA_CFG_STOP|ENUM_DMA_CFG_EN| ENUM_DMA_CFG_WRITE | ENUM_DMA_CFG_XCNT_INT| ENUM_DMA_CFG_PSIZE01 |ENUM_DMA_CFG_MSIZE01 |ENUM_DMA_CFG_SYNC

//#define SPI_DMA_CFG_STOP_2D ENUM_DMA_CFG_STOP|ENUM_DMA_CFG_EN| ENUM_DMA_CFG_WRITE | ENUM_DMA_CFG_YCNT_INT| ENUM_DMA_CFG_PSIZE01 |ENUM_DMA_CFG_MSIZE01 |ENUM_DMA_CFG_SYNC|ENUM_DMA_CFG_ADDR2D
#define SPI_DMA_CFG_STOP_2D			ENUM_DMA_CFG_STOP|ENUM_DMA_CFG_EN| ENUM_DMA_CFG_WRITE | ENUM_DMA_CFG_YCNT_INT| ENUM_DMA_CFG_PSIZE02 |ENUM_DMA_CFG_MSIZE02 |ENUM_DMA_CFG_SYNC|ENUM_DMA_CFG_ADDR2D
#define SPI_DMA_CFG_STOP_2D_UPDATE	ENUM_DMA_CFG_STOP| ENUM_DMA_CFG_WRITE | ENUM_DMA_CFG_YCNT_INT| ENUM_DMA_CFG_PSIZE02 |ENUM_DMA_CFG_MSIZE02 |ENUM_DMA_CFG_SYNC|ENUM_DMA_CFG_ADDR2D
#define SPI_DMA_CFG_DESC			ENUM_DMA_CFG_DSCLIST|	ENUM_DMA_CFG_FETCH07|	ENUM_DMA_CFG_WRITE|	ENUM_DMA_CFG_XCNT_INT|	ENUM_DMA_CFG_PSIZE02|	ENUM_DMA_CFG_MSIZE02|	ENUM_DMA_CFG_SYNC

/*---------------------------------------------SPI MUX settings-----------------------------------------------*/
#define SPI0_CLK_PORTB_MUX	((uint16_t) ((uint16_t) 1<<1))	//2nd bit set to 1
#define SPI0_MISO_PORTB_MUX	((uint16_t) ((uint16_t) 1<<3))	//4th bit set to 1
#define SPI0_MOSI_PORTB_MUX	((uint16_t) ((uint16_t) 1<<5))	//6th bit set to 1
#define SPI0_D2_PORTB_MUX	((uint16_t) ((uint16_t) 1<<7))	//8th bit to 1
#define SPI0_D3_PORTB_MUX	((uint16_t) ((uint16_t) 1<<15))	//16th bit to 1

//#define SPI0_SEL1_PORTA_MUX  ((uint16_t) ((uint16_t) 1<<10))	// 1: Should be driven by hardware
#define TM0_TMR1_PORTA_MUX   ((uint16_t) ((uint16_t) 0<<12))

//Function enable on Port B at pins 0 , 1 , 2 , 3, 7
#define SPI0_CLK_PORTB_FER	((uint16_t) ((uint16_t) 1<<0))
#define SPI0_MISO_PORTB_FER	((uint16_t) ((uint16_t) 1<<1))
#define SPI0_MOSI_PORTB_FER	((uint16_t) ((uint16_t) 1<<2))
#define SPI0_D2_PORTB_FER	((uint16_t) ((uint16_t) 1<<3))
#define SPI0_D3_PORTB_FER    ((uint16_t) ((uint16_t) 1<<7))

//#define SPI0_SEL1_PORTA_FER  ((uint16_t) ((uint16_t) 1<<5))	// 1: Should be driven by hardware
#define TM0_TMR1_PORTA_FER  ((uint16_t) ((uint16_t) 1<<6))

/*  Convert start PWM Timer configuration */
#define  CONVERT_WIDTH  (unsigned int)((BUFFER_SIZE_IN_BYTES*SCLK0_FREQ)/ADC_FS_MBPS)
#define  CONVERT_PERIOD	10 + CONVERT_WIDTH // One shot mode so it does not matter just 1 + width is fine
#define  CONVERT_DELAY  (unsigned int)((INITIAL_SKIP*2*NO_CHANNEL*SCLK0_FREQ)/ADC_FS_MBPS)  // Programmable delay width

/*************************************************************************************************************************
									Function Declarations
**************************************************************************************************************************/
void init_spi_data_pinmux(void);
void SPI_data_init(void);
void Start_DataXfer(void);
void spi_data_done(void);
int send_conv_start_SPI(void);

#ifdef DEBUG_SPI
	//This function initializes the DMA channel for corresponding SPI
	void SPI_DMANormal_Config(void);
#else
	//This function initializes the DMA channel for corresponding SPI
	void SPI_DMA_stopMode_Config(void);
	void SPI_DMA_stopMode_2DConfig(void);
	void SPI_DMA_stopMode_2DConfig_Update(signed short *SPIDataBuf, unsigned int RAMP_ENABLE);
#endif

// This function acts as ISR for  SPI0 DMA channel completion interrupt
void SPI0_Interrupt_Handler(uint32_t iid, void* handlerArg);

#define GPIO_MEMORY_SIZE (ADI_GPIO_CALLBACK_MEM_SIZE*2)
static uint8_t gpioMemory[GPIO_MEMORY_SIZE];

#endif /* __ADAR7251_SPI_QUAD_H__ */
