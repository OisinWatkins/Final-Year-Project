#< @file        DevAdf4159.m
#< @author      Haderer Andreas (HaAn)
#< @date        2013-06-13
#< @brief       Class for configuration of Adf4159 synthesizer
#< @version     1.1.0
import  Class.DevDriver  as DevDriver
from    numpy import *

class DevAdf4159(DevDriver.DevDriver):


    # DOXYGEN ------------------------------------------------------
    #> @brief Class constructor
    #>
    #> Construct a class object to configure the transmitter with an existing Frontend class object.
    #>
    #> @param[in]     Brd: Radarbook or Frontend class object
    #>
    #> @param[in]     (optional) USpiCfg: Configuration of USpi interface: access of device from the baseboard
    #>          -   <span style="color: #ff9900;"> 'Mask': </span>: Bitmask to select the device
    #>          -   <span style="color: #ff9900;"> 'Chn': </span>: Channel of USPI interface; TX is connected to this channel
    #>          -   <span style="color: #ff9900;"> 'Type': </span>: In the actual version only 'USpi' is supported for the type
    #>          If USpiCfg is not stated then the default setting is used: Mask = 1, Chn = 0; Type = 'USpi'
    #> @return  Returns a object of the class with the desired USpi interface configuration
    #>
    #> e.g. with PNet TCP/IP functions
    #>   @code
    #>   Brd        =   Radarbook('PNet','192.168.1.1')
    #>   USpiCfg.Mask   =   1
    #>   USpiCfg.Chn    =   1
    #>   Adf5901    =   DevAdf5901(Brd,USpiCfg)
    #>   @endcode
    def __init__(self, Brd, dUSpiCfg):
        super(DevAdf4159, self).__init__()

        self.stVers                 =   '1.1.0'
        self.USpiCfg_Mask           =   1
        self.USpiCfg_Chn            =   1
        self.USpiCfg_Type           =   'USpi'

        self.fStrt                  =   24.0e9
        self.fStop                  =   24.25e9
        self.TRampUp                =   512e-6
        self.TRampDo                =   128e-6

        # Choose internal reference frequency settings
        self.VcoDiv                 =   2
        self.fRefIn                 =   100e6
        self.ValD                   =   0                       # Reg doubler, 0: disabled, 1: enabled
        self.ValR                   =   1                       # preset divide ratio to 1 (1 ... 32)
        self.ValT                   =   0                       # REF_in divide-by-2, 0: disabled, 1: enabled

        self.fDev                   =   100e3                   # choosen frequency hop
        self.ClkSel                 =   1
        self.ClkInt                 =   1e-6
        self.Brd                    =   Brd
        if self.Brd.DebugInf > 10:
            print('ADF4159 Initialize')

        if not('Mask' in dUSpiCfg):
            print('DevAdf4159: Mask not specified')
            self.USpiCfg_Mask       =   1
        else:
            self.USpiCfg_Mask       =   dUSpiCfg["Mask"]

        if not ('Chn' in dUSpiCfg):
            print('DevAdf4159: Chn not specified')
            self.USpiCfg_Chn        =   0
        else:
            self.USpiCfg_Chn        =   dUSpiCfg["Chn"]

        if not ('Type' in dUSpiCfg):
            self.USpiCfg_Type       =   'USpi'
        else:
            self.USpiCfg_Type       =   dUSpiCfg["Type"]

        self.DefineConst();

    # DOXYGEN ------------------------------------------------------
    #> @brief Get version information of Adf5904 class
    #>
    #> Get version of class
    #>      - Version String is returned as string
    #>
    #> @return  Returns the version string of the class (e.g. 1.0.0)
    def     GetVers(self):
        return  self.stVers

    # DOXYGEN -------------------------------------------------
    #> @brief Displays version information in Matlab command window
    #>
    #> Display version of class in Matlab command window
    def     DispVers(self):
        print("ADF4159 Class Version: ",self.stVers)

    # DOXYGEN ------------------------------------------------------
    #> @brief Set device configuration
    #>
    #> This method is used to set the configuration of the device. A configuration structure is used to set the desired parameters.
    #> If a field is not present in the structure, then the parameter is not changed. The function only changes the local parameters of the class.
    #> The IniCfg methos must be called, so that the configuration takes place.
    #>
    #> @param[in]     Cfg: structure with the desired configuration
    #>          -   <span style="color: #ff9900;"> 'fStrt': </span>: Desired start frequency <br>
    #>          -   <span style="color: #ff9900;"> 'fStop': </span>: Desired stop frequency <br>
    #>          -   <span style="color: #ff9900;"> 'TRampUp': </span>: Duration of upchirp <br>
    #>
    #> @return  Returns a object of the class with the desired USpi interface configuration
    #>
    def     SetCfg(self, dCfg):
        if 'fStrt' in dCfg:
            self.fStrt          =   dCfg["fStrt"]
        else:
            print('ADF4159: fStrt not set')
        if 'fStop' in dCfg:
            self.fStop          =   dCfg["fStop"]
        else:
            print('ADF4159: fStop not set')
        if 'TRampUp' in dCfg:
            self.TRampUp        =   dCfg["TRampUp"]
        else:
            print('ADF4159: TRampUp not set')
        if 'TRampDo' in dCfg:
            self.TRampDo        =   dCfg["TRampDo"]
        if 'ClkInt' in dCfg:
            self.ClkInt         =   dCfg["ClkInt"]
        if 'ClkSel' in dCfg:
            self.ClkSel         =   dCfg["ClkSel"]

    # DOXYGEN ------------------------------------------------------
    #> @brief Set device register configuration
    #>
    #> Not yet implemented; Function call has no effect;
    #> Standard device driver function
    def     SetRegCfg(self, dCfg):
        pass

    # DOXYGEN ------------------------------------------------------
    #> @brief Set device basic hardware and class configuration
    #>
    #> Not yet implemented; Function call has no effect;
    #> Standard device driver function
    def     DevSetCfg(self):
        # reset this function is currently not implemented
        pass

    # DOXYGEN ------------------------------------------------------
    #> @brief Reset device
    #>
    #> Not yet implemented; Function call has no effect;
    #> Standard device driver function
    def     DevRst(self):
        # reset currently not implemented
        pass

    # DOXYGEN ------------------------------------------------------
    #> @brief Enable device
    #>
    #> Not yet implemented; Function call has no effect;
    #> Standard device driver function
    def     DevEna(self):
        # enable currently not implemented
        pass

    # DOXYGEN ------------------------------------------------------
    #> @brief Disable device
    #>
    #> Not yet implemented; Function call has no effect;
    #> Standard device driver function
    def     DevDi(self):
        # disable currently not implemented
        pass

    # DOXYGEN ------------------------------------------------------
    #> @brief Programm device registers to the PLL
    #>
    #> This function programms the register to the device. The function expects an array with 19 register values according to the
    #> device data sheet. In addition, a valid Radarbook object must be stated at the class constructor.
    #>
    #> @param[in]     Regs array with register values <br>
    #>                The register values are programmed to the device over the selected SPI interface.
    #>
    #> @return     Return code of the command
    def     DevSetReg(self, Regs):
        Ret     =   -1
        Regs    =   Regs.flatten(1)
        if self.USpiCfg_Type == 'USpi':
            dUSpiCfg            =   dict()
            dUSpiCfg["Mask"]    =   self.USpiCfg_Mask
            dUSpiCfg["Chn"]     =   self.USpiCfg_Chn
            if len(Regs) > 28:
                Regs            =   Regs[0:28]

            Ret     =   self.Brd.Dsp_SendSpiData(dUSpiCfg, Regs)
        return Ret

    # DOXYGEN ------------------------------------------------------
    #> @brief Programm device registers to the transmitter directly
    #>
    #> This function programms the register to the device, without caring for timing constraints.
    #>
    #> @param[in]     Regs array with register values number of entries must be smaller than 28 <br>
    #>                The register values are programmed to the device over the selected SPI interface.
    #>
    #> @return     Return code of the command
    def     DevSetRegDirect(self, Regs):
        Ret     =   -1
        Regs    =   Regs.flatten(1)
        if self.USpiCfg_Type == 'USpi':
            dUSpiCfg            =   dict()
            dUSpiCfg["Mask"]    =   self.USpiCfg_Mask
            dUSpiCfg["Chn"]     =   self.USpiCfg_Chn
            if len(Regs) > 28:
                Regs        =   Regs[0:28]

            Ret             =   self.Brd.Dsp_SendSpiData(dUSpiCfg, Regs)
        return  Ret

    # DOXYGEN ------------------------------------------------------
    #> @brief Get device registers
    #>
    #> Not yet implemented; Function call has no effect;
    #> Standard device driver function
    def     DevGetReg(self, Regs):
        pass

    # DOXYGEN ------------------------------------------------------
    #> @brief Initialize device
    #>
    #> This function generates the configuration from the settings programmed to the class object.
    #> First the registers are generated GenRegs() and thereafter the DevSetReg() method is called
    #>
    #>  @return     Return code of the DevSetReg method
    #>
    #> e.g. Configure PLL with default configuration
    #>   @code
    #>   Brd        =   Radarbook('PNet','192.168.1.1')
    #>   USpiCfg.Mask   =   1
    #>   USpiCfg.Chn    =   1
    #>   Adf4159        =   DevAdf4159(Brd,USpiCfg)
    #>   Adf4159.Ini()
    #>   @endcode
    def     Ini(self):
        Data            =   self.GenRegs()
        #print("Adf4951: ")
        #for Val in Data:
        #    print(" ", hex(Val))

        Ret             =   self.DevSetReg(Data)

    #   @function       GenRegs
    #   @author         Haderer Andreas (HaAn)
    #   @date           2015-07-27
    #   @brief          Generate registers for programming
    def     GenRegs(self):

        fStrtDiv            =   self.fStrt/self.VcoDiv
        fStopDiv            =   self.fStop/self.VcoDiv
        BDiv                =   fStopDiv - fStrtDiv                                             # Bandwidth divided


        fPfd                =   self.fRefIn*( (1+self.ValD) / (self.ValR*(1+self.ValT)))        # calculate internal PFD frequency
        NStrt               =   fStrtDiv/fPfd
        NStrtInt            =   floor(NStrt)
        NStrtFracMsb        =   floor((NStrt - NStrtInt) * 2**12)
        NStrtFracLsb        =   floor(((NStrt - NStrtInt) * 2**12 - NStrtFracMsb) * 2**13)

        DevMax              =   2**15
        fRes                =   fPfd/(2**25)
        DevOffs             =   ceil(log10(self.fDev/(fRes*DevMax))/log10(2))
        fDevRes             =   fRes * 2**DevOffs
        DevVal              =   round(self.fDev/(fRes * 2**DevOffs))
        fDevVal             =   fPfd/(2**25) * (DevVal * 2**DevOffs)

        Clk2                =   2                                                               # choosen value
        Clk1                =   50

        #print("NStep: ", self.TRampUp/1e-6)
        #print("NStep: ", self.TRampDo/1e-6)
        #print("TRampDo: ", self.TRampDo)

        NrStepsUp           =   round(self.TRampUp/1e-6)
        NrStepsDown         =   round(self.TRampDo/1e-6) + 1
        fDevUp              =   BDiv/NrStepsUp
        DevUp               =   fDevUp/fRes
        DevOffsUp           =   ceil(log10(DevUp/8000)/log10(2))
        DevValUp            =   round(DevUp/(2**DevOffsUp)/4)*4
        DevValDown          =   floor(DevValUp*(NrStepsUp/NrStepsDown/8))
        DevOffsDown         =   DevOffsUp + 3

        #print("DevUp: ", DevValUp* (2**DevOffsUp))
        #print("DevOffs: ", DevOffsUp)
        #print("DevVal: ", DevValUp)

        #print("DevDown: ", DevValDown* (2**DevOffsDown))
        #print("DevOffs: ", DevOffsDown)
        #print("DevVal: ", DevValDown)

        Frac                =   NStrtFracMsb* (2**13) + NStrtFracLsb;
        fStrt               =   2*(NStrtInt+Frac/(2**25))*fPfd
        BUp                 =   2*fPfd/(2**25)*(DevValUp*(2**DevOffsUp))*NrStepsUp
        Tim                 =   Clk1*Clk2/fPfd

        #print("fStrt: ", fStrt/1e6)
        #print("BUp: ", BUp/1e6)
        #print("fStop: ", (fStrt+ BUp)/1e6)

        self.fStrt                  =   fStrt
        self.fStop                  =   fStrt + BUp
        self.TRampUp                =   Tim*NrStepsUp
        self.TRampDo                =   Tim*NrStepsDown

        #print("fStrt: ", fStrt/1e6)
        #print("fStop: ", (fStrt + BUp)/1e6)
        #print("TUp: ", (Tim*NrStepsUp)/1e-6)

        Data                =   zeros(11, dtype = uint32)
        Data[0]             =   self.GenRegFlag('R7_Delay', 0, 'TxTrig',0, 'FastRamp', 1)
        Data[1]             =   self.GenRegFlag('R6_Step', 0, 'StepWrd', NrStepsUp, 'StepSel', 0)
        Data[2]             =   self.GenRegFlag('R6_Step', 0, 'StepWrd', NrStepsDown, 'StepSel', 1)
        Data[3]             =   self.GenRegFlag('R5_Dev', 0, 'DevWrd', DevValUp, 'DevOffs', DevOffsUp, 'DevSel', 0)
        Data[4]             =   self.GenRegFlag('R5_Dev', 0, 'DevWrd', DevValDown, 'DevOffs', DevOffsDown, 'DevSel', 1)
        Data[5]             =   self.GenRegFlag('R4_Clk', 0, 'ClkDivSel', 0, 'Clk2Div', Clk2, 'ClkDivMod', 3, 'RampSts', 4)
        Data[6]             =   self.GenRegFlag('R4_Clk', 0, 'ClkDivSel', 1, 'Clk2Div', Clk2, 'ClkDivMod', 3, 'RampSts', 4)
        Data[7]             =   self.GenRegFlag('R3_Func', 0, 'PDPol', 1, 'RampMod', 1, 'NegBleedCur', 3)
        Data[8]             =   self.GenRegFlag('R2_Div', 0, 'Clk1Div', Clk1, 'RCntr', self.ValR, 'RefDoub', self.ValD, 'RDiv2', self.ValT, 'PreSca', 1, 'CP', 7)
        Data[9]             =   self.GenRegFlag('R1_LsbFrac', 0, 'Frac', NStrtFracLsb)
        Data[10]            =   self.GenRegFlag('R0_FracInt', 0, 'Frac', NStrtFracMsb, 'Int', NStrtInt, 'MuxCtrl', 15)

        return  Data


    def     DefineConst(self):
        # ----------------------------------------------------
        # Define Register 1
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R0_FracInt"
        dReg["Adr"]          =   0
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   2
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Frac"
        dField["Strt"]       =   3
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Int"
        dField["Strt"]       =   15
        dField["Stop"]       =   26
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "MuxCtrl"
        dField["Strt"]       =   27
        dField["Stop"]       =   30
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RampOn"
        dField["Strt"]       =   31
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 2
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R1_LsbFrac"
        dReg["Adr"]          =   1
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   2
        dField["Val"]        =   1
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Phase"
        dField["Strt"]       =   3
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Frac"
        dField["Strt"]       =   15
        dField["Stop"]       =   27
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PhaseAdj"
        dField["Strt"]       =   28
        dField["Stop"]       =   28
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   29
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 3
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R2_Div"
        dReg["Adr"]          =   2
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   2
        dField["Val"]        =   2
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Clk1Div"
        dField["Strt"]       =   3
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RCntr"
        dField["Strt"]       =   15
        dField["Stop"]       =   19
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RefDoub"
        dField["Strt"]       =   20
        dField["Stop"]       =   20
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RDiv2"
        dField["Strt"]       =   21
        dField["Stop"]       =   21
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PreSca"
        dField["Strt"]       =   22
        dField["Stop"]       =   22
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   23
        dField["Stop"]       =   23
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "CP"
        dField["Strt"]       =   24
        dField["Stop"]       =   27
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "CSR"
        dField["Strt"]       =   28
        dField["Stop"]       =   28
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   29
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 4
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R3_Func"
        dReg["Adr"]          =   3
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   2
        dField["Val"]        =   3
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "CountrRst"
        dField["Strt"]       =   3
        dField["Stop"]       =   3
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "CPTri"
        dField["Strt"]       =   4
        dField["Stop"]       =   4
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PwrDwn"
        dField["Strt"]       =   5
        dField["Stop"]       =   5
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PDPol"
        dField["Strt"]       =   6
        dField["Stop"]       =   6
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "LDP"
        dField["Strt"]       =   7
        dField["Stop"]       =   7
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "FSK"
        dField["Strt"]       =   8
        dField["Stop"]       =   8
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PSK"
        dField["Strt"]       =   9
        dField["Stop"]       =   9
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RampMod"
        dField["Strt"]       =   10
        dField["Stop"]       =   11
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   12
        dField["Stop"]       =   13
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "SDRst"
        dField["Strt"]       =   14
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "NSel"
        dField["Strt"]       =   15
        dField["Stop"]       =   15
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "LOL"
        dField["Strt"]       =   16
        dField["Stop"]       =   16
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   17
        dField["Stop"]       =   17
        dField["Val"]        =   1
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   18
        dField["Stop"]       =   20
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "NBleedEna"
        dField["Strt"]       =   21
        dField["Stop"]       =   21
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "NegBleedCur"
        dField["Strt"]       =   22
        dField["Stop"]       =   24
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   25
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 5
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R4_Clk"
        dReg["Adr"]          =   4
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   2
        dField["Val"]        =   4
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   3
        dField["Stop"]       =   5
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "ClkDivSel"
        dField["Strt"]       =   6
        dField["Stop"]       =   6
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Clk2Div"
        dField["Strt"]       =   7
        dField["Stop"]       =   18
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "ClkDivMod"
        dField["Strt"]       =   19
        dField["Stop"]       =   20
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RampSts"
        dField["Strt"]       =   21
        dField["Stop"]       =   25
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "ModuMod"
        dField["Strt"]       =   26
        dField["Stop"]       =   30
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "LeSel"
        dField["Strt"]       =   31
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 6
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R5_Dev"
        dReg["Adr"]          =   5
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   2
        dField["Val"]        =   5
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "DevWrd"
        dField["Strt"]       =   3
        dField["Stop"]       =   18
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "DevOffs"
        dField["Strt"]       =   19
        dField["Stop"]       =   22
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "DevSel"
        dField["Strt"]       =   23
        dField["Stop"]       =   23
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "DualRamp"
        dField["Strt"]       =   24
        dField["Stop"]       =   24
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "FSKRamp"
        dField["Strt"]       =   25
        dField["Stop"]       =   25
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Int"
        dField["Strt"]       =   26
        dField["Stop"]       =   27
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "ParaRamp"
        dField["Strt"]       =   28
        dField["Stop"]       =   28
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "TxRampClk"
        dField["Strt"]       =   29
        dField["Stop"]       =   29
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "TxDataInv"
        dField["Strt"]       =   30
        dField["Stop"]       =   30
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   31
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 7
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R6_Step"
        dReg["Adr"]          =   6
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   2
        dField["Val"]        =   6
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "StepWrd"
        dField["Strt"]       =   3
        dField["Stop"]       =   22
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "StepSel"
        dField["Strt"]       =   23
        dField["Stop"]       =   23
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   24
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 8
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R7_Delay"
        dReg["Adr"]          =   7
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   2
        dField["Val"]        =   7
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "DelayStrt"
        dField["Strt"]       =   3
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "DelayStrtEna"
        dField["Strt"]       =   15
        dField["Stop"]       =   15
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "DelayClkSel"
        dField["Strt"]       =   16
        dField["Stop"]       =   16
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RampDelay"
        dField["Strt"]       =   17
        dField["Stop"]       =   17
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RampDelayFl"
        dField["Strt"]       =   18
        dField["Stop"]       =   18
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "FastRamp"
        dField["Strt"]       =   19
        dField["Stop"]       =   19
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "TxTrig"
        dField["Strt"]       =   20
        dField["Stop"]       =   20
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField
)
        dField               =   dict()
        dField["Name"]       =   "SingFullTri"
        dField["Strt"]       =   21
        dField["Stop"]       =   21
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "TriDelay"
        dField["Strt"]       =   22
        dField["Stop"]       =   22
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "TxTrigDelay"
        dField["Strt"]       =   23
        dField["Stop"]       =   23
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   24
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)
