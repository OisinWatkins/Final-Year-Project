/************************************************************************
 *
 * MMIC.h
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

#ifndef __MMIC_H__
#define __MMIC_H__

/*************************************************************************************************************************
									Include Files
**************************************************************************************************************************/
#include <sys/platform.h>
#include "stdio.h"
#include "UserConfig.h"

/*************************************************************************************************************************
									Macros
**************************************************************************************************************************/


/*************************************************************************************************************************
									Function Declarations
**************************************************************************************************************************/
void Init_MMIC(void);
void Init_MMIC_SPI(void);
void Init_Pin_Mux(void);
unsigned int Init_32bit_SPI_Trasfer(unsigned int Dataword);

void Init_ADF5901(void);
unsigned int Write_ADF5901_REG(unsigned int Dataword);
unsigned int Read_ADF5901_REG(unsigned int Dataword);
void Select_Slave_ADF5901(void);
void Deselect_Slave_ADF5901(void);
void Read_ALL_REGS_ADF5901(unsigned int* pREG_BUFF);

void Init_ADF5904(void);
unsigned int Write_ADF5904_REG(unsigned int Dataword);
unsigned int Read_ADF5904_REG(unsigned int Dataword);
void Select_Slave_ADF5904(void);
void Deselect_Slave_ADF5904(void);
void Read_ALL_REGS_ADF5904(unsigned int* pREG_BUFF);

void Init_ADF4159(void);
void Init_ADF4159_RampEn(unsigned int RAMP_ENABLE);
void Init_ADF4159_RampDis(unsigned int RAMP_ENABLE);
void Write_ADF4159_REG(unsigned int Dataword);
void Select_Slave_ADF4159(void);
void Deselect_Slave_ADF4159(void);

void delay_mmic(unsigned int count);

#endif /* __MMIC_H__ */
