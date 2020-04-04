/************************************************************************
 *
 * ADF4159.c
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

/*************************************************************************************************************************
									Include Files
*************************************************************************************************************************/
#include "defADF4159.h"
#include "MMIC.h"
#include <time.h>

/*************************************************************************************************************************
									Function Definitions
**************************************************************************************************************************/

/*************************************************************************************************************************
*	Function name	:	Init_ADF4159
*	Description		:	This function initializes the ADF4159 PLL using the Init Sequence given defADF4159.h file
*	Parameter		:	None.
*   Return value	:	None.
**************************************************************************************************************************/
void Init_ADF4159(void)
{
   	*pREG_PORTA_DATA_SET = BITM_PORT_DATA_SET_PX4;	//	set the Slave select pin (LE_PLL) High. Will be driven low while configuring registers
   	Init_MMIC_SPI();								//	Configure SPI in 32-bit mode

   	for( int REG_COUNT = 0 ; REG_COUNT < (sizeof(adf4159_init_sequence_values)/4) ; REG_COUNT++ )	//	Initialize the sequence ADF4159
   	{
		Write_ADF4159_REG(adf4159_init_sequence_values[REG_COUNT]);
	    delay_mmic(0XFFFF);
   	}

   	if(DBG_PRINT) printf("\nADF4159 Initialization Done\n");

   	// Disable SPI
	*pREG_SPI1_CTL = 0x00;	*pREG_SPI1_RXCTL = 0x00;	*pREG_SPI1_TXCTL = 0x00;
	return;
}

void Init_ADF4159_RampEn(unsigned int RAMP_ENABLE)
{
#ifndef DEBUG_RAMP_DISABLE
	if(RAMP_ENABLE)
	{
		*pREG_PORTA_DATA_SET = BITM_PORT_DATA_SET_PX4;	//	set the Slave select pin (LE_PLL) High. Will be driven low while configuring registers
		Init_MMIC_SPI();								//	Configure SPI in 32-bit mode

		Write_ADF4159_REG(adf4159_init_ramp_en);

		// Disable SPI
		*pREG_SPI1_CTL = 0x00;	*pREG_SPI1_RXCTL = 0x00;	*pREG_SPI1_TXCTL = 0x00;

		if(DBG_PRINT) printf("\nADF4159 Ramp Enabled\n");
	}
	else
	{
		//*pREG_TIMER0_TMR7_CFG &= ~ENUM_TIMER_TMR_CFG_TRIGSTART;
		*pREG_TRU0_MTR = TRGM_PINT2_BLOCK;
		if(DBG_PRINT) printf("\nADF4159 Virtual Ramp Enabled\n");
	}
#else
	//*pREG_TIMER0_TMR7_CFG &= ~ENUM_TIMER_TMR_CFG_TRIGSTART;
	*pREG_TRU0_MTR = TRGM_PINT2_BLOCK;
	if(DBG_PRINT) printf("\nADF4159 Virtual Ramp Enabled\n");
#endif

	return;
}

void Init_ADF4159_RampDis(unsigned int RAMP_ENABLE)
{
#ifndef DEBUG_RAMP_DISABLE
	if(RAMP_ENABLE)
	{
		*pREG_PORTA_DATA_SET = BITM_PORT_DATA_SET_PX4;	//	set the Slave select pin (LE_PLL) High. Will be driven low while configuring registers
		Init_MMIC_SPI();								//	Configure SPI in 32-bit mode

		Write_ADF4159_REG(adf4159_init_ramp_dis);

		// Disable SPI
		*pREG_SPI1_CTL = 0x00;	*pREG_SPI1_RXCTL = 0x00;	*pREG_SPI1_TXCTL = 0x00;

		if(DBG_PRINT) printf("\nADF4159 Ramp Disabled\n");
	}
	else
	{
		if(DBG_PRINT) printf("\nADF4159 Virtual Ramp Disabled\n");
	}
#else
	if(DBG_PRINT) printf("\nADF4159 Virtual Ramp Disabled\n");
#endif
	return;
}

/****************************************************************************************************************************************************************
*	Function name	:	Write_ADF4159_REG
*	Description		:	This is a helper function. It asserts the slave select signal and then initiates 32-bit transfer. Finally it de-asserts slave select line.
*	Parameter		:	Register value to be written (32-bit)
*   Return value	:	None.
******************************************************************************************************************************************************************/
void Write_ADF4159_REG(unsigned int Dataword)
{
	unsigned int Read_Data, Result;
	// Write register
	Select_Slave_ADF4159();
	Read_Data = Init_32bit_SPI_Trasfer(Dataword);
	Deselect_Slave_ADF4159();
	return;
}

/*****************************************************************************************************************************************************************
*	Function name	:	Select_Slave_ADF4159
*	Description		:	This is a helper function. It asserts the slave select signal of ADF4159 i.e. LE_PLL.
*	Parameter		:	None.
*   Return value	:	None.
******************************************************************************************************************************************************************/
void Select_Slave_ADF4159(void)
{
	*pREG_PORTA_DATA_CLR = BITM_PORT_DATA_CLR_PX4;
	 delay_mmic(0XF);
	 return;
}

/******************************************************************************************************************************************************************
*	Function name	:	Deselect_Slave_ADF4159
*	Description		:	This is a helper function. It de-asserts the slave select signal of ADF4159 i.e. LE_PLL.
*	Parameter		:	None.
*   Return value	:	None.
********************************************************************************************************************************************************************/
void Deselect_Slave_ADF4159(void)
{
	*pREG_PORTA_DATA_SET = BITM_PORT_DATA_SET_PX4;
	 delay_mmic(0XFF);
	 return;
}

/*******************************************************************************************************************************************************************/
