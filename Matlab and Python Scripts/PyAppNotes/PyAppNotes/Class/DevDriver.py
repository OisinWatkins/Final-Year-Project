#< @file        DevDriver.py                                                                
#< @author      Haderer Andreas (HaAn)                                                  
#< @date        2013-06-13          
#< @brief       Class for device driver configuration functions
#< @version     1.0.1
from    numpy import *

class   DevDriver(object):
    
    def __init__(self):
        self.lRegs      =   list()
        pass

    # DOXYGEN ------------------------------------------------------
    #> @brief Generate register values with class predefined flags
    #>  
    #> This function can be used to generate register values. The function automatically ensures that reserver bits are preserved.
    #>
    #>  @param[in]  AdrName: if value is a number than it is interpreted as address; if the value is a string, then as the register name
    #>
    #>  @param[in]  Ini value of the register
    #>  
    #>  @param[in]  variable number of flags and values for the flags: e.g. , 'Div', 1: if the divider flag exists
    #>
    #>  @return     Value of the register
    #>       
    #>
    #> e.g. Generate register values with flags
    #>   @code
    #>   Brd        =   Radarbook('PNet','192.168.1.1')
    #>   Adf5904    =   DevAdf5904(Brd,USpiCfg)
    #>   RegR0      =   Adf5904.GenRegFlg('R0', 0, 'PupLo', 1)
    #>   @endcode          
    def     GenRegFlag(self, AdrName, Ini, *varargin):
        RegVal      =   -1

        if isinstance(AdrName, str):
            RegIdx      =   self.FindRegByName(AdrName) 
            NArg        =   len(varargin)
            ArgIdx      =   0
            RegVal      =   Ini
            while ArgIdx < NArg:
                RemArg  =   ArgIdx
                if (RemArg % 2) == 0:
                    stField     =   varargin[ArgIdx]
                    Val         =   varargin[ArgIdx+1]    
                    RegVal      =   self.GenRegSetField(RegVal, RegIdx, stField, Val)    
                    ArgIdx      = ArgIdx + 2
                else:
                    # cancel initialization
                    ArgIdx      = NArg
        
            RegVal      =   self.GenRegSetDefault(RegVal, RegIdx);
        else:
            pass

        return  RegVal    

        
    # DOXYGEN ------------------------------------------------------
    #> @brief Print register map in Matlab command window
    #>  
    #> Print register map in the command window of Matlab. This function can be used to find the names of the registers.
    #> 
    #> e.g. After calling the function the register map is printed 
    #> @code
    #> Register Name:  R0 @Adr: 0
    #> Register Name:  R1 @Adr: 1
    #> Register Name:  R2 @Adr: 2
    #> Register Name:  R3 @Adr: 3
    #> Register Name:  R4 @Adr: 4
    #> Register Name:  R5 @Adr: 5
    #> Register Name:  R6 @Adr: 6
    #> Register Name:  R7 @Adr: 7
    #> Register Name:  R8 @Adr: 8
    #> Register Name:  R9 @Adr: 9
    #> Register Name:  R10 @Adr: 10
    #> @endcode             
    def     PrntRegMap(self, *varargin):
        print("[DevDriver]: PrntRegMap")        
        for dElem in self.lRegs:
            stOut   =   'Register Name:  ' +  dElem["Name"] + ' @Adr: ' + str(dElem["Adr"])  
            print(stOut)
         
        
    # DOXYGEN ------------------------------------------------------
    #> @brief Print flags of registers in Matlab command window
    #>  
    #> This function can be used to find the names of the flags.
    #>   
    #> @param[in]   Name of register (optional)
    #>
    #> After calling the function with argument 'R0' the flags for R0 are printed in the command window
    #>  @code
    #> Reg: R0 @Adr: 0
    #>  Field: Ctrl
    #>  Field: Res
    #>  Field: DoutVSel
    #>  Field: LoPinBias
    #>  Field: PupLo
    #>  Field: PupChn1
    #>  Field: PupChn2
    #>  Field: PupChn3
    #>  Field: PupChn4
    #>  Field: Res
    #>  @endcode
    def     PrntRegFlags(self, *varargin):
        if len(varargin) > 0:
            if isinstance(varagin[0],str):
                RegIdx      =   obj.FindRegByName(varargin[0]);
                dReg        =   self.lRegs[RegIdx]
                stOut       =   'Reg: ' + dReg["Name"] + ' @Adr: ' + str(dReg["Adr"])
                print(stOut)
                for dField in dReg["lFields"]:
                    print('  Field: ',dField["Name"])
        else:
            for dElem in self.lRegs:
                stOut       =   'Reg: ' + dElem["Name"] + ' @Adr: ' + str(dElem["Adr"])
                print(stOut)                
                for dField in dElem["lFields"]:
                    print('  Field: ',dField["Name"])



    #   @function       GenRegSetField                                                             
    #   @author         Haderer Andreas (HaAn)                                                  
    #   @date           2015-07-27          
    #   @brief          Set Field of Register
    #   @param[in]      RegVal: register value
    #   @param[in]      RegIdx: Index of register in caRegs array
    #   @param[in]      stField: Name of field
    #   @param[in]      Value of field
    #   @return         New register value
    def     GenRegSetField(self, RegVal, RegIdx, stField, Val):
        dReg        =   self.lRegs[RegIdx]
        lFields     =   dReg["lFields"]
        RegVal      =   RegVal
        Ini         =   False
        for dEntry in lFields: 
            if dEntry["Name"] == stField:
                Ini         =   True
                Low         =   2**dEntry["Strt"]
                High        =   2**(dEntry["Stop"] + 1)
                if High < Low:
                    print('Field definition error')
                else:
                    Lim         =   2**(dEntry["Stop"] + 1 - dEntry["Strt"])
                    RegValLow   =   RegVal % Low
                    RegValHigh  =   floor(RegVal/High)
                    Val         =   Val % Lim
                    RegVal      =   RegValLow + Val*Low + RegValHigh*High;
        if Ini == False:
            print("Field not known: ", stField);
        
        return  RegVal

    def     FindRegByAdr(self, Adr):
        Idx         =   -1
        RegIdx      =   Idx
        for dReg    in self.lRegs:
            Idx     =   Idx + 1
            if dReg["Adr"] == Adr:
                RegIdx      =   Idx

        return RegIdx

   
    def     FindRegByName(self, stName):
        Idx         =   -1
        RegIdx      =   Idx
        for dReg    in  self.lRegs:
            Idx     =   Idx + 1
            if dReg["Name"] == stName:
                RegIdx      =   Idx
        return RegIdx

    #   @function       GenRegSetDefault                                                             
    #   @author         Haderer Andreas (HaAn)                                                  
    #   @date           2015-07-27          
    #   @brief          Set default value: ensure res and adr field
    #   values
    #   @param[in]      RegVal: register value
    #   @param[in]      RegIdx: Index of register in caRegs array 
    def     GenRegSetDefault(self, RegVal, RegIdx):
        dReg        =   self.lRegs[RegIdx]
        lFields     =   dReg["lFields"]
        RegVal      =   RegVal;
        for dField in lFields:
            if dField["Name"] == 'Res':
                Low         =   2**dField["Strt"]
                High        =   2**(dField["Stop"] + 1)
                Lim         =   2**(dField["Stop"] + 1 - dField["Strt"])
                RegValLow   =   RegVal % Low
                RegValHigh  =   floor(RegVal/High)
                Val         =   dField["Val"] % Lim
                RegVal      =   RegValLow + Val*Low + RegValHigh*High
            if dField["Name"] == 'Ctrl':
                Low         =   2**dField["Strt"]
                High        =   2**(dField["Stop"] + 1)
                Lim         =   2**(dField["Stop"] + 1 - dField["Strt"])
                RegValLow   =   RegVal % Low
                RegValHigh  =   floor(RegVal/High)
                Val         =   dField["Val"] % Lim
                RegVal      =   RegValLow + Val*Low + RegValHigh*High

        return RegVal

        


