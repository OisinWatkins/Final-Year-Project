/*
 * memory.h
 *
 *  Created on: May 4, 2016
 *      Author: lliu4
 */

#ifndef __MEMORY_H__
#define __MEMORY_H__

#include <stdfix.h>
#include <fract.h>

extern fract16 buff_L1_rfft_in[];
extern complex_fract16 buff_L1_cfft_in[];
extern complex_fract16 buff_L1_rfft_out[];
extern complex_fract16 buff_L1_cfft_out[];

extern signed short PingBuffer[];
extern signed short PongBuffer[];

extern fract16 window_rfft[];
extern complex_fract16 window_cfft[];
extern complex_fract16 twiddles_rfft[];
extern complex_fract16 twiddles_cfft[];

#endif /* __MEMORY_H__ */
