	/************************************************************************
 *
 * defADF5901.h
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

#ifndef __DEF_ADF5901_H__
#define __DEF_ADF5901_H__

///////////////////////////////////////////////////////////////////////////////
//
// ADF5901 Initialization Sequence
//
// Notes:
// 1. The information below is derived from "Table 6: Initialization Sequence"
// as shown on page 22 of the Rev. Pr. G data sheet.
//
// 2. Please note the following timing delays are also shown in Table 6:
//  a. 10usec delay after Step #7
//  b. 800usec delay after Step #15
//  c. 400usec delay after Step #17
//  d. 400usec delay after Step #19
//
///////////////////////////////////////////////////////////////////////////////

#define ADF5901_INIT_SEQUENCE_LENGTH                21

/*
int adf5901_init_sequence_values[ADF5901_INIT_SEQUENCE_LENGTH] = {
    (MASTER_RESET_ENABLED | ADF5901_REG_R7_CTRL),
    (REG_R11_CNTR_RESET_ENABLED | ADF5901_REG_R11_CTRL),
    (REG_R11_CNTR_RESET_DISABLED | ADF5901_REG_R11_CTRL),
    (REG_R10_RESERVED_FINAL_CONFIG_VAL | ADF5901_REG_R10_CTRL),
    (REG_R9_RESERVED_FINAL_CONFIG_VAL | ADF5901_REG_R9_CTRL),
    (REG_R8_RESERVED_BITS_VAL | FREQ_CAL_DIV_VAL(0x1f4)| ADF5901_REG_R8_CTRL),
    (REG_R0_RESERVED_BITS_VAL | AUX_BUFFER_GAIN_SETTING_4 | AUX_DIV_1 | PWR_UP_RCNTR | PWR_UP_NCNTR | POWER_UP_VCO | POWER_UP_ADC | POWER_UP_LO | ADF5901_REG_R0_CTRL),
    (REG_R7_RESERVED_BITS_VAL | MASTER_RESET_DISABLED | CLK_DIVIDER_VAL(0x1f4) | R_DIV_2_ENABLED | R_DIVIDER_VAL(1) | ADF5901_REG_R7_CTRL),
    (REG_R6_RESERVED_BITS_VAL | FRAC_LSB_WORD_VAL(0) | ADF5901_REG_R6_CTRL),
    (REG_R5_RESERVED_BITS_VAL | INTEGER_WORD_VAL(0xf1) | FRAC_MSB_WORD_VAL(0x400) | ADF5901_REG_R5_CTRL),
    (REG_R4_RESERVED_BITS_VAL | TBA_NORMAL_OPERATION | TBP_NORMAL_OPERATION | ANALOG_TEST_BUS_NONE | ADF5901_REG_R4_CTRL),
    (REG_R3_RESERVED_BITS_VAL | MUXOUT_TRISTATE_OUTPUT | LOGIC_OUTPUTS_3_3V | READBACK_CTRL_NONE | ADF5901_REG_R3_CTRL),
    (REG_R2_RESERVED_BITS_VAL | ADC_START_NORMAL_OPERATION | ADC_AVG_1 | ADC_CLK_DIV_VAL(0x32) | ADF5901_REG_R2_CTRL),
    (REG_R1_RESERVED_BITS_VAL | TX_AMP_CAL_REF_CODE_VAL(0xff) | ADF5901_REG_R1_CTRL),
    (REG_R0_RESERVED_BITS_VAL | AUX_BUFFER_GAIN_SETTING_4 | AUX_DIV_1 | PWR_UP_RCNTR | PWR_UP_NCNTR | TX2_AMP_CAL_NORMAL_OPERATION | TX1_AMP_CAL_NORMAL_OPERATION | POWER_UP_VCO | VCO_FULL_CAL | POWER_UP_ADC | POWER_DOWN_TX2 | POWER_DOWN_TX1 | POWER_UP_TX1 | POWER_UP_LO | ADF5901_REG_R0_CTRL),
    (REG_R0_RESERVED_BITS_VAL | AUX_BUFFER_GAIN_SETTING_4 | AUX_DIV_1 | PWR_UP_RCNTR | PWR_UP_NCNTR | TX2_AMP_CAL_NORMAL_OPERATION | TX1_AMP_CAL_NORMAL_OPERATION | POWER_UP_VCO | VCO_CAL_NORMAL_OPERATION | POWER_UP_ADC | POWER_DOWN_TX2 | POWER_UP_TX1 | POWER_UP_LO | ADF5901_REG_R0_CTRL),
    (REG_R0_RESERVED_BITS_VAL | AUX_BUFFER_GAIN_SETTING_4 | AUX_DIV_1 | PWR_UP_RCNTR | PWR_UP_NCNTR | TX2_AMP_CAL_NORMAL_OPERATION | TX1_AMP_CAL | POWER_UP_VCO | VCO_CAL_NORMAL_OPERATION | POWER_UP_ADC | POWER_DOWN_TX2 | POWER_UP_TX1 | POWER_UP_LO | ADF5901_REG_R0_CTRL),
    (REG_R0_RESERVED_BITS_VAL | AUX_BUFFER_GAIN_SETTING_4 | AUX_DIV_1 | PWR_UP_RCNTR | PWR_UP_NCNTR | TX2_AMP_CAL_NORMAL_OPERATION | TX1_AMP_CAL_NORMAL_OPERATION | POWER_UP_VCO | VCO_CAL_NORMAL_OPERATION | POWER_UP_ADC | POWER_UP_TX2 | POWER_DOWN_TX1 | POWER_UP_LO | ADF5901_REG_R0_CTRL),
    (REG_R0_RESERVED_BITS_VAL | AUX_BUFFER_GAIN_SETTING_4 | AUX_DIV_1 | PWR_UP_RCNTR | PWR_UP_NCNTR | TX2_AMP_CAL | POWER_UP_VCO | VCO_CAL_NORMAL_OPERATION | TX1_AMP_CAL_NORMAL_OPERATION | POWER_UP_ADC | POWER_UP_TX2 | POWER_DOWN_TX1 | POWER_UP_LO | ADF5901_REG_R0_CTRL),
    (REG_R9_RESERVED_FINAL_CONFIG_VAL | ADF5901_REG_R9_CTRL),
    (REG_R0_RESERVED_BITS_VAL | AUX_BUFFER_GAIN_SETTING_4 | AUX_DIV_1 | PWR_DOWN_RCNTR | PWR_DOWN_NCNTR | TX2_AMP_CAL_NORMAL_OPERATION | TX1_AMP_CAL_NORMAL_OPERATION | POWER_UP_VCO | VCO_CAL_NORMAL_OPERATION | POWER_DOWN_ADC | POWER_DOWN_TX2 | POWER_UP_TX1 | POWER_UP_LO | ADF5901_REG_R0_CTRL)};
*/

/*
int adf5901_init_sequence_values[ADF5901_INIT_SEQUENCE_LENGTH] = {0x2000007,0x2B,0xB,0x1D32A64A,0x2A20B929,0x40003E88,0x809F2460,0x11F4827,0x6,0x1E28005,0x200004
                                                                  ,0x1890803, 0x20642,0xFFF7FFE1,0x809F2660,0x809F2460,0x809F2C60,0x809F24A0,0x809F34A0,0x2800B929,0x809F24A0};
*/

unsigned int adf5901_tx_pll_sequence_values[3] ={
													0x809FA5A0,	// 21-R0 // Power Up R Counter
													0x01893803,	// 12-R3 MUXOUT - R Divider
													0x01E28005,	// R5
												};

unsigned int adf5901_init_sequence_values[ADF5901_INIT_SEQUENCE_LENGTH] =	{
															      0x02000007, // 1- R7
		                                                          0x0000002B, // 2- R11
		                                                          0x0000000B, // 3- R11
		                                                          0x1D32A64A, //4- R10
		                                                          0x2A20B929, //5- R9
		                                                          0x40003E88, //6- R8
		                                                          0x809FE520, //7- R0
		                                                          0x011F4827, //8- R7
		                                                          0x00000006, //9- R6
		                                                          0x01E28005, //10-R5
		                                                          0x00200004, //11-R4
                                                                  0x01890803, //12-R3
                                                                  0x00020642, //13-R2
                                                                //0xFFF7FFE1, //14-R1  max power
                                                                //0xFFF7EA01, // 14-R1 80d = 0x50 less power
                                                                //0xFFF7E281, // 14-R1 20d = 0x14
                                                                //0xFFF7E381, // 14-R1 28d = 0x1C
                                                                  0xFFF7E401, // 14-R1 32d = 0x20	~ +13 dBm EIRP measured in office
                                                                  0x809FE720, //15-R0
                                                                  0x809FE560, //16-R0
                                                                  0x809FED60, //17-R0
                                                                  0x809FE5A0, //18-R0
                                                                  0x809FF5A0, //19-R0
                                                                  0x2800B929, //20-R9
                                                                  0x809F25A0  //21- R0
																			};

#endif // __DEF_ADF5901_H__
