/************************************************************************
 *
 * defADF4159.h
 *
 * (c) Copyright 2015 Analog Devices, Inc.  All rights reserved.
 *
 ************************************************************************/

#ifndef __DEF_ADF4159_H__
#define __DEF_ADF4159_H__

///////////////////////////////////////////////////////////////////////////////
//
// Applications Information from the ADF4159 Rev. E Data Sheet
//
// ADF4159 Initialization Sequence:
// 1. Program Delay Register (R7)
// 2. Program Step Register (R6)
//      a. Load the Step Register TWICE
//      b. First with STEP_SELECT_WORD_1 (STEP SELECT = 0)
//      c. And then with STEP_SELECT_WORD_2 (STEP SELECT = 1)
// 3. Program Deviation Register (R5)
//      a. Load the Deviation Register TWICE
//      b. First with DEVIATION_SELECT_WORD_1 (DEVIATION SELECT = 0)
//      c. And then with DEVIATION_SELECT_WORD_2 (DEVIATION SELECT = 1)
// 4. Program Clock Register (R4)
//      a. Load the Clock Register TWICE
//      b. First with CLK_DIV_1_SEL (CLOCK DIVIDER SELECT = 0)
//      c. And then with CLK_DIV_2_SEL (CLOCK DIVIDER SELECT = 1)
// 5. Program Function Register (R3)
// 6. Program R Divider Register (R2)
// 7. Program LSB FRAC Register (R1)
// 8. Program FRAC-INT Register (R0)
//
///////////////////////////////////////////////////////////////////////////////

#define ADF4159_INIT_SEQUENCE_LENGTH                11

/*
int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = {
    (DELAY_REGISTER_R7 | FAST_RAMP_ENABLED | DELAY_START_WORD(0)),
    (STEP_REGISTER_R6 | STEP_SELECT_WORD_1 | STEP_WORD(0x3e8)),
    (STEP_REGISTER_R6 | STEP_SELECT_WORD_2 | STEP_WORD(0x4)),
    (DEVIATION_REGISTER_R5 | DEVIATION_SELECT_WORD_1 | DEVIATION_WORD(7) | DEVIATION_OFFSET_WORD(0xf4)),
    (DEVIATION_REGISTER_R5 | DEVIATION_SELECT_WORD_2 | DEVIATION_WORD(9) | DEVIATION_OFFSET_WORD(0x3b94)),
    (CLOCK_REGISTER_R4 | CLK_DIV_1_SEL | RAMP_STATUS_RAMP_COMP_TO_MUXOUT | CLK_DIV_MODE_RAMP_DIVIDER | CLK_2_DIVIDER_VALUE(0x18)),
    (CLOCK_REGISTER_R4 | CLK_DIV_2_SEL | RAMP_STATUS_RAMP_COMP_TO_MUXOUT | CLK_DIV_MODE_RAMP_DIVIDER | CLK_2_DIVIDER_VALUE(0x2d)),
    (FUNCTION_REGISTER_R3 | NEG_BLEED_CURRENT_VALUE(0x3) | NEG_BLEED_CURRENT_DISABLE | PHASE_DETECTOR_POLARITY_POS | FUNCTION_REGISTER_R3_RESERVED_BITS_VAL),
    (R_DIVIDER_REGISTER_R2 | CYCLE_SLIP_REDUCTION_DISABLED | CHARGE_PUMP_CURRENT_SETTING_VAL(7) | PRESCALER_8DIV9 | R_COUNTER_DIV_RATIO_VALUE(1) | CLK_1_DIVIDER_VALUE(1)),
    (LSB_FRAC_REGISTER_R1 | PHASE_ADJUST_DISABLED | LSB_FRACTIONAL_VALUE(0) | PHASE_VALUE(1)),
    (FRAC_INT_REGISTER_R0 | RAMP_ON_ENABLED | MUXOUT_CTRL_READBACK_TO_MUXOUT | INTEGER_VALUE(0x78) | MSB_FRACTIONAL_VALUE(0x200))};
*/
/*
int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = {
    (DELAY_REGISTER_R7 | FAST_RAMP_ENABLED | DELAY_START_WORD(0)),
    (STEP_REGISTER_R6 | STEP_SELECT_WORD_1 | STEP_WORD(0x3e8)),
    (STEP_REGISTER_R6 | STEP_SELECT_WORD_2 | STEP_WORD(0x4)),
    (DEVIATION_REGISTER_R5 | DEVIATION_SELECT_WORD_1 | DEVIATION_WORD(7) | DEVIATION_OFFSET_WORD(0xf4)),
    (DEVIATION_REGISTER_R5 | DEVIATION_SELECT_WORD_2 | DEVIATION_WORD(9) | DEVIATION_OFFSET_WORD(0x3b94)),
    (CLOCK_REGISTER_R4 | CLK_DIV_1_SEL | RAMP_STATUS_RAMP_COMP_TO_MUXOUT | CLK_DIV_MODE_RAMP_DIVIDER | CLK_2_DIVIDER_VALUE(0x18)),
    (CLOCK_REGISTER_R4 | CLK_DIV_2_SEL | RAMP_STATUS_RAMP_COMP_TO_MUXOUT | CLK_DIV_MODE_RAMP_DIVIDER | CLK_2_DIVIDER_VALUE(0x2d)),
    (FUNCTION_REGISTER_R3 | NEG_BLEED_CURRENT_VALUE(0x3) | RAMP_MODE_CONTINUOUS_SAWTOOTH| NEG_BLEED_CURRENT_DISABLE | PHASE_DETECTOR_POLARITY_POS | FUNCTION_REGISTER_R3_RESERVED_BITS_VAL),
    (R_DIVIDER_REGISTER_R2 | CYCLE_SLIP_REDUCTION_DISABLED | CHARGE_PUMP_CURRENT_SETTING_VAL(0xA) | PRESCALER_8DIV9 | R_COUNTER_DIV_RATIO_VALUE(1) | CLK_1_DIVIDER_VALUE(1)),
    (LSB_FRAC_REGISTER_R1 | PHASE_ADJUST_DISABLED | LSB_FRACTIONAL_VALUE(0) | PHASE_VALUE(1)),
    (FRAC_INT_REGISTER_R0 | RAMP_ON_ENABLED | MUXOUT_CTRL_READBACK_TO_MUXOUT | INTEGER_VALUE(0x78) | MSB_FRACTIONAL_VALUE(0x200))};
*/
                                                                   //R7      // R6   //R6    // R5     // R5    //R4     // R4     //R3      //R2       //R1  //R0
//int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = { 0x80007, 0x1F46, 0x800026, 0x3807A5, 0xC9DC95,0x780C04,0x7816C4 ,0xC20043, 0x740800A, 0x9, 0xF83C1000};// Bruce GUI values
//int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = { 0x80007, 0x1F46, 0x80026, 0x3807A5, 0xCE2375,0x780C04,0x7816C4 ,0xC20043, 0x740800A, 0x9, 0xF83C1000};
//int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = { 0x80007, 0x1F46, 0x800026, 0x3807A5, 0xC9DC95,0x780C04,0x7816C4 ,0xC20043, 0x740800A, 0x9, 0x783C1000}; //R0- with ramp disabled
//int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = { 0x80007, 0x2586, 0x800026, 0x3807A5, 0xC9DC95,0x780C04,0x7816C4 ,0xC20043, 0x740800A, 0x9, 0x783C1000}; //R0- with ramp disabled
//int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = { 0x80007, 0x2586, 0x800046, 0x003807A5, 0xC91DF5,0x780C04,0x7816C4 ,0xC20043, 0x740800A, 0x9, 0x783C1000}; //R0- with ramp disabled Pattrick
//int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = { 0x80007, 0x2586, 0x800046, 0x003807A5, 0xC91DF5,0x780C04,0x7816C4 ,0xC20043, 0x740800A, 0x9, 0x783C1000}; //R0- with triangle ramp disabled Pattrick

// default values slow triangle ramp sdp default
/*
unsigned int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = {
																   0x00000007, // R7
																   0x00001F46, // R6
																   0x00800006, // R6
																   0x00380835, // R5
																   0x00800005, // R5
																   0x00781904, // R4
																   0x00780144, // R4
																   0x00C20443, // R3
																   0x07408052, // R2
																   0x00000009, // R1
																   0x783C1000}; //R0- with triangle ramp
*/

// Single ramp-out with fast triangle ramp
unsigned int adf4159_init_sequence_values[ADF4159_INIT_SEQUENCE_LENGTH] = {
																   0x00080007, // R7: Fast Ramp (an alternative to the sawtooth ramp);
																   0x000008C6, // R6: Step 1: 280;
																   0x00800026, // R6: Step 2: 4;
																   0x00381AA5, // R5: DEV word 1: CLK_DIV; offset: 7; word: 852;
																   0x00C9D1F5, // R5: DEV word 2: CLK_DIV; offset: 9; word: 14910;
																   0x00980104, // R4: CLK DIV 1: RAMP DIVIDER; CLK2 DIVIDER = 2;
																   0x00980144, // R4: CLK DIV 2: RAMP DIVIDER; CLK2 DIVIDER = 2;
																   0x00C20443, // R3: loss of lock indication; CONTINUOUS TRIANGULAR; positive Phase Detector (PD) Polarity
																   0x07408192, // R2: R counter = 1; CLK1 DIVIDER = 50; CP current = 2.5 mA; PRESCALER = 8/9; RDIV2 = 0; Reference Doubler = 0;
																   0x00000009, // R1: No phase adjustment; values invalid
																   0x783C1000}; //R0: READBACK TO MUXOUT; FRAC = 512; INT = 120;

unsigned int adf4159_init_ramp_en = 0xF83C1000; //R0 with ramp enabled
unsigned int adf4159_init_ramp_dis= 0x783C1000; //R0 with ramp disabled

#endif // __DEF_ADF4159_H__
