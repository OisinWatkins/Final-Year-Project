#< @file        DevAdf5901.m
#< @author      Haderer Andreas (HaAn)
#< @date        2013-06-13
#< @brief       Class for configuration of Adf5901 transmitter
#< @version     1.0.1
import  Class.DevDriver  as DevDriver
from    numpy import *

class DevAdf5901(DevDriver.DevDriver):


    # DOXYGEN ------------------------------------------------------
    #> @brief Class constructor
    #>
    #> Construct a class self.ct to configure the transmitter with an existing Frontend class self.ct.
    #>
    #> @param[in]     Brd: Radarbook or Frontend class self.ct
    #>
    #> @param[in]     USpiCfg: Configuration of USpi interface: access of device from the baseboard
    #>          -   <span style="color: #ff9900;"> 'Mask': </span>: Bitmask to select the device
    #>          -   <span style="color: #ff9900;"> 'Chn': </span>: Channel of USPI interface; TX is connected to this channel
    #>          -   <span style="color: #ff9900;"> 'Type': </span>: In the actual version only 'USpi' is supported for the type
    #>
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
        super(DevAdf5901, self).__init__()

        self.stVers             =   '1.0.1'
        self.USpiCfg_Mask       =   1
        self.USpiCfg_Chn        =   1
        self.USpiCfg_Type       =   'USpi'

        self.RfFreqStrt         =   24.125e9
        self.RfRefDiv           =   1
        self.RfSysClk           =   100e6
        self.RDiv2              =   2

        self.TxPwr              =   100
        self.RegR0Final         =   0


        self.Brd     =   Brd;
        if self.Brd.DebugInf > 10:
            print('ADF5901 Initialize')

        if not ('Mask' in dUSpiCfg):
            print('DevAdf5901: Mask not specified')
            self.USpiCfg_Mask   =   1
        else:
            self.USpiCfg_Mask   =   dUSpiCfg["Mask"]

        if not ('Chn' in dUSpiCfg):
            print('DevAdf5901: Chn not specified')
            self.USpiCfg_Chn    =   0
        else:
            self.USpiCfg_Chn    =   dUSpiCfg["Chn"]

        if not ('Type' in dUSpiCfg):
            self.USpiCfg_Type   =   'USpi'
        else:
            self.USpiCfg_Type   =   dUSpiCfg["Type"]

        self.DefineConst()
        self.RegR0Final         =   self.GenRegFlag('R0',0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 0, 'PupTx2', 0);


    # DOXYGEN ------------------------------------------------------
    #> @brief Get version information of Adf5901 class
    #>
    #> Get version of class
    #>      - Version String is returned as string
    #>
    #> @return  Returns the version string of the class (e.g. 0.5.0)
    def     GetVers(self):
        return self.stVers


    # DOXYGEN -------------------------------------------------
    #> @brief Displays version information in Matlab command window
    #>
    #> Display version of class in Matlab command window
    def     DispVers(self):
        print("ADF5901 Class Version: ", self.stVers)


    # DOXYGEN ------------------------------------------------------
    #> @brief Set device configuration
    #>
    #> This method is used to set the configuration of the device. A configuration structure is used to set the desired parameters.
    #> If a field is not present in the structure, then the parameter is not changed. The function only changes the local parameters of the class.
    #> The IniCfg methos must be called, so that the configuration takes place.
    #>
    #> @param[in]     Cfg: structure with the desired configuration
    #>          -   <span style="color: #ff9900;"> 'TxPwr': </span>: Desired transmit power; register setting 0 - 255
    #>          -   <span style="color: #ff9900;"> 'TxChn': </span>: Transmit channel to be enabled <br>
    #>              If set to 0, then only the LO generation is enabled <br>
    #>              If set to 1, then the first transmit antenna is activated
    #>              If set to 2, then the second transmit antenna is enabled
    #>
    #> @return  Returns a self.ct of the class with the desired USpi interface configuration
    #>
    #> e.g. Enable the first TX antenna and set the power to 100
    #>   @code
    #>   Brd        =   Radarbook('PNet','192.168.1.1')
    #>   USpiCfg.Mask   =   1
    #>   USpiCfg.Chn    =   1
    #>   Adf5901    =   DevAdf5901(Brd,USpiCfg)
    #>   Cfg.TxPwr      =   100
    #>   Cfg.TxChn      =   1
    #>   Adf5901.SetCfg(Cfg)
    #>   @endcode
    def     SetCfg(self, dCfg):
        if 'TxPwr' in dCfg:
            self.TxPwr          =   (dCfg["TxPwr"] % 256)
        if 'TxChn' in dCfg:
            if dCfg["TxChn"]    == 0:
                self.RegR0Final      =   self.GenRegFlag('R0',self.RegR0Final, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 0, 'PupTx2', 0);
            elif dCfg["TxChn"]  == 1:
                self.RegR0Final      =   self.GenRegFlag('R0',self.RegR0Final, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 1, 'PupTx2', 0);
            elif dCfg["TxChn"]  == 2:
                self.RegR0Final      =   self.GenRegFlag('R0',self.RegR0Final, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 0, 'PupTx2', 1);
            else:
                self.RegR0Final      =   self.GenRegFlag('R0',self.RegR0Final, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 0, 'PupTx2', 0);

    # DOXYGEN ------------------------------------------------------
    #> @brief Set device register
    #>
    #> This method is used to set the configuration of the device. In this method the register value is altered directly.
    #> The user has to take care, that a valid register configuration is programmed.
    #> The method only alters the variable of the class.
    #>
    #> @param[in]     Cfg: structure with the desired regiser configuration
    #>          -   <span style="color: #ff9900;"> 'RegR0': </span>: Desired value for register R0
    #>
    def     SetRegCfg(self, dCfg):
        if 'RegR0' in dCfg:
            self.RegR0Final      =   dCfg["RegR0"]


    # DOXYGEN ------------------------------------------------------
    #> @brief Set device basic hardware and class configuration
    #>
    #> This method is used to set the configuration of the class
    #>
    #> @param[in]     Cfg: structure with the desired configuration
    #>          -   <span style="color: #ff9900;"> 'Mask': </span>: Mask of USPI interface
    #>          -   <span style="color: #ff9900;"> 'Chn': </span>: Channel of USPI interface <br>
    #>          -   <span style="color: #ff9900;"> 'Type': </span>: Type of configuration interface; currently only 'USpi' is supported <br>
    #>          -   <span style="color: #ff9900;"> 'RfFreqStrt': </span>: RF start frequency of transmitter <br>
    #>          -   <span style="color: #ff9900;"> 'RfRevDiv': </span>: RF reference divider for PLL <br>
    #>          -   <span style="color: #ff9900;"> 'RfSysClk': </span>: Input clock frequency <br>
    #>
    def     DevSetCfg(self, dCfg):
        if 'Mask' in dCfg:
            self.USpiCfg_Mask       =   dCfg["Mask"]
        if 'Chn' in dCfg:
            self.USpiCfg_Chn        =   dCfg["Chn"]
        if 'Type' in dCfg:
            self.USpiCfg_Type       =   dCfg["Type"]
        if 'RfFreqStrt' in dCfg:
            self.RfFreqStrt         =   dCfg["RfFreqStrt"]
        if 'RfRefDiv' in dCfg:
            self.RfRefDiv           =   dCfg["RfRefDiv"]
        if 'RfSysClk' in dCfg:
            self.RfSysClk           =   dCfg["RfSysClk"]

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
    #> @brief Programm device registers to the transmitter
    #>
    #> This function programms the register to the device. The function expects an array with 19 register values according to the
    #> device data sheet. In addition, a valid Radarbook self.ct must be stated at the class constructor.
    #>
    #> @param[in]     Regs array with register values <br>
    #>                The register values are programmed to the device over the selected SPI interface. The device registers are programmed according
    #>                to the following sequence. This ensures the timing constraints of the device.
    #>          - With the first command the registers 1-13 are programmed
    #>          - With the second command the registers 14-15 are programmed
    #>          - With the third command the registers 16 -17 are programmed
    #>          - With the fourth command the residual registers are set
    #>
    #> @return     Return code of the command
    def     DevSetReg(self, Regs):
        Ret     =   -1
        if self.USpiCfg_Type == 'USpi':
            dUSpiCfg            =   dict()
            dUSpiCfg["Mask"]    =   self.USpiCfg_Mask
            dUSpiCfg["Chn"]     =   self.USpiCfg_Chn
            self.Brd.Dsp_SendSpiData(dUSpiCfg, Regs[0:13])
            self.Brd.Dsp_SendSpiData(dUSpiCfg, Regs[13:15])
            self.Brd.Dsp_SendSpiData(dUSpiCfg, Regs[15:17])
            Ret                 =   self.Brd.Dsp_SendSpiData(dUSpiCfg, Regs[17:19])

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
        if self.USpiCfg_Type == 'USpi':
            dUSpiCfg            =   dict()
            dUSpiCfg["Mask"]    =   self.USpiCfg_Mask
            dUSpiCfg["Chn"]     =   self.USpiCfg_Chn
            if len(Regs) > 28:
                Regs        =   Regs[0:28]
            Ret     =   self.Brd.Dsp_SendSpiData(dUSpiCfg, Regs)
        return Ret


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
    #> This function generates the configuration from the settings programmed to the class self.ct.
    #> First the registers are generated GenRegs() and thereafter the DevSetReg() method is called
    #>
    #>  @return     Return code of the DevSetReg method
    #>
    #> e.g. Enable the first TX antenna and set the power to 100 and call the Ini function. In this case the transmitted is
    #>      configured
    #>   @code
    #>   Brd        =   Radarbook('PNet','192.168.1.1')
    #>   USpiCfg.Mask   =   1
    #>   USpiCfg.Chn    =   1
    #>   Adf5901    =   DevAdf5901(Brd,USpiCfg)
    #>   Cfg.TxPwr      =   100
    #>   Cfg.TxChn      =   1
    #>   Adf5901.SetCfg(Cfg)
    #>   Adf5901.Ini()
    #>   @endcode
    def     Ini(self):
        Data            =   self.GenRegs()
        Ret             =   self.DevSetReg(Data)


    # DOXYGEN ------------------------------------------------------
    #> @brief This function generates the register values for the device
    #>
    #> This function generates the register values for the device according to the sequence state in the datasheet.
    #> The class settings are automatically included in the generated registers.
    #>
    #> @return     Array with device register values.
    #>
    #> @note If the standard configuration is used. The Ini method should be called to configure the device.
    def     GenRegs(self):

        Data            =   zeros(19, dtype = uint32)
        #--------------------------------------------------------------
        # Initialize Register 7:
        # Master Reset
        #--------------------------------------------------------------
        Data[0]         =   self.GenRegFlag('R7', 0 , 'MsRst', 1)
        #--------------------------------------------------------------
        # Initialize Register 10:
        # Reserved
        #--------------------------------------------------------------
        Data[1]         =   self.GenRegFlag('R10', 0 )
        #--------------------------------------------------------------
        # Initialize Register 9:
        # Reserved
        #--------------------------------------------------------------
        Data[2]         =   self.GenRegFlag('R9', 0 )
        #--------------------------------------------------------------
        # Initialize Register 8:
        # Requency divider for calibration
        #--------------------------------------------------------------
        Data[3]         =   self.GenRegFlag('R8', 0, 'FreqCalDiv', 500) #
        #--------------------------------------------------------------
        # Initialize Register 0:
        # Reserved
        #--------------------------------------------------------------
        Data[4]         =   self.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupAdc', 1, 'PupVco', 1, 'PupLo', 1) #0x809FE520
        #--------------------------------------------------------------
        # Initialize Register 7:
        # Mater reset
        #--------------------------------------------------------------
        if self.RDiv2 > 1:
            Flag        =   1
        else:
            Flag        =   0
        Data[5]         =   self.GenRegFlag('R7', 0, 'RDiv', self.RfRefDiv, 'ClkDiv', 500, 'RDiv2', Flag) #0x011F4827,


        RefClk          =   self.RfSysClk/self.RfRefDiv/self.RDiv2
        Div             =   self.RfFreqStrt/(2*RefClk)
        DivInt          =   floor(Div)
        DivFrac         =   round((Div - DivInt) * 2**25)
        DivFracMsb      =   DivFrac/2**13
        DivFracLsb      =   DivFrac % 2**13

        #--------------------------------------------------------------
        # Initialize Register 6:
        # Reserved: Frac LSB:
        #--------------------------------------------------------------
        Data[6]         =   self.GenRegFlag('R6', 0, 'FracLsb', DivFracLsb)
        #--------------------------------------------------------------
        # Initialize Register 5:
        # Reserved: Frac MSB:
        #--------------------------------------------------------------
        Data[7]         =   self.GenRegFlag('R5', 0, 'FracMsb', DivFracMsb, 'Int', DivInt) #0x01E28005
        #--------------------------------------------------------------
        # Initialize Register 4:
        # Analog Test Bus Configuration
        #--------------------------------------------------------------
        Data[8]         =   self.GenRegFlag('R4', 0) #0x00200004
        #--------------------------------------------------------------
        # Initialize Register 3:
        # Io Configuration
        #--------------------------------------------------------------
        Data[9]         =   self.GenRegFlag('R3', 0, 'ReadBackCtrl', 0, 'IoLev', 1, 'MuxOut', 0)
        #--------------------------------------------------------------
        # Initialize Register 2:
        # Adc configuration
        #--------------------------------------------------------------
        Data[10]        =   int("0x00020642",0)#self.GenRegFlag('R2', 0, 'AdcClkDiv', 100, 'AdcAv', 0)
        #--------------------------------------------------------------
        # Initialize Register 1:
        # Tx Amplitude Calibration
        #--------------------------------------------------------------
        Data[11]        =   self.GenRegFlag('R1', 0, 'TxAmpCalRefCode', self.TxPwr)
        #--------------------------------------------------------------
        # Initialize Register 0:
        # Enable and Calibration: Calibrate VCO
        #--------------------------------------------------------------
        Data[12]        =   self.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'VcoCal', 1, 'PupAdc', 1)
        #--------------------------------------------------------------
        # Initialize Register 0:
        # Enable and Calibration: Tx1 On, Lo On, VCO On
        #--------------------------------------------------------------
        Data[13]        =   self.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'PupTx1', 1, 'PupLo', 1, 'PupAdc', 1)
        #--------------------------------------------------------------
        # Initialize Register 0:
        # Enable and Calibration: Tx1 Amplitude Calibration
        #--------------------------------------------------------------
        Data[14]        =   self.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'PupTx1', 1, 'PupLo', 1, 'Tx1AmpCal', 1, 'PupAdc', 1)
        #--------------------------------------------------------------
        # Initialize Register 0:
        # Enable and Calibration: Tx2 On, Lo On, VCO on
        #--------------------------------------------------------------
        Data[15]        =   self.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'PupTx2', 1, 'PupLo', 1, 'PupAdc', 1)
        #--------------------------------------------------------------
        # Initialize Register 0:
        # Enable and Calibration: Tx2 Amplitude Calibration
        #--------------------------------------------------------------
        Data[16]        =   self.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'PupTx2', 1, 'PupLo', 1, 'Tx2AmpCal', 1, 'PupAdc', 1)
        #--------------------------------------------------------------
        # Initialize Register 9:
        # ??? R9 ENABLES VTUNE INPUT!!!!!!!!!!!!
        #--------------------------------------------------------------
        #Data        =   [Data; self.GenRegFlag('R9', 0)];
        Data[17]        =   int ('0x2800B929',0)

        #--------------------------------------------------------------
        # Initialize Register 0:
        # R0
        #--------------------------------------------------------------
        Data[18]        =   self.RegR0Final

        return Data


    def DefineConst(self):
        # ----------------------------------------------------
        # Define Register 1
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R0"
        dReg["Adr"]          =   0
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupLo"
        dField["Strt"]       =   5
        dField["Stop"]       =   5
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupTx1"
        dField["Strt"]       =   6
        dField["Stop"]       =   6
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupTx2"
        dField["Strt"]       =   7
        dField["Stop"]       =   7
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupAdc"
        dField["Strt"]       =   8
        dField["Stop"]       =   8
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "VcoCal"
        dField["Strt"]       =   9
        dField["Stop"]       =   9
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupVco"
        dField["Strt"]       =   10
        dField["Stop"]       =   10
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Tx1AmpCal"
        dField["Strt"]       =   11
        dField["Stop"]       =   11
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Tx2AmpCal"
        dField["Strt"]       =   12
        dField["Stop"]       =   12
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   13
        dField["Stop"]       =   13
        dField["Val"]        =   1
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupNCntr"
        dField["Strt"]       =   14
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupRCntr"
        dField["Strt"]       =   15
        dField["Stop"]       =   15
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   16
        dField["Stop"]       =   19
        dField["Val"]        =   15
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "AuxDiv"
        dField["Strt"]       =   20
        dField["Stop"]       =   20
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "AuxBufGain"
        dField["Strt"]       =   21
        dField["Stop"]       =   23
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   24
        dField["Stop"]       =   31
        dField["Val"]        =   128
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 2
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R1"
        dReg["Adr"]          =   1
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   1
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "TxAmpCalRefCode"
        dField["Strt"]       =   5
        dField["Stop"]       =   12
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   13
        dField["Stop"]       =   31
        dField["Val"]        =   524207
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 3
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R2"
        dReg["Adr"]          =   2
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   2
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "AdcClkDiv"
        dField["Strt"]       =   5
        dField["Stop"]       =   12
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "AdcAv"
        dField["Strt"]       =   13
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "AdcStrt"
        dField["Strt"]       =   15
        dField["Stop"]       =   15
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   16
        dField["Stop"]       =   31
        dField["Val"]        =   2
        dField["Res"]        =   0
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 4
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R3"
        dReg["Adr"]          =   3
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   3
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "ReadBackCtrl"
        dField["Strt"]       =   5
        dField["Stop"]       =   10
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "IoLev"
        dField["Strt"]       =   11
        dField["Stop"]       =   11
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "MuxOut"
        dField["Strt"]       =   12
        dField["Stop"]       =   15
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   16
        dField["Stop"]       =   31
        dField["Val"]        =   393
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 5
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R4"
        dReg["Adr"]          =   4
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   4
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "AnaTstBus"
        dField["Strt"]       =   5
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "TstBusToPin"
        dField["Strt"]       =   15
        dField["Stop"]       =   15
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "TstBusToAdc"
        dField["Strt"]       =   16
        dField["Stop"]       =   16
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   17
        dField["Stop"]       =   31
        dField["Val"]        =   16
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 6
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R5"
        dReg["Adr"]          =   5
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   5
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "FracMsb"
        dField["Strt"]       =   5
        dField["Stop"]       =   16
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Int"
        dField["Strt"]       =   17
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
        # Define Register 7
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R6"
        dReg["Adr"]          =   6
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   6
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "FracLsb"
        dField["Strt"]       =   5
        dField["Stop"]       =   17
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   18
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
        dReg["Name"]         =   "R7"
        dReg["Adr"]          =   7
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   7
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RDiv"
        dField["Strt"]       =   5
        dField["Stop"]       =   9
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RefDoub"
        dField["Strt"]       =   10
        dField["Stop"]       =   10
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "RDiv2"
        dField["Strt"]       =   11
        dField["Stop"]       =   11
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "ClkDiv"
        dField["Strt"]       =   12
        dField["Stop"]       =   23
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   24
        dField["Stop"]       =   24
        dField["Val"]        =   1
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "MsRst"
        dField["Strt"]       =   25
        dField["Stop"]       =   25
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   26
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 9
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R8"
        dReg["Adr"]          =   8
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   8
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "FreqCalDiv"
        dField["Strt"]       =   5
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   15
        dField["Stop"]       =   31
        dField["Val"]        =   32768
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 10
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R9"
        dReg["Adr"]          =   9
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   9
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   5
        dField["Stop"]       =   31
        dField["Val"]        =   22087113
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

        # ----------------------------------------------------
        # Define Register 11
        # ----------------------------------------------------
        dReg                 =   dict()
        dReg["Name"]         =   "R10"
        dReg["Adr"]          =   10
        dReg["Val"]          =   0
        lFields              =   list()

        dField               =   dict()
        dField["Name"]       =   "Ctrl"
        dField["Strt"]       =   0
        dField["Stop"]       =   4
        dField["Val"]        =   10
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   5
        dField["Stop"]       =   31
        dField["Val"]        =   16777215
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

