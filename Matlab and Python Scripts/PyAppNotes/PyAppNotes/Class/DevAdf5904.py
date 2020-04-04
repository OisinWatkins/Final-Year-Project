#< @file        DevAdf5904.pyh
#< @author      Haderer Andreas (HaAn)
#< @date        2016-06-13
#< @brief       Class for configuration of Adf5904 receiver
#< @version     1.0.1
import  Class.DevDriver  as DevDriver
from    numpy import *


class DevAdf5904(DevDriver.DevDriver):

    # DOXYGEN ------------------------------------------------------
    #> @brief Class constructor
    #>
    #> Construct a class object to configure the receiver with an existing Frontend class object.
    #>
    #> @param[in]     Brd: Frontend class object
    #>
    #> @param[in]     USpiCfg: Configuration of USpi interface: access of device from the baseboard
    #>          -   <span style="color: #ff9900;"> 'Mask': </span>: Bitmask to select the device
    #>          -   <span style="color: #ff9900;"> 'Chn': </span>: Channel of USPI interface; TX is connected to this channel
    #>          -   <span style="color: #ff9900;"> 'Type': </span>: In the actual version only 'USpi' is supported for the type
    #>
    #> @return  Returns a object of the class with the desired USpi interface configuration
    #>
    def __init__(self, Brd, dUSpiCfg):
        super(DevAdf5904, self).__init__()

        self.stVers                 =   '1.0.0'
        self.USpiCfg_Mask           =   1
        self.USpiCfg_Chn            =   0
        self.USpiCfg_Type           =   'USpi'
        self.RegR3                  =   0;
        self.RegR2                  =   0
        self.RegR0                  =   0

        self.Brd                    =   Brd;
        if self.Brd.DebugInf > 10:
            print('ADF5904 Initialize')

        if not ('Mask' in dUSpiCfg):
            print('DevAdf5904: Mask not specified')
        else:
            self.USpiCfg_Mask       =   dUSpiCfg["Mask"]

        if not ('Chn' in dUSpiCfg):
            print('DevAdf5904: Chn not specified')
        else:
            self.USpiCfg_Chn        =   dUSpiCfg["Chn"]
        if not ('Type' in dUSpiCfg):
            self.USpiCfg_Type       =   'USpi'
        else:
            self.USpiCfg_Type       =   dUSpiCfg["Type"]

        self.DefineConst();

        self.RegR3      =   self.GenRegFlag('R3',0);
        self.RegR2      =   self.GenRegFlag('R2',0);
        self.RegR0      =   self.GenRegFlag('R0',0, 'PupLo', 1, 'PupChn1', 1, 'PupChn2', 1, 'PupChn3', 1, 'PupChn4', 1);

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
        print("ADF5904 Class Version: ", self.stVers)

    # DOXYGEN ------------------------------------------------------
    #> @brief Set device configuration
    #>
    #> This method is used to set the configuration of the device. A configuration structure is used to set the desired parameters.
    #> If a field is not present in the structure, then the parameter is not changed. The function only changes the local parameters of the class.
    #> The IniCfg methos must be called, so that the configuration takes place.
    #>
    #> @param[in]     Cfg: structure with the desired configuration
    #>          -   <span style="color: #ff9900;"> 'Rx1': </span>: Enable disable Rx1; 0 to disable, 1 to enable channel
    #>          -   <span style="color: #ff9900;"> 'Rx2': </span>: Enable disable Rx2; 0 to disable, 1 to enable channel
    #>          -   <span style="color: #ff9900;"> 'Rx3': </span>: Enable disable Rx3; 0 to disable, 1 to enable channel
    #>          -   <span style="color: #ff9900;"> 'Rx4': </span>: Enable disable Rx4; 0 to disable, 1 to enable channel
    #>          -   <span style="color: #ff9900;"> 'Lo': </span>: Enable disable Lo ; 0 to disable, 1 to enable channel
    #>          -   <span style="color: #ff9900;"> 'All': </span>: Enable disable all channels and Lo; 0 to disable, 1 to enable channel
    #>
    #> @return  Returns a object of the class with the desired USpi interface configuration
    #>
    #> e.g. Disable all receive channels and the LO path
    #>   @code
    #>   Brd        =   Radarbook('PNet','192.168.1.1')
    #>   USpiCfg.Mask   =   1
    #>   USpiCfg.Chn    =   1
    #>   Adf5904    =   DevAdf5904(Brd,USpiCfg)
    #>   Cfg.All        =   0
    #>   Adf5904.SetCfg(Cfg)
    #>   @endcode
    def     SetCfg(self, dCfg):
        if 'Rx1' in dCfg:
            self.RegR0      =   self.GenRegFlag('R0',self.RegR0, 'PupChn1', dCfg['Rx1'])
        if 'Rx2' in dCfg:
            self.RegR0      =   self.GenRegFlag('R0',self.RegR0, 'PupChn2', dCfg['Rx2'])
        if 'Rx3' in dCfg:
            self.RegR0      =   self.GenRegFlag('R0',self.RegR0, 'PupChn3', dCfg['Rx3'])
        if 'Rx4' in dCfg:
            self.RegR0      =   self.GenRegFlag('R0',self.RegR0, 'PupChn4', dCfg['Rx4'])
        if 'Lo' in dCfg:
            self.RegR0      =   self.GenRegFlag('R0',self.RegR0, 'PupLo', dCfg['Lo'])
        if 'All' in dCfg:
            self.RegR0      =   self.GenRegFlag('R0',self.RegR0, 'PupChn1', dCfg['All'], 'PupChn2', dCfg['All'], 'PupChn3', dCfg['All'], 'PupChn4', dCfg['All'], 'PupLo', dCfg['All'])



    # DOXYGEN ------------------------------------------------------
    #> @brief Set device register
    #>
    #> This method is used to set the configuration of the device. In this method the register value is altered directly.
    #> The user has to take care, that a valid register configuration is programmed.
    #> The method only alters the variable of the class.
    #>
    #> @param[in]     Cfg: structure with the desired regiser configuration
    #>          -   <span style="color: #ff9900;"> 'RegR0': </span>: Desired value for register R0
    #>          -   <span style="color: #ff9900;"> 'RegR2': </span>: Desired value for register R2
    #>          -   <span style="color: #ff9900;"> 'RegR3': </span>: Desired value for register R3
    #>
    def SetRegCfg(self, dCfg):
        if 'RegR0'  in dCfg:
            self.RegR0      =   dCfg["RegR0"]
        if 'RegR2'  in dCfg:
            self.RegR2      =   dCfg["RegR2"]
        if 'RegR3'  in dCfg:
            self.RegR3      =   dCfg["RegR3"]

    # DOXYGEN ------------------------------------------------------
    #> @brief Set device basic hardware and class configuration
    #>
    #> This method is used to set the configuration of the class
    #>
    #> @param[in]     Cfg: structure with the desired configuration
    #>          -   <span style="color: #ff9900;"> 'Mask': </span>: Mask of USPI interface
    #>          -   <span style="color: #ff9900;"> 'Chn': </span>: Channel of USPI interface <br>
    #>          -   <span style="color: #ff9900;"> 'Type': </span>: Type of configuration interface; currently only 'USpi' is supported <br>
    #>
    def DevSetCfg(self, dCfg):
        # reset this function is currently not implemented
        if 'Mask' in dCfg:
            self.USpiCfg_Mask   =   dCfg["Mask"]
        if 'Chn' in dCfg:
            self.USpiCfg_Chn    =   dCfg["Chn"]
        if 'Type' in dCfg:
            self.USpiCfg_Type   =   dCfg["Type"]

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
        #enable currently not implemented
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
    #> @brief Programm device registers to the receiver
    #>
    #> This function programms the register to the device. The function expects an array with register values. That are programmed to the device.
    #>
    #> @param[in]     Regs array with register values <br>
    #>                The register values are programmed to the device over the selected SPI interface.
    #>
    #> @return     Return code of the command
    def     DevSetReg(self, Regs):
        Ret     =   0
        Regs    =   Regs.flatten(1)

        if self.USpiCfg_Type == 'USpi':
            if len(Regs) > 28:
                Regs    =   Regs[0:28]
            print("Set Regs:", Regs)
            dUSpiCfg            =   dict()
            dUSpiCfg["Mask"]    =   self.USpiCfg_Mask;
            dUSpiCfg["Chn"]     =   self.USpiCfg_Chn;
            Ret                 =   self.Brd.Dsp_SendSpiData(dUSpiCfg, Regs)
        return  Ret

    # DOXYGEN ------------------------------------------------------
    #> @brief Programm device registers to the receiver directly
    #>
    #> Is identical to DevSetReg as no programming sequence is required.
    #>
    #> @param[in]     Regs array with register values number of entries must be smaller than 28 <br>
    #>                The register values are programmed to the device over the selected SPI interface.
    #>
    #> @return     Return code of the command
    def DevSetRegDirect(self, Regs):
        Ret     =   0
        Regs    =   Regs.flatten(1)
        if self.USpiCfg_Type == 'USpi':
            dUSpiCfg            =   dict()
            dUSpiCfg["Mask"]    =   self.USpiCfg_Mask;
            dUSpiCfg["Chn"]     =   self.USpiCfg_Chn;
            if len(Regs) > 28:
                Regs        =   Regs[0:28];
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
    #> This function generates the configuration from the settings programmed to the class object.
    #> First the registers are generated GenRegs() and thereafter the DevSetReg() method is called
    #>
    #>  @return     Return code of the DevSetReg method
    #>
    #> e.g. Configure the device: The following sequence enables all transmit channels on the device (default class setting)
    #>   @code
    #>   Brd        =   Radarbook('PNet','192.168.1.1')
    #>   USpiCfg.Mask   =   1
    #>   USpiCfg.Chn    =   1
    #>   Adf5904    =   DevAdf5904(Brd,USpiCfg)
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
        Data            =   zeros(8, dtype=uint32)
        Data[0]         =   self.RegR3
        Data[1]         =   self.RegR2
        Data[2]         =   self.GenRegFlag('R1', 0, 'ChnSel', 1)
        Data[3]         =   self.GenRegFlag('R1', 0, 'ChnSel', 2)
        Data[4]         =   self.GenRegFlag('R1', 0, 'ChnSel', 3)
        Data[5]         =   self.GenRegFlag('R1', 0, 'ChnSel', 4)
        Data[6]         =   int("0xA0000019",0)
        Data[7]         =   self.RegR0
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
        dField["Stop"]       =   1
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   2
        dField["Stop"]       =   7
        dField["Val"]        =   40
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "DoutVSel"
        dField["Strt"]       =   8
        dField["Stop"]       =   8
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "LoPinBias"
        dField["Strt"]       =   9
        dField["Stop"]       =   9
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupLo"
        dField["Strt"]       =   10
        dField["Stop"]       =   10
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupChn1"
        dField["Strt"]       =   11
        dField["Stop"]       =   11
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupChn2"
        dField["Strt"]       =   12
        dField["Stop"]       =   12
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupChn3"
        dField["Strt"]       =   13
        dField["Stop"]       =   13
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "PupChn4"
        dField["Strt"]       =   14
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   15
        dField["Stop"]       =   31
        dField["Val"]        =   65536
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
        dField["Stop"]       =   1
        dField["Val"]        =   1
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   2
        dField["Stop"]       =   28
        dField["Val"]        =   1318
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "ChnSel"
        dField["Strt"]       =   29
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   0
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
        dField["Stop"]       =   1
        dField["Val"]        =   2
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   2
        dField["Stop"]       =   9
        dField["Val"]        =   1
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "ChnTstSel"
        dField["Strt"]       =   10
        dField["Stop"]       =   14
        dField["Val"]        =   0
        dField["Res"]        =   0
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   15
        dField["Stop"]       =   31
        dField["Val"]        =   4
        dField["Res"]        =   1
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
        dField["Stop"]       =   1
        dField["Val"]        =   3
        dField["Res"]        =   1
        lFields.append(dField)

        dField               =   dict()
        dField["Name"]       =   "Res"
        dField["Strt"]       =   2
        dField["Stop"]       =   31
        dField["Val"]        =   0
        dField["Res"]        =   1
        lFields.append(dField)

        dReg["lFields"]      =   lFields
        self.lRegs.append(dReg)

