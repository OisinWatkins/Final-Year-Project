/*
** adi_initialize.c source file generated on July 13, 2017 at 15:56:32.
**
** Copyright (C) 2000-2017 Analog Devices Inc., All Rights Reserved.
**
** This file is generated automatically. You should not modify this source file,
** as your changes will be lost if this source file is re-generated.
*/

#include <sys/platform.h>
#include <services/int/adi_sec.h>

#include "adi_initialize.h"

#ifdef __ADI_USE_UTILITY_ROM /* check if Utility ROM support is enabled */

#ifndef NO_UTILITY_ROM_LIBDRV

/**
* By default, Utility ROM support includes drivers. To exclude drivers, define the pre-processor macro
* NO_UTILITY_ROM_LIBDRV in "CrossCore Blackfin C/C++ Compiler: Preprocessor: Preprocessor definitions (-D)"
* and "CrossCore Blackfin Linker: Preprocessor: Preprocessor definitions (-MD)".
*/

#include <services/rom/adi_rom.h>
#include <drivers/rom/adi_rom.h>

#endif /* NO_UTILITY_ROM_LIBDRV */

#endif /* __ADI_USE_UTILITY_ROM */

extern int32_t adi_initpinmux(void);

int32_t adi_initComponents(void)
{
	int32_t result = 0;

	result = adi_sec_Init();


#ifdef __ADI_USE_UTILITY_ROM /* check if Utility ROM support is enabled */

#ifndef NO_UTILITY_ROM_LIBDRV
	/* Drivers initialization for the parts that have a Utility ROM. */
	if (result == 0) {
		static uint8_t bfrom_memory[ADI_BF70X_RAM_SIZE_FOR_ROM_CODE];
	
		result = adi_init_drv_Rom(bfrom_memory, (uint32_t) ADI_BF70X_RAM_SIZE_FOR_ROM_CODE);
	}
	
#endif /* NO_UTILITY_ROM_LIBDRV */

#endif /* __ADI_USE_UTILITY_ROM */

	if (result == 0) {
		result = adi_initpinmux(); /* auto-generated code (order:0) */
	}

	return result;
}

