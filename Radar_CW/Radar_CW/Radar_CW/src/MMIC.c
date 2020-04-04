/************************************************************************
 *
 * MMIC.c
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

/*************************************************************************************************************************
									Include Files
*************************************************************************************************************************/
#include "MMIC.h"
#include "ADAR7251_SPI.h"

/*************************************************************************************************************************
									Function Definitions
**************************************************************************************************************************/
void Init_MMIC(void)
{
	Init_Pin_Mux();
	Init_ADF5904(); // Rx
	Init_ADF4159(); // PLL - without ramp enabled
	Init_ADF5901(); // TX
	return;
}

/***********************************************************************************************************************************************************
*	Function name	:	Init_Pin_Mux
*	Description		:	This function initializes the SPI pins and GPIO's needed to control CE and LE pins of ADF5901, ADF5904 and ADF4159
*	Parameter		:	None.
*	Return value	:	None.
*************************************************************************************************************************************************************/
void Init_Pin_Mux(void)
{
	// Initialize SPI Pins
	// SPI1_CLK: PA_00, SPI1_MOSI: PA_02, SPI1_MISO: PA_01
    *pREG_PORTA_MUX = SPI1_CLK_PORTA_MUX | SPI1_MISO_PORTA_MUX | SPI1_MOSI_PORTA_MUX;
    *pREG_PORTA_FER_SET = (SPI1_CLK_PORTA_FER | SPI1_MISO_PORTA_FER | SPI1_MOSI_PORTA_FER);

	// LE_Rx (PA_14) used to control ADF5904 Receiver
   	*pREG_PORTA_FER_CLR  =  BITM_PORT_FER_CLR_PX14;
   	*pREG_PORTA_DIR_SET  =  BITM_PORT_DIR_SET_PX14;
   	*pREG_PORTA_DATA_SET =  BITM_PORT_DATA_SET_PX14;

	// LE_Tx (PC_10) used to control ADF5901 Transmitter
   	*pREG_PORTC_FER_CLR  = BITM_PORT_FER_CLR_PX10   ;
   	*pREG_PORTC_DIR_SET  = BITM_PORT_DIR_SET_PX10   ;
   	*pREG_PORTC_DATA_SET = BITM_PORT_DATA_SET_PX10 ;

   	// LE_PLL (PA_04) used to control ADF4159 PLL
   	*pREG_PORTA_FER_CLR  = BITM_PORT_FER_CLR_PX4   ;
   	*pREG_PORTA_DIR_SET  = BITM_PORT_DIR_SET_PX4   ;
   	*pREG_PORTA_DATA_SET = BITM_PORT_DATA_SET_PX4  ;

   	return;
}

/***********************************************************************************************************************************************************
*	Function name	:	Init_MMIC_SPI
*	Description		:	This function initializes the SPI in 32-bit mode.
*	Parameter		:	None.
*	Return value	:	None.
*************************************************************************************************************************************************************/
void Init_MMIC_SPI(void)
{
	*pREG_SPI1_CTL = 0x00;	*pREG_SPI1_RXCTL = 0x00;	*pREG_SPI1_TXCTL = 0x00;

	*pREG_SPI1_CLK = 24;	*pREG_SPI1_DLY = 0x301;
//	*pREG_SPI0_SLVSEL= ENUM_SPI_SLVSEL_SSEL4_HI | ENUM_SPI_SLVSEL_SSEL4_EN | ENUM_SPI_SLVSEL_SSEL5_HI | ENUM_SPI_SLVSEL_SSEL5_EN; // SSLE4 Not Used as Slave Select
	*pREG_SPI1_CTL 	 = ENUM_SPI_CTL_MASTER /*| ENUM_SPI_CTL_SCKBEG | ENUM_SPI_CTL_SCKLO*/ | ENUM_SPI_CTL_SIZE32 | ENUM_SPI_CTL_SW_SSEL | ENUM_SPI_CTL_MSB_FIRST;
	*pREG_SPI1_RXCTL = ENUM_SPI_RXCTL_OVERWRITE | ENUM_SPI_RXCTL_RX_EN;
	*pREG_SPI1_TXCTL = ENUM_SPI_TXCTL_TTI_EN | ENUM_SPI_TXCTL_TWC_EN | ENUM_SPI_TXCTL_ZERO | ENUM_SPI_TXCTL_TX_EN;
	*pREG_SPI1_CTL 	|= BITM_SPI_CTL_EN;

	delay_mmic(0xFF);
	return;
}

/***********************************************************************************************************************************************************
*	Function name	:	Init_32bit_SPI_Trasfer
*	Description		:	This function can be used to write the register or can be used to readback the register. It performs single 32-bit access (R/W)
*	Parameter		:	Register value to be written (32-bit)
*	Return value	:	Register value read (32-bit)
*************************************************************************************************************************************************************/
unsigned int Init_32bit_SPI_Trasfer(unsigned int Dataword)
{
	unsigned int Read_Data, temp;
	while(!(*pREG_SPI1_STAT & BITM_SPI_STAT_RFE))		//	read RFIFO till it is empty
		temp = *pREG_SPI1_RFIFO;

	*pREG_SPI1_TWC	= 	1;								//	single byte instruction, no addr/data
	*pREG_SPI1_TFIFO = Dataword;						//	command ID
	while(!(*pREG_SPI1_STAT & BITM_SPI_STAT_TF));		//	wait till completion
	*pREG_SPI1_STAT = BITM_SPI_STAT_TF;					//	clear latch
	while(*pREG_SPI1_STAT & BITM_SPI_STAT_RFE);
	Read_Data =  *pREG_SPI1_RFIFO;

	return Read_Data;
}

void delay_mmic(unsigned int count)
{
	for (volatile unsigned int i = 0 ; i < count ; i++);
	return;
}

/*************************************************************************************************************************************************************/
