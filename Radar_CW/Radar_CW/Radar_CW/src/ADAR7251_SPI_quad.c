/*
 * ADAR7251_SPI_quad.c
 *
 *  Created on: May 31, 2016
 *      Author: tbaruah
 */

#include "ADAR7251_SPI_quad.h"
#include <services/gpio/adi_gpio.h>

volatile bool SPI_DATA=false;

// Ping-Pong Data in different L2 Banks as per LDF (configured in UserConfig.h)
#ifdef TRIM_DATA_SW
extern  signed short PingBuffer[BUFFER_SIZE_IN_SAMPLES];
extern  signed short PongBuffer[BUFFER_SIZE_IN_SAMPLES];
#else
extern  signed short PingBuffer[BUFIN_SIZE_IN_SAMPLES];
extern  signed short PongBuffer[BUFIN_SIZE_IN_SAMPLES];
#endif

// SPI DMA descriptors
extern unsigned int PingBuffer_Desc[7];
extern unsigned int PongBuffer_Desc[7];

void SPI_data_init(void)
{
	init_spi_data_pinmux();
	/*
#ifndef TRIM_DATA_SW
	// Configure SPI DMA registers.
	SPI_DMA_stopMode_2DConfig();
#else
	// Configure SPI DMA registers.
	SPI_DMA_stopMode_Config();
#endif
	*/
	SPI_DMA_DescMode_Config();

	*pREG_SPI0_CTL = 0x00;
	*pREG_SPI0_RXCTL = 0x00;
	*pREG_SPI0_TXCTL = 0x00;

	//Configure System event controllers
	*pREG_SEC0_GCTL=ENUM_SEC_GCTL_EN;
	*pREG_SEC0_CCTL0=ENUM_SEC_CCTL_EN;

	//Configure SPI Control registers here
	// Slave, 16 bits, MSB first, Quad bit mode.
	*pREG_SPI0_CTL = ENUM_SPI_CTL_SLAVE | ENUM_SPI_CTL_SIZE16 | ENUM_SPI_CTL_MSB_FIRST
			         |ENUM_SPI_CTL_MIO_QUAD| ENUM_SPI_CTL_STMISO  ;
	*pREG_SPI0_RXCTL = ENUM_SPI_RXCTL_OVERWRITE  |ENUM_SPI_RXCTL_RDR_50  | ENUM_SPI_RXCTL_RX_EN;	// Overwrite and enable receive

	//Install the ISR for SPIO DMA Interrupt
	adi_int_InstallHandler(INTR_SPI0_RXDMA, SPI0_Interrupt_Handler,NULL, true );

	//Enable SPI0 for transfer
	*pREG_SPI0_CTL |= ENUM_SPI_CTL_EN;

	// Enable SPI DMA
	*pREG_DMA5_CFG |= ENUM_DMA_CFG_EN;

	return;
}

void Start_DataXfer(void)
{
	//Enable ADC Convert Start
	*pREG_PORTA_FER_CLR = BITM_PORT_FER_CLR_PX6;
	*pREG_PORTA_DIR_SET = BITM_PORT_DIR_SET_PX6;
	*pREG_PORTA_DATA_CLR = BITM_PORT_DATA_CLR_PX6;
	return;
}

void init_spi_data_pinmux(void)
{
	*pREG_PORTA_MUX |=TM0_TMR1_PORTA_MUX;
	*pREG_PORTB_MUX |= SPI0_CLK_PORTB_MUX | SPI0_MISO_PORTB_MUX |SPI0_MOSI_PORTB_MUX | SPI0_D2_PORTB_MUX | SPI0_D3_PORTB_MUX;
	*pREG_PORTA_FER |= TM0_TMR1_PORTA_FER;
	*pREG_PORTB_FER |= SPI0_CLK_PORTB_FER | SPI0_MISO_PORTB_FER |SPI0_MOSI_PORTB_FER | SPI0_D2_PORTB_FER | SPI0_D3_PORTB_FER;
	return;
}

void SPI_DMA_stopMode_Config(void)
{
	*pREG_DMA5_ADDRSTART= PingBuffer;				//Initialize start address
	*pREG_DMA5_XCNT		= BUFFER_SIZE_IN_SAMPLES;	//Initialize X count
	*pREG_DMA5_XMOD		= 1;						//Initialize DMA X modifier
	*pREG_DMA5_YCNT		= 0;						//Initialize Y count
	*pREG_DMA5_YMOD		= 0;						//Initialize DMA Y modifier
	*pREG_DMA5_CFG		= SPI_DMA_CFG_STOP;			//Initialize DMA config register
	return;
}

void SPI_DMA_stopMode_2DConfig(void)
{
	*pREG_DMA5_ADDRSTART= PingBuffer;							//Initialize start address
	*pREG_DMA5_XCNT		= BUFFER_SIZE_IN_SAMPLES/NO_ROWS;		//Initialize X count
	*pREG_DMA5_XMOD		= 2;									//Initialize DMA X modifier
	*pREG_DMA5_YCNT		= NO_ROWS;								//Initialize Y count
	*pREG_DMA5_YMOD		= 2 - BETWEEN_RAMP_SKIP*NO_CHANNEL*2;	//Initialize DMA Y modifier
	*pREG_DMA5_CFG		= SPI_DMA_CFG_STOP_2D;					//Initialize DMA config register
	return;
}

// SPI DMA Configuration - Ping-Pong Descriptors
void SPI_DMA_DescMode_Config(void)
{
	PingBuffer_Desc[0] = (unsigned int)PongBuffer_Desc;
	PingBuffer_Desc[1] = (unsigned int)PingBuffer;
	PingBuffer_Desc[2] = SPI_DMA_CFG_DESC | ENUM_DMA_CFG_EN;
	PingBuffer_Desc[3] = BUFIN_SIZE_IN_SAMPLES;
	PingBuffer_Desc[4] = 2;
	PingBuffer_Desc[5] = 0;
	PingBuffer_Desc[6] = 0;

	PongBuffer_Desc[0] = (unsigned int)PingBuffer_Desc;
	PongBuffer_Desc[1] = (unsigned int)PongBuffer;
	PongBuffer_Desc[2] = SPI_DMA_CFG_DESC | ENUM_DMA_CFG_EN;
	PongBuffer_Desc[3] = BUFIN_SIZE_IN_SAMPLES;
	PongBuffer_Desc[4] = 2;
	PongBuffer_Desc[5] = 0;
	PongBuffer_Desc[6] = 0;

	*pREG_DMA5_DSCPTR_NXT	= (unsigned int)PingBuffer_Desc;
	*pREG_DMA5_ADDRSTART	= (unsigned int)PingBuffer;		//Initialize start address
	*pREG_DMA5_XCNT			= BUFIN_SIZE_IN_SAMPLES;		//Initialize X count
	*pREG_DMA5_XMOD			= 2;			//Initialize DMA X modifier
	*pREG_DMA5_YCNT			= 0;			//Initialize Y count
	*pREG_DMA5_YMOD			= 0;			//Initialize DMA Y modifier
	*pREG_DMA5_CFG			= SPI_DMA_CFG_DESC;		//Initialize DMA config register

	return;
}

void SPI_DMA_stopMode_2DConfig_Update(signed short *SPIDataBuf, unsigned int RAMP_ENABLE)
{
	*pREG_DMA5_ADDRSTART= SPIDataBuf;							//Initialize start address

	if(RAMP_ENABLE)
			*pREG_DMA5_XCNT	= BUFFER_SIZE_IN_SAMPLES/NO_ROWS;	//Initialize X count
	else
			*pREG_DMA5_XCNT	= BUFIN_SIZE_IN_SAMPLES/NO_ROWS;	//Initialize X count

	*pREG_DMA5_XMOD		= 2;									//Initialize DMA X modifier
	*pREG_DMA5_YCNT		= NO_ROWS;								//Initialize Y count

	if(RAMP_ENABLE)
		*pREG_DMA5_YMOD	= 2 - BETWEEN_RAMP_SKIP*NO_CHANNEL*2;	//Initialize DMA Y modifier
	else
		*pREG_DMA5_YMOD	= 2;									//Initialize DMA Y modifier

	*pREG_DMA5_CFG		= SPI_DMA_CFG_STOP_2D_UPDATE;					//Initialize DMA config register

	return;
}

int send_conv_start_SPI(void)
{
	// Configure PA1 for ramp
	*pREG_PORTA_FER |= 0 << BITP_PORT_FER_PX7;		// Set it as GPIO
	*pREG_PORTA_DIR |= 0 << BITP_PORT_FER_PX7;		// Set it as input
	*pREG_PORTA_INEN |= 1 << BITP_PORT_INEN_PX7;	// Enable input
	*pREG_PORTA_POL_SET = 1 << BITP_PORT_INEN_PX7;  // Set it for polarity inversion

	*pREG_PINT2_ASSIGN |= BITM_PINT_ASSIGN_B0MAP;			// Byte0 map selected for pint2
	*pREG_PINT2_MSK_SET |= 1 << BITP_PINT_MSK_SET_PIQ7;		// Select Pin 1 on Port A
	*pREG_PINT2_EDGE_SET |= 1 << BITP_PINT_EDGE_SET_PIQ7;	// Set edge based triggering on that pin
	*pREG_PINT2_INV_SET |= 1 << BITP_PINT_INV_SET_PIQ7;		// Enables inversion

	// Configure TIMER01 in MODE with START on Trigger
	*pREG_TIMER0_TMR1_CFG = BITM_TIMER_TMR_CFG_EMURUN|ENUM_TIMER_TMR_CFG_CLKSEL_SCLK| ENUM_TIMER_TMR_CFG_TRIGSTART|ENUM_TIMER_TMR_CFG_PWMSING_MODE;
	*pREG_TIMER0_TMR1_PER = CONVERT_PERIOD+ CONV2DRDY_DELAY;
	*pREG_TIMER0_TMR1_WID = CONVERT_WIDTH + CONV2DRDY_DELAY;
	*pREG_TIMER0_TMR1_DLY = CONVERT_DELAY;

	*pREG_TIMER0_TRG_IE |= BITM_TIMER_TRG_IE_TMR01;

	/* Enable the TRU */
	*pREG_TRU0_GCTL |= 0x1;

	/* Configure Timer0 slave to receive trigger from PINT2 master */
	*pREG_TRU0_SSR3 = TRGM_PINT2_BLOCK;

	return 0;
}

void SPI0_Interrupt_Handler(uint32_t iid, void* handlerArg)
{
	*pREG_DMA5_STAT |= ENUM_DMA_STAT_IRQDONE;	//Clear the W1C interrupt status bit
	SPI_DATA = true;
	return;
}

void spi_data_done(void) // Wait till SPI transfer done
{
	while(SPI_DATA == false);
	SPI_DATA = false;
	return;
}
