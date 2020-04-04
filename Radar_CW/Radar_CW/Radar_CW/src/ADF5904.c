/************************************************************************
 *
 * ADF5904.c
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

/*************************************************************************************************************************
									Include Files
*************************************************************************************************************************/
#include "defADF5904.h"
#include "MMIC.h"

/*************************************************************************************************************************
									Function Definitions
**************************************************************************************************************************/

/***********************************************************************************************************************************************************
*	Function name	:	Init_ADF5904
*	Description		:	This function initializes the ADF5904 Rx using the Init Sequence given defADF5904.h file.
*	Parameter		:	None.
*	Return value	:	None.
*************************************************************************************************************************************************************/
void Init_ADF5904(void)
{
	unsigned int Result;

	//Corrected
   	*pREG_PORTA_DATA_SET =  BITM_PORT_DATA_SET_PX14;	//	set both CE_Rx and LE_Rx pins to high
   	Init_MMIC_SPI();									//	configure SPI in 32-bit mode

   	for( int REG_COUNT=0 ; REG_COUNT < (sizeof(adf5904_init_sequence_values)/4) ; REG_COUNT++ )
   	{
		Result = Write_ADF5904_REG(adf5904_init_sequence_values[REG_COUNT]);	//	initiates register write operations
		delay_mmic(0XFFF);
		if(Result != 1)
		{
			if(DBG_PRINT) printf("\nError Writing the ADF5904 Register\n");		//	readback register result didn't match
			while(1)
				asm("nop;");
		}
   	}
   	if(DBG_PRINT) printf("\nADF5904 Initialization Done\n");

#ifdef DEBUG_READ_AD5904
	unsigned int REG_BUFF[6];
	Read_ALL_REGS_ADF5904(REG_BUFF);	//	optionally read back all registers if required
   	for ( int i = 0 ; i < 6 ; i++ )
   		if(DBG_PRINT) printf("RX :Dataword = %08x, Read_Data = %08x\n",i,REG_BUFF[i]);
#endif

   	// Disable SPI
	*pREG_SPI1_CTL = 0x00;	*pREG_SPI1_RXCTL = 0x00;	*pREG_SPI1_TXCTL = 0x00;

	return;
}

/****************************************************************************************************************************************************************
*	Function name	:	Write_ADF5904_REG
*	Description		:	This function performs 32-bit write operation to ADF5904 register.
*						It asserts the slave select signal and then initiates 32-bit transfer. Finally it de-asserts slave select line.
*						After writing to register, it can perform verify operation, if READBACK_REGISTERS_WHILE_PROGRAMMING macro in debug.h file is uncommented.
*	Parameter		:	Register value to be written (32-bit)
*	Return value	:	Result of comparison if READBACK_REGISTERS_WHILE_PROGRAMMING macro is commented:  0-not matched	1-matched
*   					1: if READBACK_REGISTERS_WHILE_PROGRAMMING macro is commented
******************************************************************************************************************************************************************/
unsigned int Write_ADF5904_REG(unsigned int Dataword)
{
	unsigned int Read_Data, Result;

	// Write register
	Select_Slave_ADF5904();
	Read_Data = Init_32bit_SPI_Trasfer(Dataword);
	Deselect_Slave_ADF5904();

#ifdef READBACK_REGISTERS_WHILE_PROGRAMMING
	//	Read back register value
	if((Dataword & 0x3) == 0)		//Readback R0
		Read_Data = Read_ADF5904_REG(0x00020006 | (16 << 10));
	else if((Dataword & 0x3) == 1)	//Readback R1
	{
		if(((Dataword & 0xE0000000) >> 29 == 1))
			Read_Data = Read_ADF5904_REG(0x00020006 | (17 << 10));
		else if(((Dataword & 0xE0000000) >> 29 == 2))
			Read_Data = Read_ADF5904_REG(0x00020006 | (18 << 10));
		else if(((Dataword & 0xE0000000) >> 29 == 3))
			Read_Data = Read_ADF5904_REG(0x00020006 | (19 << 10));
		else if(((Dataword & 0xE0000000) >> 29 == 4))
			Read_Data = Read_ADF5904_REG(0x00020006 | (20 << 10));
		else if(((Dataword & 0xE0000000) >> 29 == 5))
			Read_Data = Read_ADF5904_REG(0x00020006 | (21 << 10));
	}
	/*else if((Dataword & 0x3) == 2 )//Readback R2 - Pointless as we write "read command" into R2 again
	{
			Read_Data = Read_ADF5904_REG(0x00020006 | (22 << 10));
	}*/
	else	//R3 is reserved
	{
		return 1;
	}

	if(DBG_PRINT) printf("Rx : Dataword = %08x, Read_Data = %08x\n",Dataword,Read_Data);
	if(Read_Data != Dataword)
		Result = 0;
	else
		Result = 1;

	return Result;
#else
	return 1;
#endif
}

/****************************************************************************************************************************************************************
*	Function name	:	Read_ADF5904_REG
*	Description		:	This is a helper function. It asserts the slave select signal and then initiates 32-bit transfer. Finally it de-asserts slave select line.
*						Two transfers are need to readback register. First will set register address and next will perform actual read access
*	Parameter		:	Register value to be written (32-bit)
*	Return value	:	Register value read (32-bit)
******************************************************************************************************************************************************************/
unsigned int Read_ADF5904_REG(unsigned int Dataword)
{
	unsigned int Read_Data;
	Select_Slave_ADF5904();
	Init_32bit_SPI_Trasfer(Dataword);
	Deselect_Slave_ADF5904();

	Select_Slave_ADF5904();
	Read_Data = Init_32bit_SPI_Trasfer(0x00020006);
	Deselect_Slave_ADF5904();

	printf("Data word %04x \n", Dataword);
	return Read_Data;
}

/*****************************************************************************************************************************************************************
*	Function name	:	Select_Slave_ADF5904
*	Description		:	This is a helper function. It asserts the slave select signal of  ADF5904 i.e. LE_Rx. This is GPIO2 -> PA14 pin
*	Parameter		:	None.
*	Return value	:	None.
******************************************************************************************************************************************************************/
void Select_Slave_ADF5904(void)
{
	*pREG_PORTA_DATA_CLR = BITM_PORT_DATA_CLR_PX14;
	delay_mmic(0XF);
	return;
}

/******************************************************************************************************************************************************************
*	Function name	:	Deselect_Slave_ADF5904
*	Description		:	This is a helper function. It de-asserts the slave select signal of ADF5904 i.e. LE_Rx. This is GPIO2 -> PA14 pin
*	Parameter		:	None.
*	Return value	:	None.
********************************************************************************************************************************************************************/
void Deselect_Slave_ADF5904(void)
{
	//Incorrect because of pin configs
	*pREG_PORTA_DATA_SET = BITM_PORT_DATA_SET_PX14;
	delay_mmic(0XFF);
	return;
}

/*****************************************************************************************************************************************************************
*	Function name	:	Read_ALL_REGS_ADF5904
*	Description		:	This function reads all the registers of ADF5904.
*	Parameter		:	Pointer to Array. The Array should be 12 x 32-bit, if all registers needs to be read.
*	Return value	:	The Array would be updated to readback values of registers.
******************************************************************************************************************************************************************/
void Read_ALL_REGS_ADF5904(unsigned int* pREG_BUFF)
{
	*pREG_BUFF++ = Read_ADF5904_REG(0x00020006 | (16 << 10));
	*pREG_BUFF++ = Read_ADF5904_REG(0x00020006 | (17 << 10));
	*pREG_BUFF++ = Read_ADF5904_REG(0x00020006 | (18 << 10));
	*pREG_BUFF++ = Read_ADF5904_REG(0x00020006 | (19 << 10));
	*pREG_BUFF++ = Read_ADF5904_REG(0x00020006 | (20 << 10));
	*pREG_BUFF++ = Read_ADF5904_REG(0x00020006 | (21 << 10));
	return;
}

/*******************************************************************************************************************************************************************/
