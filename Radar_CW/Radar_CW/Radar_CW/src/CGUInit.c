/***************************************************************************************
*File name : CGUInit.c
*Purpose: Has functions to initialize the CGU.
*Author: Jeyanthi
*VDSP version used for testing: Andromeda Beta(Oct 14th 2011)
*Hardware used: BF609 EZ-KIT
*Connection details :  N/A
*Guidelines for change: N/A
*****************************************************************************************/
#include  "CGUInit.h"

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
*	Note: Multiplier value should be selected to make sure that PLLCLK does not exceed 1GHz.
*****************************************************************************************************/
void CGU_Init_All(int iMultiplierSel,bool bDivideFrequency, int iCCLKSel,int iDDCLKSel, int iSCLK0Sel, int iSCLK1Sel,int iSysCLKSel,int iOutClockSel, int iClkOut)
{
//	*pREG_CGU0_CTL = (((MSEL(MSEL_DIV))) |DF(DF_DIV));
//	*pREG_CGU0_DIV = (((OSEL(OSEL_DIV))| (SYSSEL(SYSSEL_DIV))|CSEL(CSEL_DIV ))|(S0SEL(S0SEL_DIV))|(S1SEL(S1SEL_DIV))|(DSEL(DSEL_DIV ))|(1<< BITP_CGU_DIV_UPDT));
//	*pREG_CGU0_CLKOUTSEL = CCLK_BY_16;

	*pREG_CGU0_CTL = (((MSEL(iMultiplierSel))) |DF(bDivideFrequency));
	*pREG_CGU0_DIV = (((OSEL(iOutClockSel))| (SYSSEL(iSysCLKSel))|CSEL(iCCLKSel ))|(S0SEL(iSCLK0Sel))|(S1SEL(iSCLK1Sel))|(DSEL(iDDCLKSel ))|(1<< BITP_CGU_DIV_UPDT));
	*pREG_CGU0_CLKOUTSEL = iClkOut;

	__builtin_ssync();
	return;
}
