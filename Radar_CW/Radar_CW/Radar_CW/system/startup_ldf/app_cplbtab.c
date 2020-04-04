/*


** ADSP-BF706 CPLB table definitions generated on Oct 09, 2017 at 11:10:05.


*/
/*
** Copyright (C) 2000-2017 Analog Devices Inc., All Rights Reserved.
**
** This file is generated automatically based upon the options selected
** in the System Configuration utility. Changes to the CPLB configuration
** should be made by modifying the appropriate options rather than editing
** this file. To access the System Configuration utility, double-click the
** system.svc file from a navigation view.
**
** Custom additions can be inserted within the user-modifiable sections,
** these are bounded by comments that start with "$VDSG". Only changes
** placed within these sections are preserved when this file is re-generated.
**
** Product      : CrossCore Embedded Studio
** Tool Version : 6.0.9.0
*/

/* Configuration:-
**     use_user_mod:                           true
**     crt_doj:                                app_startup.doj
**     processor:                              ADSP-BF706
**     product_name:                           CrossCore(R) Embedded Studio
**     si_revision:                            1.1
**     default_silicon_revision_from_archdef:  1.1
**     device_init:                            true
**     cplb_init:                              true
**     cplb_init_cplb_ctrl:                    57
**     has_default_cplbs:                      true
**     cplb_init_cplb_src_file:                app_cplbtab.c
**     cplb_init_cplb_obj_file:                app_cplbtab.doj
**     cplb_init_cplb_src_alt:                 false
**     dcache_config:                          disable_dcache_and_enable_cplb
**     icache_config:                          enable_icache
**     using_cplusplus:                        true
**     use_profiling:                          false
**     mem_init:                               false
**     use_eh:                                 true
**     use_argv:                               false
**     use_pgo_hw:                             false
**     use_full_cpplib:                        false
**     running_from_internal_memory:           true
**     user_heap_src_file:                     app_heaptab.c
**     libraries_use_fileio_libs:              false
**     libraries_use_eh_enabled_libs:          false
**     libraries_use_fixed_point_io_libs:      false
**     libraries_heap_dbg_libs:                false
**     libraries_use_utility_rom:              true
**     detect_stackoverflow:                   false
**     system_heap:                            L1
**     system_heap_min_size:                   4
**     system_heap_size_units:                 kB
**     system_stack:                           L1
**     system_stack_min_size:                  4
**     system_stack_size_units:                kB
**     use_mt:                                 false
**     use_software_modules:                   false
**     use_user_mod_ldf:                       true
*/
#include <sys/platform.h>
#include <cplbtab.h>
#include <cplb.h>

#ifdef _MISRA_RULES
#pragma diag(push)
#pragma diag(suppress:misra_rule_2_2)
#pragma diag(suppress:misra_rule_8_10)
#pragma diag(suppress:misra_rule_10_1_a)
#endif /* _MISRA_RULES */

#define CACHE_MEM_MODE (CPLB_DNOCACHE)

#pragma section("cplb_data")

cplb_entry dcplbs_table[] = {

   /* L1 data C - covered by REG_L1DM_DCPLB_DFLT. */
   /* L1 data B - covered by REG_L1DM_DCPLB_DFLT. */
   /* L1 data A - covered by REG_L1DM_DCPLB_DFLT. */
   /* L2 SRAM */
   {0x08000000, (ENUM_L1DM_DCPLB_DATA_256KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY)}, 
   {0x08040000, (ENUM_L1DM_DCPLB_DATA_256KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY)}, 
   {0x08080000, (ENUM_L1DM_DCPLB_DATA_256KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY)}, 
   {0x080C0000, (ENUM_L1DM_DCPLB_DATA_64KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY)}, 
   {0x080D0000, (ENUM_L1DM_DCPLB_DATA_64KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY)}, 
   {0x080E0000, (ENUM_L1DM_DCPLB_DATA_64KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY)}, 
   {0x080F0000, (ENUM_L1DM_DCPLB_DATA_64KB | CPLB_DNOCACHE | BITM_L1DM_DCPLB_DATA_DIRTY)}, 



   /* L2 ROM */
   {0x04000000, (ENUM_L1DM_DCPLB_DATA_256KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY | CPLB_READONLY_ACCESS)}, 
   {0x04040000, (ENUM_L1DM_DCPLB_DATA_256KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY | CPLB_READONLY_ACCESS)}, 



   /* Static Memory Controller (SMC) memory, can connect to


   ** Asynchronous SRAM, Asynchronous flash or NOR flash for example.


   ** Two blocks of up to 8KB.


   */
   {0x70000000, (ENUM_L1DM_DCPLB_DATA_4KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY | CPLB_READONLY_ACCESS)}, 
   {0x70001000, (ENUM_L1DM_DCPLB_DATA_4KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY | CPLB_READONLY_ACCESS)}, 
   {0x74000000, (ENUM_L1DM_DCPLB_DATA_4KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY | CPLB_READONLY_ACCESS)}, 
   {0x74001000, (ENUM_L1DM_DCPLB_DATA_4KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY | CPLB_READONLY_ACCESS)}, 
   /* 128 MB SPI FLASH */
   {0x40000000, (ENUM_L1DM_DCPLB_DATA_64MB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY | CPLB_READONLY_ACCESS)}, 
   {0x44000000, (ENUM_L1DM_DCPLB_DATA_64MB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY | CPLB_READONLY_ACCESS)}, 
   /* 4KB OTP memory */
   {0x38000000, (ENUM_L1DM_DCPLB_DATA_4KB | CACHE_MEM_MODE | BITM_L1DM_DCPLB_DATA_DIRTY | CPLB_READONLY_ACCESS)}, 
   /* end of section - termination */
   {0xffffffff, 0}, 
}; /* dcplbs_table */

#pragma section("cplb_data")

cplb_entry icplbs_table[] = {

   /* L1 Instruction - covered by REG_L1IM_ICPLB_DFLT. */
   /* L2 SRAM */
   {0x08000000, (ENUM_L1IM_ICPLB_DATA_256KB | CPLB_IDOCACHE)}, 
   {0x08040000, (ENUM_L1IM_ICPLB_DATA_256KB | CPLB_IDOCACHE)}, 
   {0x08080000, (ENUM_L1IM_ICPLB_DATA_256KB | CPLB_IDOCACHE)}, 
   {0x080C0000, (ENUM_L1IM_ICPLB_DATA_64KB | CPLB_IDOCACHE)}, 
   {0x080D0000, (ENUM_L1IM_ICPLB_DATA_64KB | CPLB_IDOCACHE)}, 
   {0x080E0000, (ENUM_L1IM_ICPLB_DATA_64KB | CPLB_IDOCACHE)}, 
   {0x080F0000, (ENUM_L1IM_ICPLB_DATA_64KB | CPLB_INOCACHE)}, 
   /* L2 ROM */
   {0x04000000, (ENUM_L1IM_ICPLB_DATA_256KB | CPLB_IDOCACHE)}, 
   {0x04040000, (ENUM_L1IM_ICPLB_DATA_256KB | CPLB_IDOCACHE)}, 



   /* Static Memory Controller (SMC) memory, can connect to


   ** Asynchronous SRAM, Asynchronous flash or NOR flash for example.


   ** Two blocks of up to 8KB.


   */
   {0x70000000, (ENUM_L1IM_ICPLB_DATA_4KB | CPLB_IDOCACHE)}, 
   {0x70001000, (ENUM_L1IM_ICPLB_DATA_4KB | CPLB_IDOCACHE)}, 
   {0x74000000, (ENUM_L1IM_ICPLB_DATA_4KB | CPLB_IDOCACHE)}, 
   {0x74001000, (ENUM_L1IM_ICPLB_DATA_4KB | CPLB_IDOCACHE)}, 



   /* 128 MB SPI FLASH */
   {0x40000000, (ENUM_L1IM_ICPLB_DATA_64MB | CPLB_IDOCACHE)}, 
   {0x44000000, (ENUM_L1IM_ICPLB_DATA_64MB | CPLB_IDOCACHE)}, 
   /* end of section - termination */
   {0xffffffff, 0}, 
}; /* icplbs_table */


#ifdef _MISRA_RULES
#pragma diag(pop)
#endif /* _MISRA_RULES */

