/************************************************************************
 *
 * ADAR7251_SPI.c
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

#include "ADAR7251_SPI.h"
#include "defADAR7251.h"

/*************************************************************************************************************************
									Include Files
 *************************************************************************************************************************/

/*************************************************************************************************************************
									Variables
 **************************************************************************************************************************/

/*************************************************************************************************************************
									Function Definitions
 **************************************************************************************************************************/
void Init_SPI_ADAR7251(void)
{
	*pREG_SPI1_CTL 	 = 0x00;
	*pREG_SPI1_RXCTL = 0x00;
	*pREG_SPI1_TXCTL = 0x00;

	*pREG_SPI1_CLK	 = 999 << BITP_SPI_CLK_BAUD;   // Baud rate of 1000
	*pREG_SPI1_DLY	 = (1 << BITP_SPI_DLY_LAGX  | 1<< BITP_SPI_DLY_LEADX | 0 << BITP_SPI_DLY_STOP);// 1 Delay in Lag, 1 Delay in Lead, No stop

	//*pREG_SPI1_SLVSEL= ENUM_SPI_SLVSEL_SSEL2_HI | ENUM_SPI_SLVSEL_SSEL2_EN;  // Slave select 2 enable

	*pREG_SPI1_CTL 	 = ENUM_SPI_CTL_MASTER | BITM_SPI_CTL_CPHA | BITM_SPI_CTL_CPOL | ENUM_SPI_CTL_SIZE08 | ENUM_SPI_CTL_SW_SSEL | ENUM_SPI_CTL_MSB_FIRST;
	//SPI1 set as master, clock phase from start, clock polarity 1, 1 byte mode, Software based slave selections, MSB first

	*pREG_SPI1_RXCTL = ENUM_SPI_RXCTL_OVERWRITE | ENUM_SPI_RXCTL_RX_EN;
	//rxctl set to overwrite on new data coming in and also enabled
	*pREG_SPI1_TXCTL = ENUM_SPI_TXCTL_TTI_EN | ENUM_SPI_TXCTL_TWC_EN | ENUM_SPI_TXCTL_ZERO | ENUM_SPI_TXCTL_TX_EN;
	//transmit transfer initiate is enabled , transmit word count is enabled to prevent underrun error
	//send zeroes when TxFIFO is empty

	*pREG_SPI1_CTL 	|= BITM_SPI_CTL_EN; // Enable SPI1 since now it is safe to enable
	delay_afe(0XFFFF);

	return;
}

void Init_ADAR7251(void)
{
	init_spi_pinmux();
	Init_SPI_ADAR7251();

	Access_ADAR7251(write_buffer_crc_disable,7,read_reg);
	delay_afe(0XFFFF);

	Access_ADAR7251(write_buffer_output,5,read_reg);
	delay_afe(0XFFFF);

	Access_ADAR7251(write_buffer_pll[0],5,read_reg); // CTRL
	delay_afe(0XFFFF);

	Access_ADAR7251(write_buffer_pll[2],5,read_reg); // DEN
	delay_afe(0XFFFF);

	Access_ADAR7251(write_buffer_pll[3],5,read_reg); // NUM
	delay_afe(0XFFFF);

	Access_ADAR7251(write_buffer_pll[1],5,read_reg);  // PLL_CTRL
	delay_afe(0XFFFF);

	// Wait PLL to lock
	do
	{
		Access_ADAR7251(read_buffer_input[0], 5,read_reg);
		delay_afe(0XFFFF);
	}	while(read_reg[4] != 0x01);

	// Write all the registers
	for (unsigned int i= 0; i < NUM_REGS_W; i++)
	{
		Access_ADAR7251(write_buffer[i], 5,read_reg);
	}

#ifdef DEBUG_READ_ADAR7251
	for (unsigned int i= 0; i < NUM_REGS_R; i++)
	{
		Access_ADAR7251(read_buffer[i], 5,read_reg_all[i]);
	}

	//Print the registers to the console
	for (int i = 0 ; i < NUM_REGS_R; i++)
	{
		if(DBG_PRINT) printf("Register address 0x%02x%02x is 0x%02x%02x \n", read_buffer[i][1],read_buffer[i][2], read_reg_all[i][3],read_reg_all[i][4]);
	}
#endif
	if(DBG_PRINT) printf("\nADAR7251 Initialization Done\n");

	return;
}

// Using GPIO to drive slave select low/high
void Access_ADAR7251(uint8_t Dataword[],unsigned int count,uint8_t read_data[])
{
	//*pREG_SPI0_SLVSEL &= ~BITM_SPI_SLVSEL_SSEL2;
	*pREG_PORTA_DATA_CLR = 1<< BITP_PORT_DIR_PX3;	// Used for asserting and deasserting slave
	//*pREG_PORTC_DATA_CLR =   1 << BITP_PORT_DIR_PX9;	// Used for asserting and deasserting slave

	for( unsigned i = 0 ; i < count; i++ )
	{
		read_data[i] = Init_SPI_Trasfer(Dataword[i]);
	}

//	*pREG_SPI0_SLVSEL |= BITM_SPI_SLVSEL_SSEL2;
	*pREG_PORTA_DATA_SET = 1<< BITP_PORT_DIR_PX3;
//	*pREG_PORTC_DATA_SET = 1  << BITP_PORT_DIR_PX9;
	return;
}

unsigned int Init_SPI_Trasfer(unsigned int Dataword)
{
	unsigned int Read_Data;

	while(!(*pREG_SPI1_STAT & BITM_SPI_STAT_RFE))		//	read RFIFO till it is empty
		Read_Data = *pREG_SPI1_RFIFO;

	Read_Data = 0;

	*pREG_SPI1_TWC	= 	1;								//	single byte instruction, no addr/data
	*pREG_SPI1_TFIFO = Dataword;						//	command ID
	while(!(*pREG_SPI1_STAT & BITM_SPI_STAT_TF));		//	wait till completion
	*pREG_SPI1_STAT = BITM_SPI_STAT_TF;					//	clear latch
	while(*pREG_SPI1_STAT & BITM_SPI_STAT_RFE);
	Read_Data =  *pREG_SPI1_RFIFO & 0XFF;

	return Read_Data;
}

void gpio_pb1_low(bool flag)
{
	if (flag == true)
	{
		// Enable PB01
		*pREG_PORTB_MUX &=  ~(BITM_PORT_MUX_MUX1);
		*pREG_PORTB_FER_CLR = (BITM_PORT_FER_SET_PX1); //  set PB01 in GPIO
		*pREG_PORTB_DIR_SET = BITM_PORT_DIR_SET_PX1;  // Set direction of PB01 to output
		*pREG_PORTB_DATA_CLR = BITM_PORT_DIR_SET_PX1; // Clear PB1
	}
	else
	{
		// Move  PB01 to Peripheral Mode
		*pREG_PORTB_MUX  |=  (BITM_PORT_MUX_MUX1);
		*pREG_PORTB_FER_SET = (BITM_PORT_FER_SET_PX1);
	}
	return;
}

/* Initialize the Port Control MUX and FER Registers */
void init_spi_pinmux(void)
{
	/* PORTx_MUX registers */
	*pREG_PORTA_MUX = SPI1_CLK_PORTA_MUX | SPI1_MISO_PORTA_MUX|SPI1_MOSI_PORTA_MUX;

	/* PORTx_FER registers */
	*pREG_PORTA_FER = SPI1_CLK_PORTA_FER | SPI1_MISO_PORTA_FER|SPI1_MOSI_PORTA_FER;

	//Port A direction and data set
	//*pREG_PORTC_DIR_SET =  1 << 9;	//Pin09  is in output mode for alternate adc slave selection
	//*pREG_PORTC_DATA_SET = 1 << BITP_PORT_DIR_PX9;	// Send 1 through P09 of Port C for slave
	*pREG_PORTA_DIR_SET = 1<< 3;	//Pin03  is in output mode for slave selection
	*pREG_PORTA_DATA_SET = 1<< BITP_PORT_DIR_PX3;	// Send 1 through P03 of Port A for slave

	return;
}

void delay_afe(unsigned int count)
{
	for (volatile unsigned int i = 0 ; i < count ; i++);
	return;
}

