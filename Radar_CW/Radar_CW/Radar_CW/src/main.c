/************************************************************************
 *
 * main.c
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

/*************************************************************************************************************************
									Include Files
*************************************************************************************************************************/
#include "main.h"

/*************************************************************************************************************************
									 Global Variables
**************************************************************************************************************************/


/*************************************************************************************************************************
									Function Definitions
**************************************************************************************************************************/

/** 
 * If you want to use command program arguments, then place them in the following string. 
 */
char __argv_string[] = "";
unsigned int count = 0; //  - Number of Cubes collected

int main(int argc, char *argv[])
{
	void *PrevBuffer;		//  - Previous buffer pointer with SPI data
	void *CurrBuffer;		//  - Current buffer pointer being updated with SPI data
	void *Temp;             //  - Swap Pointer

	int i =0;
	adi_initComponents();

	CGU_Init_All(MSEL_DIV,DF_DIV,CSEL_DIV,DSEL_DIV,S0SEL_DIV,S1SEL_DIV,SYSSEL_DIV,OSEL_DIV,CLKIN);

#ifdef ENABLE_BF70x_FFT
	// Initialize FFT (Windows and Twiddle factors)
	FFT_init();
#endif

#ifndef DEBUG_DISABLE_MMIC
	Init_MMIC(); // Configure RX,TX,PLL (Ramp Disabled)
#endif

#ifndef DEBUG_DISABLE_ADAR7251
	Init_ADAR7251(); // Configure AFE
	SPI_data_init();
#endif

#if (defined (OUTPUT_BEAMFORM) || defined (OUTPUT_TIME_DOMAIN) || defined(OUTPUT_FREQ_DOMAIN)) & !defined (DEBUG_DISABLE_USB)
	if(DBG_PRINT) printf("\nWaiting for USB Initialization\n");
	bulk_usb_init(BUFUOT_SIZE_IN_BYTES); //  - The USB stack will block until the board is plugged into a host, and first USB command is sent from host
#endif

	//Init_ADF4159_RampEn(1); //Enable Ramp (FMCW output with upramp and downramp)
	Start_DataXfer(); //Start Data Receive

#ifdef DEBUG_INITBUFF
     Initialize_buffer();
#endif

#ifdef DEBUG_HALT_B4_PROCESS
   while(1);
#endif

	// Initialize Ping-pong buffer
	PrevBuffer = PingBuffer;
	CurrBuffer = PongBuffer;

#ifdef INFINITE_CUBES
	while(1)
#else
	while( count < NUM_DATA_CUBES)
#endif
	{
#ifndef DEBUG_DISABLE_ADAR7251
		// Collect SPI_Data
		spi_data_done();
#endif

#if !defined(DEBUG_DISABLE_USB) & defined(OUTPUT_TIME_DOMAIN)
		// USB Transfer Time Domain Data
		bulk_usb_write_block( PrevBuffer, BUFUOT_SIZE_IN_BYTES );
#endif

#if defined (ENABLE_BF70x_FFT)
		Perform2DFFTCube( PrevBuffer );
#endif


#ifdef ENABLE_BF70x_FFT
#if !defined(DEBUG_DISABLE_USB) & defined(OUTPUT_FREQ_DOMAIN)
		bulk_usb_write_nonblock( PrevBuffer, BUFUOT_SIZE_IN_BYTES );
#endif
#endif

		Temp = PrevBuffer;				//  - Swap ping pong buffers
		PrevBuffer = CurrBuffer;		//  - Swap ping pong buffers
		CurrBuffer = Temp;				//  - Swap ping pong buffers

		// NUM_DATA_BLKS
		count++;
	}

	return 0;
}

void reInit_system( signed short *SPIDataBuf )
{
	if(count < NUM_FMCW_CUBES)
		Init_ADF4159_RampDis(1); // Disable Ramp
	else if(count < (NUM_FMCW_CUBES+NUM_CW_CUBES))
		Init_ADF4159_RampDis(0); // Disable Ramp - Virtual

	// Disable SPI
	*pREG_SPI0_CTL  &= ~ENUM_SPI_CTL_EN;

	//Initialize SPI DMA
	if((count < (NUM_FMCW_CUBES-1)) || (count == (NUM_FMCW_CUBES+NUM_CW_CUBES-1)))
		SPI_DMA_stopMode_2DConfig_Update(SPIDataBuf,1); //FMCW DMA config
	else if(count < (NUM_FMCW_CUBES+NUM_CW_CUBES-1))
		SPI_DMA_stopMode_2DConfig_Update(SPIDataBuf,0); //CW DMA config

	// Re-Enable the SPI DMA
	*pREG_DMA5_CFG |= ENUM_DMA_CFG_EN;

	// Enable SPI
	*pREG_SPI0_CTL |= ENUM_SPI_CTL_EN;

	// Clear the Latch for the RampSync-> PINT2-> TIMER7_OUT(CONV_START)
	*pREG_PINT2_LATCH = BITM_PINT_EDGE_CLR_PIQ7;

	if((count < (NUM_FMCW_CUBES-1)) || (count == (NUM_FMCW_CUBES+NUM_CW_CUBES-1)))
		Init_ADF4159_RampEn(1); //Enable Ramp
	else if(count < (NUM_FMCW_CUBES+NUM_CW_CUBES-1))
		Init_ADF4159_RampEn(0); //Enable Ramp - Virtual

	return;
}

#define pi 3.14159
void Initialize_buffer(void)
{
	unsigned int i;
	unsigned int ChannelNo = 0;
	for( i = 0 ; i < (BUFFER_SIZE_IN_SAMPLES/4) ; i++ )
	{
		for( ChannelNo = 0 ; ChannelNo < 4 ; ChannelNo++ )
		{
			PingBuffer[4*i+ChannelNo] = 1000.0 * sin(2.0*pi*i*10.0/256.0);
			PongBuffer[4*i+ChannelNo] = 1000.0 * sin(2.0*pi*i*10.0/256.0);
		}
	}
	return;
}
