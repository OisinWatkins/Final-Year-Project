/***************************************************************************************
* 	File name : CGUInit.h
* 	Purpose: Includes the macros, variables and function declarations for CGUInit.c
* 	Author: Jeyanthi
* 	VDSP version used for testing: Andromeda Beta(Oct 14th 2011)
* 	Hardware used: BF609 EZ-KIT
* 	Connection details :  N/A
* 	Guidelines for change: N/A
*****************************************************************************************/

#ifndef __CGUINIT_H__
#define __CGUINIT_H__

//#include "ProcInclude.h"
#include <sysreg.h>
#include <ccblkfn.h>
#include <stdio.h>
#include <stdarg.h>
#include <cdefBF707.h>
#include <defBF707.h>

// macros for CLKOUT options
#define	CLKIN 0
#define	CCLK_BY_4  1
#define	SYSCLK_BY_2 2
#define	SCLK0 3
#define	SCLK1 4
#define	DCLK_BY_2 5
#define	USB_PLL_CLK 6
#define	OUT_CLK 7
#define	USB_CLKIN 8

// Default values for the parameters
#define  MULTIPLIER_SEL		20
#define	 DF_SEL				false
#define  CCLK_SEL			1
#define  DDRCLK_SEL			2
#define	 SCLK0_SEL			2
#define	 SCLK1_SEL			2
#define	 SYSCLK_SEL			2
#define	 OUTCLK_SEL			4
#define  CLKOUT_SEL			CCLK_BY_4


//PLL Multiplier and Divisor Selections (Required Value, Bit Position)
#define MSEL(X)         ((X  << BITP_CGU_CTL_MSEL)) 	//PLL Multiplier Select [1-127]: PLLCLK = ((CLKIN x MSEL/DF+1))
//#define DF(X)	        ((X  << BITP_CGU_CTL_DF)    & BITM_CGU_CTL_DF )		// Divide frequency[true or false]
#define DF(X)	        ((X  << BITP_CGU_CTL_DF))		// Divide frequency[true or false]
#define CSEL(X)         ((X  << BITP_CGU_DIV_CSEL)	)	//Core Clock Divisor Select [1-31]: (CLKIN x MSEL/DF+1)/CSEL
#define SYSSEL(X)       ((X  << BITP_CGU_DIV_SYSSEL))	//System Clock Divisor Select [1-31]: (CLKIN x MSEL/DF+1)/SYSSEL
#define S0SEL(X)        ((X  << BITP_CGU_DIV_S0SEL)	)	//SCLK0 Divisor Select [1-7]: SYSCLK/S0SEL
#define S1SEL(X)        ((X  << BITP_CGU_DIV_S1SEL)	)	//SCLK1 Divisor Select [1-7]: SYSLCK/S1SEL
#define DSEL(X)         ((X  << BITP_CGU_DIV_DSEL)	) 	//DDR Clock Divisor Select [1-31]: (CLKIN x MSEL/DF+1)/DSEL
#define OSEL(X)         ((X  << BITP_CGU_DIV_OSEL)	) 	//OUTCLK Divisor Select [1-127]: (CLKIN x MSEL/DF+1)/OSEL
#define CLKOUTSEL(X)    ((X  << BITP_CGU_CLKOUTSEL_CLKOUTSEL)	) 	//CLKOUT Select [0-8]
#define USBCLKSEL(X)    ((X  << BITP_CGU_CLKOUTSEL_USBCLKSEL)	) 			/* USBCLKSEL select */


#define COUNT_PARMS2(_1, _2, _3, _4, _5, _6, _7, _8, _9,_, ...) _
#define COUNT_PARMS(...)\
	COUNT_PARMS2(__VA_ARGS__,9, 8, 7, 6, 5, 4, 3, 2, 1)

/***************************************************************************************************
*	Function name	:	CGU_Init_All
*	Description		:	This function initializes the CGU with the multiplier, Divide frequency,
*						CCLK SEL, DDR2CLK SEL, SCLK0 SEL , SCLK1 SEL ,SYSCLK SEL ,Output clock and
*						CLKOUT values passed
*	Arguments		:	Parameter	 		|	Description				| Valid values
*						iMultiplier	 		|	Multiplier value		| 1 - 127
*						bDivideFrequency    |	Divide Frequency Select	| true or false
*						iCCLKSel 			|	CCLK SEL value			| 1 - 31
*		   				iDDCLKSel			|	DDR2CLK SEL value		| 1 - 31
*		   				iSCLK0Sel			|	SCLK0 SEL value			| 1 - 7
*		   				iSCLK1Sel			|	SCLK1 SEL value			| 1 - 7
*   					iSysCLKSel 			|	SYSCLK SEL Value		| 1 - 31
*   					iOutClock 			|	Output clock value		| 1 - 127
*   					iClkOut				|	CLKOUT value			| 0 - 8
*	Return			:	None.
*
*   Note: Multiplier value should be selected to make sure that PLLCLK does not exceed 1GHz.
*
*         bDivideFrequency - false
*         iCCLKSel - 5
*         iDDCLKSel - 2
*         iSCLK0Sel - 2
*         iSCLK1Sel - 2
*         iSysCLKSel - 2
*         iOutClock - 4
*         iClkOut - CCLK_BY_4
*******************************************************************************************/

void CGU_Init_All(int iMultiplier,bool bDivideFrequency, int iCCLKSel,int iDDCLKSel, int iSCLK0Sel, int iSCLK1Sel,int iSysCLKSel,int iOutClock, int iClkOut);

#endif /* __CGUINIT_H__ */
