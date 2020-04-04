/************************************************************************
 *
 * defADF5904.h
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

#ifndef __DEF_ADF5904_H__
#define __DEF_ADF5904_H__

///////////////////////////////////////////////////////////////////////////////
//
// ADF5904 Initialization Sequence
//
// Notes:
// 1. The information below is derived from "Table 6: Initialization Sequence"
// as shown on page 13 of the Rev. Pr. G data sheet.
//
///////////////////////////////////////////////////////////////////////////////

#define ADF5904_INIT_SEQUENCE_LENGTH                8

/*
int adf5904_init_sequence_values[ADF5904_INIT_SEQUENCE_LENGTH] = {
    (ADF5904_REG_R3_CTRL),
    (ADF5904_REG_R2_CTRL | CHANNEL_TEST_NONE),
    (ADF5904_REG_R1_CTRL | CHANNEL_SEL_CH1),
    (ADF5904_REG_R1_CTRL | CHANNEL_SEL_CH2),
    (ADF5904_REG_R1_CTRL | CHANNEL_SEL_CH3),
    (ADF5904_REG_R1_CTRL | CHANNEL_SEL_CH4),
    (ADF5904_REG_R1_CTRL | CONFIG_LO_INIT_SEQ_STEP_7),
    (ADF5904_REG_R0_CTRL | POWER_UP_CH2 | POWER_UP_CH1 | POWER_UP_LO | LO_PIN_NO_DC_BIAS | DOUT_VSEL_3_3V)};
*/
// Original Values
//int adf5904_init_sequence_values[ADF5904_INIT_SEQUENCE_LENGTH] = { 0x3, 0x20406, 0x20001499, 0x40001499 , 0x60001499 ,0x80001499,0xA0000019, 0x80001CA0};

unsigned int adf5904_init_sequence_values[ADF5904_INIT_SEQUENCE_LENGTH] = {
		0x3,          //R3
		0x20406,      //R2
		0x20001499,   //R1
		0x40001499,   // R1
		0x60001499,   //R1
		0x80001499,   //R1
		0xA0000019,   //R1
		0x80007CA0};  //R0
		//0x800004A0}; // LO , CH1-4 powered down
//int adf5904_init_sequence_values[ADF5904_INIT_SEQUENCE_LENGTH] = { 0x3, 0x20406, 0x20001499, 0x40001499 , 0x60001499 ,0x80001499,0xA0000019, 0x80001CFC};

#endif // __DEF_ADF5904_H__
