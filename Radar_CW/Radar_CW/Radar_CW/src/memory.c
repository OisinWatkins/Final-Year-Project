/*
 * memory.c
 *
 *  Created on: May 4, 2016
 *      Author: lliu4
 */

#include "UserConfig.h"
#include "memory.h"

// L1 Buffers
#pragma align 4*FFT_UNIT
section("L1_data_a") fract16 buff_L1_rfft_in[NO_COLS];
#pragma align 4*FFT_UNIT
section("L1_data_a") complex_fract16 buff_L1_cfft_in[NO_ROWS];

#pragma align 4*FFT_UNIT
section("L1_data_b") complex_fract16 buff_L1_rfft_out[NO_COLS];
#pragma align 4*FFT_UNIT
section("L1_data_b") complex_fract16 buff_L1_cfft_out[NO_ROWS];


// Ping-Pong Data in different L2 Banks as per LDF
#ifdef TRIM_DATA_SW
//section("ping_data")  signed short PingBuffer[BUFFER_SIZE_IN_SAMPLES];
//section("pong_data")  signed short PongBuffer[BUFFER_SIZE_IN_SAMPLES];
#else // TRIM_DATA_SW
#pragma align 16
section("ping_data")  signed short PingBuffer[BUFIN_SIZE_IN_SAMPLES];

#pragma align 16
section("pong_data")  signed short PongBuffer[BUFIN_SIZE_IN_SAMPLES];
#endif // TRIM_DATA_SW

// SPI DMA descriptors
unsigned int PingBuffer_Desc[7];
unsigned int PongBuffer_Desc[7];

// Aligned to 4*FFT_UNIT for FFT implementation
#pragma align 4*FFT_UNIT
section ("L1_data_a") fract16 window_rfft[NO_COLS];

#pragma align 4*FFT_UNIT
section ("L1_data_a") complex_fract16 window_cfft[NO_ROWS];

#pragma align 4
section ("L1_data_c") complex_fract16 twiddles_rfft[3*NO_COLS/4];

#pragma align 4
section ("L1_data_c") complex_fract16 twiddles_cfft[3*NO_ROWS/4];
