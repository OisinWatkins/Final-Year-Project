/************************************************************************
 *
 * ADF5901.c
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

/*************************************************************************************************************************
									Include Files
*************************************************************************************************************************/
#include "defADF5901.h"
#include "MMIC.h"

/*************************************************************************************************************************
									Function Definitions
**************************************************************************************************************************/

/***********************************************************************************************************************************************************
*	Function name	:	Init_ADF5901
*	Description		:	This function initializes the ADF5901 Tx using the Init Sequence given defADF5901.h file.
*	Parameter		:	None.
*	Return value	:	None.
*************************************************************************************************************************************************************/
void Init_ADF5901(void)
{
	unsigned int Result;
	int REG_COUNT=0;

	*pREG_PORTC_DATA_SET =  BITM_PORT_DATA_SET_PX10;	//	set both CE_Tx and LE_Tx pins to high
	Init_MMIC_SPI();									//	configure SPI in 32-bit mode

   	for( REG_COUNT = 0 ; REG_COUNT < sizeof(adf5901_init_sequence_values)/4 ; REG_COUNT++ )
   	{
		Result = Write_ADF5901_REG(adf5901_init_sequence_values[REG_COUNT]);	//	initiates register write operations
		delay_mmic(0XFFFF);
		if(Result != 1)
		{
			printf("\nError Writing the ADF5901 Register\n");	//	readback register result didn't match
			while(1)
				asm("nop;");
		}
   	}
   	if(DBG_PRINT) printf("\nADF5901 Initialization Done\n");

#ifdef DEBUG_READ_AD5901
	unsigned int REG_BUFF[12];	//	optionally read back all registers if required
	Read_ALL_REGS_ADF5901(REG_BUFF);
	for( int i = 0 ; i < 12 ; i++ )
		if(DBG_PRINT) printf("TX :Dataword = %08x, Read_Data = %08x\n",i,REG_BUFF[i]);
#endif
	// Disable SPI
	*pREG_SPI1_CTL = 0x00;	*pREG_SPI1_RXCTL = 0x00;	*pREG_SPI1_TXCTL = 0x00;
	return;
}

/****************************************************************************************************************************************************************
*	Function name	:	Write_ADF5901_REG
*	Description		:	This function performs 32-bit write operation to ADF5901 register.
*						It asserts the slave select signal and then initiates 32-bit transfer. Finally it de-asserts slave select line.
*						After writing to register, it can perform verify operation, if READBACK_REGISTERS_WHILE_PROGRAMMING macro in debug.h file is uncommented.
*	Parameter		:	Register value to be written (32-bit)
*	Return value	:	Result of comparison if READBACK_REGISTERS_WHILE_PROGRAMMING macro is commented:  0-not matched	1-matched
*						1: if READBACK_REGISTERS_WHILE_PROGRAMMING macro is commented
******************************************************************************************************************************************************************/
unsigned int Write_ADF5901_REG(unsigned int Dataword)
{
	unsigned int Read_Data, Result;

	// Write register
	Select_Slave_ADF5901();
	Read_Data = Init_32bit_SPI_Trasfer(Dataword);
	Deselect_Slave_ADF5901();

#ifdef READBACK_REGISTERS_WHILE_PROGRAMMING
	// Read back it's value
	Read_Data = Read_ADF5901_REG(Dataword & 0x1F);
	if(DBG_PRINT) printf("TX :Dataword = %08x, Read_Data = %08x\n",Dataword,Read_Data);
	// Read_Data1[count++] = Read_Data;

	if((Dataword & 0x1F) == 7)
			return 1;				//	This is double buffer register..contents cannot be verified unless R5 is written
	else if((Dataword & 0x1F) == 3)
		Read_Data &= 0xFFFFF81F;	//	Reg3 sets the Register. So, cannot be read. Field should be masked.

	if(Read_Data != Dataword)
	{
		if((Dataword & 0x1F) == 0)	//	Somehow reserved bit#31 of R0 is reading back 0 instead of 1. So, need to mask this condition
		{
			if(Read_Data == (Dataword & 0x7FFFFFFF))
				Result = 1;
			else
				Result = 0;
		}
		else
			Result = 0;
	}
	else
		Result = 1;

	return Result;
#else
	return 1;
#endif
}

/****************************************************************************************************************************************************************
*	Function name	:	Read_ADF5901_REG
*	Description		:	This is a helper function. It asserts the slave select signal and then initiates 32-bit transfer. Finally it de-asserts slave select line.
*						Two transfers are need to readback register. First will set register address and next will perform actual read access
*	Parameter		:	Register value to be written (32-bit)
*	Return value	:	Register value read (32-bit)
******************************************************************************************************************************************************************/
unsigned int Read_ADF5901_REG(unsigned int Dataword)
{
	unsigned int Read_Data;
	Select_Slave_ADF5901();
	Init_32bit_SPI_Trasfer(0x01890803 | ((Dataword+1) << 5));
	Deselect_Slave_ADF5901();

	Select_Slave_ADF5901();
	Read_Data = Init_32bit_SPI_Trasfer(0x01890803);
	Deselect_Slave_ADF5901();

	printf("Data word %04x \n", Dataword);
	return Read_Data;
}

/*****************************************************************************************************************************************************************
*	Function name	:	Select_Slave_ADF5901
*	Description		:	This is a helper function. It asserts the slave select signal of ADF5901 i.e. LE_Tx. This is GPIO5 -> PC10 pin
*	Parameter		:	None.
*	Return value	:	None.
******************************************************************************************************************************************************************/
void Select_Slave_ADF5901(void)
{
	*pREG_PORTC_DATA_CLR = BITM_PORT_DATA_CLR_PX10;
	delay_mmic(0XF);
	return;
}

/******************************************************************************************************************************************************************
*	Function name	:	Deselect_Slave_ADF5901
*	Description		:	This is a helper function. It de-asserts the slave select signal of ADF5901 i.e. LE_Tx. This is GPIO5 -> PC10 pin
*	Parameter		:	None.
*	Return value	:	None.
********************************************************************************************************************************************************************/
void Deselect_Slave_ADF5901(void)
{
	*pREG_PORTC_DATA_SET = BITM_PORT_DATA_SET_PX10;
	delay_mmic(0XFF);
	return;
}

/*****************************************************************************************************************************************************************
*	Function name	:	Read_ALL_REGS_ADF5901
*	Description		:	This function reads all the registers of ADF5901.
*	Parameter		:	Pointer to Array. The Array should be 12 x 32-bit, if all registers needs to be read.
*	Return value	:	The Array would be updated to readback values of registers.
******************************************************************************************************************************************************************/
void Read_ALL_REGS_ADF5901(unsigned int* pREG_BUFF)
{
	*pREG_BUFF++ = Read_ADF5901_REG(0);
	*pREG_BUFF++ = Read_ADF5901_REG(1);
	*pREG_BUFF++ = Read_ADF5901_REG(2);
	*pREG_BUFF++ = Read_ADF5901_REG(3);
	*pREG_BUFF++ = Read_ADF5901_REG(4);
	*pREG_BUFF++ = Read_ADF5901_REG(5);
	*pREG_BUFF++ = Read_ADF5901_REG(6);
	*pREG_BUFF++ = Read_ADF5901_REG(7);
	*pREG_BUFF++ = Read_ADF5901_REG(8);
	*pREG_BUFF++ = Read_ADF5901_REG(9);
	*pREG_BUFF++ = Read_ADF5901_REG(10);
	*pREG_BUFF++ = Read_ADF5901_REG(11);
	return;
}

/*******************************************************************************************************************************************************************/
