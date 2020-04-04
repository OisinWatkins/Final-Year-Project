/*****************************************************************************
 * MDMA_FFT.c
 *****************************************************************************/

/*************************************************************************************************************************
									Include Files
**************************************************************************************************************************/
#include "MDMA_FFT.h"

/*************************************************************************************************************************
									Variables
**************************************************************************************************************************/


/*************************************************************************************************************************
									Function Definitions
**************************************************************************************************************************/
void FFT_init(void)
{
	// Generate Hanning windows for FFTs
	gen_hanning_fr16(window_rfft, 1, NO_COLS);
	gen_hanning_fr16((fract16*)window_cfft, 2, NO_ROWS); // window_stride=2 skips imaginary part
	for( unsigned int i = 0 ; i < NO_ROWS ; i++ ) // Initialize imaginary part with zero
		window_cfft[i].im = 0;

	// Generate Twiddle factors for FFTs
	twidfftf_fr16(twiddles_rfft, NO_COLS);
	twidfftf_fr16(twiddles_cfft, NO_ROWS);

	return;
}

// Perform 2D FFT on Row and Column Data
// Output data format - short buff_L2[NO_ROWS][NO_COLS/2][Ch1.re, Ch2.re, Ch3.re, Ch4.re, Ch1.img, Ch2.img, Ch3.img, Ch4.img]
// Note: Fixed-point FFT needs scaling, and only static-scaling is allowed for FMCW applications
void Perform2DFFTCube(signed short* buff_L2)
{
	short* SrcAddr;
	short* DestAddr;
	unsigned int rowid,colid,chid;
	int block_expnt;

	ConfigureMDMA1RowsXfer(); //L2 to L1 transfer row-wise
	ConfigureMDMA2RowsXfer(); //L1 to L2 transfer row-wise

	for( chid = 0 ; chid < NO_CHANNEL ; chid++ )
	{
		for( rowid = 0 ; rowid < NO_ROWS ; rowid++ )
		{
			SrcAddr = (short *)(buff_L2 + (chid + rowid*NO_CHANNEL*NO_COLS));
			DestAddr = (short *)buff_L1_rfft_in;
			StartMDMA1Transfer(SrcAddr,DestAddr);
			WaitMDMA1DstDone();

			vecvmlt_fr16(buff_L1_rfft_in, window_rfft, buff_L1_rfft_in, NO_COLS); //Apply Window to input
			rfft_fr16(buff_L1_rfft_in, buff_L1_rfft_out, twiddles_rfft, 1, NO_COLS, &block_expnt, 1 /*static scaling*/); //Calculate Range FFT

			SrcAddr = (short *)buff_L1_rfft_out;
			DestAddr = (short *)(buff_L2 + (chid + rowid*NO_CHANNEL*NO_COLS));
			StartMDMA2Transfer(SrcAddr,DestAddr);
			WaitMDMA2DstDone();
		}
	}

	ConfigureMDMA1ColsXfer(); //L2 to L1 transfer column-wise
	ConfigureMDMA2ColsXfer(); //L1 to L2 transfer column-wise

	for( chid = 0 ; chid < NO_CHANNEL ; chid++ )
	{
		for( colid = 0 ; colid < NO_COLS/2 ; colid++ )
		{
			SrcAddr = (short *)(buff_L2 + (chid + 2*colid*NO_CHANNEL));
			DestAddr = (short *)buff_L1_cfft_in;
			StartMDMA1Transfer(SrcAddr,DestAddr);
			WaitMDMA1DstDone();

			cvecvmlt_fr16(buff_L1_cfft_in, window_cfft, buff_L1_cfft_in, NO_ROWS); //Apply Window to input
			cfft_fr16(buff_L1_cfft_in, buff_L1_cfft_out, twiddles_cfft, 1, NO_ROWS, &block_expnt, 1 /*static scaling*/); //Calculate Doppler FFT

			SrcAddr = (short *)buff_L1_cfft_out;
			DestAddr = (short *)(buff_L2 + (chid + 2*colid*NO_CHANNEL));
			StartMDMA2Transfer(SrcAddr,DestAddr);
			WaitMDMA2DstDone();
		}
	}

	return;
}

void ConfigureMDMA1RowsXfer(void)
{
	// Disable MDMA1 Channels
	*pREG_DMA18_CFG = 0;
	*pREG_DMA19_CFG = 0;

	// Source MDMA Channel 1
	// configure source registers
	*pREG_DMA18_CFG  = (ENUM_DMA_CFG_READ | ENUM_DMA_CFG_MSIZE02 | ENUM_DMA_CFG_PSIZE02 | ENUM_DMA_CFG_STOP | ENUM_DMA_CFG_ADDR1D | ENUM_DMA_CFG_SYNC);
	*pREG_DMA18_XCNT = NO_COLS; // NO_COLS samples each channel, 2 bytes each sample
	*pREG_DMA18_XMOD = NO_CHANNEL*2; // XCNT increment in bytes

	// Destination MDMA Channel 1
	// configure destination registers
	*pREG_DMA19_CFG  = (ENUM_DMA_CFG_WRITE | ENUM_DMA_CFG_XCNT_INT | ENUM_DMA_CFG_MSIZE02 | ENUM_DMA_CFG_PSIZE02 | ENUM_DMA_CFG_STOP | ENUM_DMA_CFG_ADDR1D);
	*pREG_DMA19_XCNT = NO_COLS; // NO_COLS samples each channel, 2 bytes each sample
	*pREG_DMA19_XMOD = 2; // XCNT increment in bytes

	return;
}

void ConfigureMDMA1ColsXfer(void)
{
	// Disable MDMA1 Channels
	*pREG_DMA18_CFG = 0;
	*pREG_DMA19_CFG = 0;

	// Source MDMA Channel 1
	// configure source registers
	*pREG_DMA18_CFG  = (ENUM_DMA_CFG_READ | ENUM_DMA_CFG_MSIZE02 | ENUM_DMA_CFG_PSIZE02 | ENUM_DMA_CFG_STOP | ENUM_DMA_CFG_ADDR2D | ENUM_DMA_CFG_SYNC);
	*pREG_DMA18_XCNT = 2; // Real and Imaginary sample from each row of each channel, 2 bytes each sample
	*pREG_DMA18_XMOD = NO_CHANNEL*2; // XCNT increment in bytes
	*pREG_DMA18_YCNT = NO_ROWS; // NO_ROWS rows from each channel
	*pREG_DMA18_YMOD = NO_CHANNEL*2*(NO_COLS-1); // YCNT increment in bytes

	// Destination MDMA Channel 1
	// configure destination registers
	*pREG_DMA19_CFG  = (ENUM_DMA_CFG_WRITE | ENUM_DMA_CFG_XCNT_INT | ENUM_DMA_CFG_MSIZE02 | ENUM_DMA_CFG_PSIZE02 | ENUM_DMA_CFG_STOP | ENUM_DMA_CFG_ADDR1D);
	*pREG_DMA19_XCNT = NO_ROWS*2; // NO_ROWS Real and Imaginary samples each channel, 2 bytes each sample
	*pREG_DMA19_XMOD = 2; // XCNT increment in bytes

	return;
}

#pragma inline
void StartMDMA1Transfer(short* src, short* dest)
{
	*pREG_DMA18_ADDRSTART = src;
	*pREG_DMA19_ADDRSTART = dest;

	// Enable MDMA1 Channels
	*pREG_DMA18_CFG |= ENUM_DMA_CFG_EN ;
	*pREG_DMA19_CFG |= ENUM_DMA_CFG_EN ;

	return;
}

#pragma inline
void WaitMDMA1DstDone(void)
{
	while(*pREG_DMA19_STAT & BITM_DMA_STAT_RUN);
	return;
}

void ConfigureMDMA2RowsXfer(void)
{
	// Disable MDMA2 Channels
	*pREG_DMA20_CFG = 0;
	*pREG_DMA21_CFG = 0;

	// Source MDMA Channel 2
	// configure source registers
	*pREG_DMA20_CFG  = (ENUM_DMA_CFG_READ | ENUM_DMA_CFG_MSIZE02 | ENUM_DMA_CFG_PSIZE02 | ENUM_DMA_CFG_STOP | ENUM_DMA_CFG_ADDR1D | ENUM_DMA_CFG_SYNC);
	*pREG_DMA20_XCNT = NO_COLS; // Discard 2nd-half of FFT points; NO_COLS/2 Real and Imaginary samples each channel, 2 bytes each sample
	*pREG_DMA20_XMOD = 2; // XCNT increment in bytes

	// Destination MDMA Channel 2
	// configure destination registers
	*pREG_DMA21_CFG  = (ENUM_DMA_CFG_WRITE | ENUM_DMA_CFG_XCNT_INT | ENUM_DMA_CFG_MSIZE02 | ENUM_DMA_CFG_PSIZE02 | ENUM_DMA_CFG_STOP | ENUM_DMA_CFG_ADDR1D);
	*pREG_DMA21_XCNT = NO_COLS; // NO_COLS/2 Real and Imaginary samples each channel, 2 bytes each sample
	*pREG_DMA21_XMOD = NO_CHANNEL*2; // XCNT increment in bytes

	return;
}

void ConfigureMDMA2ColsXfer(void)
{
	// Disable MDMA2 Channels
	*pREG_DMA20_CFG = 0;
	*pREG_DMA21_CFG = 0;

	// Source MDMA Channel 2
	// configure source registers
	*pREG_DMA20_CFG  = (ENUM_DMA_CFG_READ | ENUM_DMA_CFG_MSIZE02 | ENUM_DMA_CFG_PSIZE02 | ENUM_DMA_CFG_STOP | ENUM_DMA_CFG_ADDR1D | ENUM_DMA_CFG_SYNC);
	*pREG_DMA20_XCNT = NO_ROWS*2; // NO_ROWS Real and Imaginary samples each channel, 2 bytes each sample
	*pREG_DMA20_XMOD = 2; // XCNT increment in bytes

	// Destination MDMA Channel 2
	// configure destination registers
	*pREG_DMA21_CFG  = (ENUM_DMA_CFG_WRITE | ENUM_DMA_CFG_YCNT_INT | ENUM_DMA_CFG_MSIZE02 | ENUM_DMA_CFG_PSIZE02 | ENUM_DMA_CFG_STOP | ENUM_DMA_CFG_ADDR2D);
	*pREG_DMA21_XCNT = 2; // Real and Imaginary sample from each row of each channel, 2 bytes each sample
	*pREG_DMA21_XMOD = NO_CHANNEL*2; // XCNT increment in bytes
	*pREG_DMA21_YCNT = NO_ROWS; // NO_ROWS rows from each channel
	*pREG_DMA21_YMOD = NO_CHANNEL*2*(NO_COLS-1); // YCNT increment in bytes

	return;
}

#pragma inline
void StartMDMA2Transfer(short* src, short* dest)
{
	*pREG_DMA20_ADDRSTART = src;
	*pREG_DMA21_ADDRSTART = dest;

	*pREG_DMA20_CFG |= ENUM_DMA_CFG_EN ;
	*pREG_DMA21_CFG |= ENUM_DMA_CFG_EN ;

	return;
}

#pragma inline
void WaitMDMA2DstDone(void)
{
	while(*pREG_DMA21_STAT & BITM_DMA_STAT_RUN);
	return;
}
