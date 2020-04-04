/************************************************************************
 *
 * MDMA_FFT.h
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

#ifndef __MDMA_FFT_H__
#define __MDMA_FFT_H__

/*************************************************************************************************************************
									Include Files
**************************************************************************************************************************/
#include <sys/platform.h>
#include <string.h>
#include "UserConfig.h"
#include "debug.h"
#include "memory.h"
#include <window.h>
#include <filter.h>
#include <vector.h>

/*************************************************************************************************************************
									Macros
**************************************************************************************************************************/


/*************************************************************************************************************************
									Function Declarations
**************************************************************************************************************************/
void FFT_init(void);
void Perform2DFFTCube(signed short*buff_L2);
void ConfigureMDMA1RowsXfer(void);
void ConfigureMDMA1ColsXfer(void);
void StartMDMA1Transfer(short* src, short* dest);
void WaitMDMA1DstDone(void);
void ConfigureMDMA2RowsXfer(void);
void ConfigureMDMA2ColsXfer(void);
void StartMDMA2Transfer(short* src, short* dest);
void WaitMDMA2DstDone(void);

#endif /* __MDMA_FFT_H__ */
