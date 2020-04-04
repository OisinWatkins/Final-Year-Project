%< @file        DevAdf5901.m                                                                
%< @author      Haderer Andreas (HaAn)                                                  
%< @date        2013-06-13          
%< @brief       Class for configuration of Adf5901 transmitter
%< @version     1.0.1

classdef DevAdf5901<handle
    
    properties (Access = public)
        
    end

    properties (Access = private)
        Brd                         =   []
        caRegs                      =   cell(0);
        stVers                      =   '1.0.1';
        USpiCfg_Mask                =   1;
        USpiCfg_Chn                 =   1;
        USpiCfg_Type                =   'USpi';

        
        RfFreqStrt                  =   24.125e9;
        RfRefDiv                    =   1;
        RfSysClk                    =   100e6;
        RDiv2                       =   2;
        
        TxPwr                       =   100;
        RegR0Final                  =   0;
                       
    end
    
    methods (Access = public)

        % DOXYGEN ------------------------------------------------------
        %> @brief Class constructor
        %>
        %> Construct a class object to configure the transmitter with an existing Frontend class object.
        %>
        %> @param[in]     Brd: Radarbook or Frontend class object         
        %>
        %> @param[in]     USpiCfg: Configuration of USpi interface: access of device from the baseboard
        %>          -   <span style="color: #ff9900;"> 'Mask': </span>: Bitmask to select the device
        %>          -   <span style="color: #ff9900;"> 'Chn': </span>: Channel of USPI interface; TX is connected to this channel        
        %>          -   <span style="color: #ff9900;"> 'Type': </span>: In the actual version only 'USpi' is supported for the type        
        %>
        %> @return  Returns a object of the class with the desired USpi interface configuration
        %>
        %> e.g. with PNet TCP/IP functions
        %>   @code
        %>   Brd        =   Radarbook('PNet','192.168.1.1')
        %>   USpiCfg.Mask   =   1
        %>   USpiCfg.Chn    =   1
        %>   Adf5901    =   DevAdf5901(Brd,USpiCfg)
        %>   @endcode       
        function obj    =   DevAdf5901(Brd, USpiCfg)   
            obj.Brd     =   Brd; 
            if obj.Brd.DebugInf > 10
                disp('ADF5901 Initialize')
            end
            if ~isfield(USpiCfg, 'Mask')
                warning('DevAdf5901: Mask not specified')
                obj.USpiCfg_Mask    =   1;
            else
                obj.USpiCfg_Mask    =   USpiCfg.Mask;
            end
            if ~isfield(USpiCfg, 'Chn')
                warning('DevAdf5901: Chn not specified')
                obj.USpiCfg_Chn     =   0;
            else
                obj.USpiCfg_Chn     =   USpiCfg.Chn;   
            end
            if ~isfield(USpiCfg, 'Type')
                obj.USpiCfg_Type    =   'USpi';
            else
                obj.USpiCfg_Type    =   USpiCfg.Type;
            end
            
            obj.DefineConst();
            obj.RegR0Final      =   obj.GenRegFlag('R0',0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 0, 'PupTx2', 0);
            
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Class destructor
        %>
        %> Delete class object            
        function delete(obj)           
        end
        
        % DOXYGEN ------------------------------------------------------
        %> @brief Get version information of Adf5901 class
        %>
        %> Get version of class 
        %>      - Version String is returned as string
        %>
        %> @return  Returns the version string of the class (e.g. 0.5.0)   
        function Ret    =   GetVers(obj)          
            Ret         =   obj.stVers
        end
            

        % DOXYGEN -------------------------------------------------
        %> @brief Displays version information in Matlab command window  
        %>
        %> Display version of class in Matlab command window             
        function DispVers(obj)         
            disp(['ADF5901 Class Version: ', obj.stVers])
        end
        
        % DOXYGEN ------------------------------------------------------
        %> @brief Set device configuration
        %>
        %> This method is used to set the configuration of the device. A configuration structure is used to set the desired parameters.
        %> If a field is not present in the structure, then the parameter is not changed. The function only changes the local parameters of the class.
        %> The IniCfg methos must be called, so that the configuration takes place.       
        %>
        %> @param[in]     Cfg: structure with the desired configuration
        %>          -   <span style="color: #ff9900;"> 'TxPwr': </span>: Desired transmit power; register setting 0 - 255
        %>          -   <span style="color: #ff9900;"> 'TxChn': </span>: Transmit channel to be enabled <br>
        %>              If set to 0, then only the LO generation is enabled <br>
        %>              If set to 1, then the first transmit antenna is activated
        %>              If set to 2, then the second transmit antenna is enabled
        %>
        %> @return  Returns a object of the class with the desired USpi interface configuration
        %>
        %> e.g. Enable the first TX antenna and set the power to 100
        %>   @code
        %>   Brd        =   Radarbook('PNet','192.168.1.1')
        %>   USpiCfg.Mask   =   1
        %>   USpiCfg.Chn    =   1
        %>   Adf5901    =   DevAdf5901(Brd,USpiCfg)
        %>   Cfg.TxPwr      =   100
        %>   Cfg.TxChn      =   1
        %>   Adf5901.SetCfg(Cfg)
        %>   @endcode           
        function SetCfg(obj, Cfg)
            if isfield(Cfg, 'TxPwr')
                obj.TxPwr           =   mod(Cfg.TxPwr, 256);
            end
            if isfield(Cfg, 'TxChn')
                switch (Cfg.TxChn)
                    case 0
                        obj.RegR0Final      =   obj.GenRegFlag('R0',obj.RegR0Final, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 0, 'PupTx2', 0);
                    case 1
                        obj.RegR0Final      =   obj.GenRegFlag('R0',obj.RegR0Final, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 1, 'PupTx2', 0);
                    case 2
                        obj.RegR0Final      =   obj.GenRegFlag('R0',obj.RegR0Final, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 0, 'PupTx2', 1);
                    otherwise
                        obj.RegR0Final      =   obj.GenRegFlag('R0',obj.RegR0Final, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupLo', 1, 'PupAdc', 1, 'PupTx1', 0, 'PupTx2', 0);
                end
            end

        end
        
        % DOXYGEN ------------------------------------------------------
        %> @brief Set device register
        %>
        %> This method is used to set the configuration of the device. In this method the register value is altered directly.      
        %> The user has to take care, that a valid register configuration is programmed.
        %> The method only alters the variable of the class.
        %>
        %> @param[in]     Cfg: structure with the desired regiser configuration
        %>          -   <span style="color: #ff9900;"> 'RegR0': </span>: Desired value for register R0
        %> 
        function SetRegCfg(obj, Cfg)
            if isfield(Cfg, 'RegR0')
                obj.RegR0Final      =   Cfg.RegR0;
            end

        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Set device basic hardware and class configuration   
        %>
        %> This method is used to set the configuration of the class     
        %>
        %> @param[in]     Cfg: structure with the desired configuration
        %>          -   <span style="color: #ff9900;"> 'Mask': </span>: Mask of USPI interface
        %>          -   <span style="color: #ff9900;"> 'Chn': </span>: Channel of USPI interface <br>
        %>          -   <span style="color: #ff9900;"> 'Type': </span>: Type of configuration interface; currently only 'USpi' is supported <br>
        %>          -   <span style="color: #ff9900;"> 'RfFreqStrt': </span>: RF start frequency of transmitter <br>
        %>          -   <span style="color: #ff9900;"> 'RfRevDiv': </span>: RF reference divider for PLL <br>
        %>          -   <span style="color: #ff9900;"> 'RfSysClk': </span>: Input clock frequency <br>
        %>  
        function DevSetCfg(obj, Cfg)
            if isfield(Cfg, 'Mask')
                obj.USpiCfg_Mask    =   Cfg.Mask;
            end
            if isfield(Cfg, 'Chn')
                obj.USpiCfg_Chn     =   Cfg.Chn;
            end
            if isfield(Cfg, 'Type')
                obj.USpiCfg_Type    =   Cfg.Type;
            end
            if isfield(Cfg, 'RfFreqStrt')
                obj.RfFreqStrt      =   Cfg.RfFreqStrt;
            end
            if isfield(Cfg, 'RfRefDiv')
                obj.RfRefDiv        =   Cfg.RfRefDiv;
            end
            if isfield(Cfg, 'RfSysClk')
                obj.RfSysClk        =   Cfg.RfSysClk;
            end
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Reset device
        %>
        %> Not yet implemented; Function call has no effect; 
        %> Standard device driver function
        function DevRst(obj)
        % reset currently not implemented
        end
    
        % DOXYGEN ------------------------------------------------------
        %> @brief Enable device
        %>
        %> Not yet implemented; Function call has no effect; 
        %> Standard device driver function
        function DevEna(obj)
        % enable currently not implemented
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Disable device
        %>
        %> Not yet implemented; Function call has no effect; 
        %> Standard device driver function
        function DevDi(obj)
        % disable currently not implemented
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Programm device registers to the transmitter 
        %>  
        %> This function programms the register to the device. The function expects an array with 19 register values according to the 
        %> device data sheet. In addition, a valid Radarbook object must be stated at the class constructor.
        %>
        %> @param[in]     Regs array with register values <br>
        %>                The register values are programmed to the device over the selected SPI interface. The device registers are programmed according
        %>                to the following sequence. This ensures the timing constraints of the device.
        %>          - With the first command the registers 1-13 are programmed
        %>          - With the second command the registers 14-15 are programmed
        %>          - With the third command the registers 16 -17 are programmed
        %>          - With the fourth command the residual registers are set
        %>
        %> @return     Return code of the command
        function Ret    =   DevSetReg(obj, Regs)
            Ret     =   [];
            Regs    =   Regs(:);
            if strcmp(obj.USpiCfg_Type,'USpi')
                
                USpiCfg.Mask    =   obj.USpiCfg_Mask;
                USpiCfg.Chn     =   obj.USpiCfg_Chn;
                
                obj.Brd.Fpga_SetUSpiData(USpiCfg, Regs(1:13));
                obj.Brd.Fpga_SetUSpiData(USpiCfg, Regs(14:15));
                obj.Brd.Fpga_SetUSpiData(USpiCfg, Regs(16:17));
                Ret             =   obj.Brd.Fpga_SetUSpiData(USpiCfg, Regs(18:19));
            
            end
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Programm device registers to the transmitter directly
        %>  
        %> This function programms the register to the device, without caring for timing constraints. 
        %>
        %> @param[in]     Regs array with register values number of entries must be smaller than 28 <br>
        %>                The register values are programmed to the device over the selected SPI interface. 
        %>
        %> @return     Return code of the command        
        function Ret    =   DevSetRegDirect(obj, Regs)
            Ret     =   [];
            Regs    =   Regs(:);
            if strcmp(obj.USpiCfg_Type,'USpi')
                
                USpiCfg.Mask    =   obj.USpiCfg_Mask;
                USpiCfg.Chn     =   obj.USpiCfg_Chn;

                if numel(Regs) > 28
                    Regs        =   Regs(1:28);
                end
                
                Ret     =   obj.Brd.Fpga_SetUSpiData(USpiCfg, Regs);
            end
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Get device registers
        %>
        %> Not yet implemented; Function call has no effect; 
        %> Standard device driver function
        function DevGetReg(obj, Regs)
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Initialize device
        %>  
        %> This function generates the configuration from the settings programmed to the class object.
        %> First the registers are generated GenRegs() and thereafter the DevSetReg() method is called
        %>
        %>  @return     Return code of the DevSetReg method  
        %>  
        %> e.g. Enable the first TX antenna and set the power to 100 and call the Ini function. In this case the transmitted is 
        %>      configured
        %>   @code
        %>   Brd        =   Radarbook('PNet','192.168.1.1')
        %>   USpiCfg.Mask   =   1
        %>   USpiCfg.Chn    =   1
        %>   Adf5901    =   DevAdf5901(Brd,USpiCfg)
        %>   Cfg.TxPwr      =   100
        %>   Cfg.TxChn      =   1
        %>   Adf5901.SetCfg(Cfg)
        %>   Adf5901.Ini()
        %>   @endcode     
        function Ret    =   Ini(obj) 
            Data            =   obj.GenRegs();
            Ret             =   obj.DevSetReg(Data);
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief This function generates the register values for the device
        %>  
        %> This function generates the register values for the device according to the sequence state in the datasheet.
        %> The class settings are automatically included in the generated registers.
        %>
        %> @return     Array with device register values.
        %>
        %> @note If the standard configuration is used. The Ini method should be called to configure the device.
        function Data   =   GenRegs(obj)   
                      
            Data            =   [];
            %--------------------------------------------------------------
            % Initialize Register 7:
            % Master Reset
            %--------------------------------------------------------------
            Data            =   [Data; obj.GenRegFlag('R7',0 , 'MsRst', 1)];
            %--------------------------------------------------------------
            % Initialize Register 10:
            % Reserved
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R10', 0 )];
            %--------------------------------------------------------------
            % Initialize Register 9:
            % Reserved
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R9', 0 )];
            %--------------------------------------------------------------
            % Initialize Register 8:
            % Requency divider for calibration
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R8', 0, 'FreqCalDiv', 1000)];
            %--------------------------------------------------------------
            % Initialize Register 0:
            % Reserved
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupVco', 1, 'PupAdc', 1)];
            %--------------------------------------------------------------
            % Initialize Register 7:
            % Mater reset
            %--------------------------------------------------------------
            if obj.RDiv2 > 1
                Flag        =   1;
            else
                Flag        =   0;
            end
            Data        =   [Data; obj.GenRegFlag('R7', 0, 'RDiv', obj.RfRefDiv, 'ClkDiv', 500,'RDiv2', Flag)];


            RefClk      =   obj.RfSysClk/obj.RfRefDiv/obj.RDiv2;
            Div         =   obj.RfFreqStrt/(2*RefClk);
            DivInt      =   floor(Div);
            DivFrac     =   round((Div - DivInt)*2^25);
            DivFracMsb  =   DivFrac/2^13;
            DivFracLsb  =   mod(DivFrac, 2^13);

            %--------------------------------------------------------------
            % Initialize Register 6:
            % Reserved: Frac LSB:
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R6', 0, 'FracLsb', DivFracLsb)];
            %--------------------------------------------------------------
            % Initialize Register 5:
            % Reserved: Frac MSB:
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R5', 0, 'FracMsb', DivFracMsb, 'Int', DivInt)];
            %--------------------------------------------------------------
            % Initialize Register 4:
            % Analog Test Bus Configuration
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R4', 0)];
            %--------------------------------------------------------------
            % Initialize Register 3:
            % Io Configuration
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R3', 0, 'ReadBackCtrl', 0, 'IoLev', 1, 'MuxOut', 0)];
            %--------------------------------------------------------------
            % Initialize Register 2:
            % Adc configuration
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R2', 0, 'AdcClkDiv', 80, 'AdcAv', 0)];
            %--------------------------------------------------------------
            % Initialize Register 1:
            % Tx Amplitude Calibration
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R1', 0, 'TxAmpCalRefCode', obj.TxPwr)];
            %--------------------------------------------------------------
            % Initialize Register 0:
            % Enable and Calibration: Calibrate VCO
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'VcoCal', 1, 'PupAdc', 1)];
            %--------------------------------------------------------------
            % Initialize Register 0:
            % Enable and Calibration: Tx1 On, Lo On, VCO On
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'PupTx1', 1, 'PupLo', 1, 'PupAdc', 1)];
            %--------------------------------------------------------------
            % Initialize Register 0:
            % Enable and Calibration: Tx1 Amplitude Calibration
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'PupTx1', 1, 'PupLo', 1, 'Tx1AmpCal', 1, 'PupAdc', 1)];
            %--------------------------------------------------------------
            % Initialize Register 0:
            % Enable and Calibration: Tx2 On, Lo On, VCO on
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'PupTx2', 1, 'PupLo', 1, 'PupAdc', 1)];
            %--------------------------------------------------------------
            % Initialize Register 0:
            % Enable and Calibration: Tx2 Amplitude Calibration
            %--------------------------------------------------------------
            Data        =   [Data; obj.GenRegFlag('R0', 0, 'AuxBufGain', 4, 'AuxDiv', 1, 'PupNCntr', 1, 'PupRCntr', 1, 'PupVco', 1, 'PupTx2', 1, 'PupLo', 1, 'Tx2AmpCal', 1, 'PupAdc', 1)];
            %--------------------------------------------------------------
            % Initialize Register 9:
            % ??? R9 ENABLES VTUNE INPUT!!!!!!!!!!!!
            %--------------------------------------------------------------
            %Data        =   [Data; obj.GenRegFlag('R9', 0)];
            Data        =   [Data; hex2dec('2800B929')];

            %--------------------------------------------------------------
            % Initialize Register 0:
            % R0
            %--------------------------------------------------------------
            Data        =   [Data; obj.RegR0Final];
            
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Generate register values with class predefined flags
        %>  
        %> This function can be used to generate register values. The function automatically ensures that reserver bits are preserved.
        %>
        %>  @param[in]  AdrName: if value is a number than it is interpreted as address; if the value is a string, then as the register name
        %>
        %>  @param[in]  Ini value of the register
        %>  
        %>  @param[in]  variable number of flags and values for the flags: e.g. , 'Div', 1: if the divider flag exists
        %>
        %>  @return     Value of the register
        %>       
        %>
        %> e.g. Generate register values with flags
        %>   @code
        %>   Brd        =   Radarbook('PNet','192.168.1.1')
        %>   Adf5901    =   DevAdf5901(Brd,USpiCfg)
        %>   RegR0      =   Adf5901.GenRegFlg('R0', 0, 'PupLo', 1, 'PupTx1', 2)
        %>   @endcode   
        function RegVal     =   GenRegFlag(obj, AdrName, Ini, varargin)           
            if isstr(AdrName)
                RegIdx      =   obj.FindRegByName(AdrName); 
                NArg        =   nargin - 2;
                ArgIdx      =   1;
                RegVal      =   Ini;
                while ArgIdx < NArg
                    RemArg  =   NArg - ArgIdx;
                    if mod(RemArg ,2) == 0
                        stField     =   varargin{ArgIdx};
                        Val         =   varargin{ArgIdx+1};    
                        RegVal      =   obj.GenRegSetField(RegVal, RegIdx, stField, Val);    
                        ArgIdx = ArgIdx + 2;
                    else
                        ArgIdx = NArg;
                    end
                end
                RegVal      =   obj.GenRegSetDefault(RegVal, RegIdx);
            else
                
            end
        
        end
        
        % DOXYGEN ------------------------------------------------------
        %> @brief Print register map in Matlab command window
        %>  
        %> Print register map in the command window of Matlab. This function can be used to find the names of the registers.
        %> 
        %> e.g. After calling the function the register map is printed 
        %> @code
        %> Register Name:  R0 @Adr: 0
        %> Register Name:  R1 @Adr: 1
        %> Register Name:  R2 @Adr: 2
        %> Register Name:  R3 @Adr: 3
        %> Register Name:  R4 @Adr: 4
        %> Register Name:  R5 @Adr: 5
        %> Register Name:  R6 @Adr: 6
        %> Register Name:  R7 @Adr: 7
        %> Register Name:  R8 @Adr: 8
        %> Register Name:  R9 @Adr: 9
        %> Register Name:  R10 @Adr: 10
        %> @endcode                      
        function PrntRegMap(obj, varargin)        
            for Idx = 1:numel(obj.caRegs)
                disp(['Register Name:  ', obj.caRegs{Idx}.Name, ' @Adr: ', num2str(obj.caRegs{Idx}.Adr)])
            end
        end
        
        % DOXYGEN ------------------------------------------------------
        %> @brief Print flags of registers in Matlab command window
        %>  
        %> This function can be used to find the names of the flags.
        %>   
        %> @param[in]   Name of register (optional)
        %>
        %> After calling the function with argument 'R0' the flags for R0 are printed in the command window
        %>  @code
        %> Reg: R0 @Adr: 0
        %>   Field: Ctrl
        %>   Field: PupLo
        %>   Field: PupTx1
        %>   Field: PupTx2
        %>   Field: PupAdc
        %>   Field: VcoCal
        %>   Field: PupVco
        %>   Field: Tx1AmpCal
        %>   Field: Tx2AmpCal
        %>   Field: Res
        %>   Field: PupNCntr
        %>   Field: PupRCntr
        %>   Field: Res
        %>   Field: AuxDiv
        %>   Field: AuxBufGain
        %>   Field: Res
        %>  @endcode
        function PrntRegFlags(obj, varargin)
            if nargin > 1
                if isstr(varargin{1})
                    RegIdx      =   obj.FindRegByName(varargin{1}); 
                    disp(['Reg: ', obj.caRegs{RegIdx}.Name, ' @Adr: ', num2str(obj.caRegs{RegIdx}.Adr)])
                    for FieldIdx = 1:numel(obj.caRegs{RegIdx}.Fields)
                        disp(['  Field: ', obj.caRegs{RegIdx}.Fields{FieldIdx}.Name])
                    end
                end
                    
            else
                for Idx = 1:numel(obj.caRegs)
                    disp(['Reg: ', obj.caRegs{Idx}.Name, ' @Adr: ', num2str(obj.caRegs{Idx}.Adr)])
                    for FieldIdx = 1:numel(obj.caRegs{Idx}.Fields)
                        disp(['  Field: ', obj.caRegs{Idx}.Fields{FieldIdx}.Name])
                    
                    end
                end                
            end
        end

        function GenPhyRegMap(obj, stFileName)    
            hFile   =   fopen(stFileName,'w')
        
            for Idx = 1:numel(obj.caRegs)
                fprintf(hFile,'# ----------------------------------------------------\n')
                fprintf(hFile,'# Define Register %d\n', Idx)
                fprintf(hFile,'# ----------------------------------------------------\n')
                fprintf(hFile,'dReg                 =   dict()\n')
                fprintf(hFile,'dReg["Name"]         =   "%s"\n',obj.caRegs{Idx}.Name)
                fprintf(hFile,'dReg["Adr"]          =   %d\n',obj.caRegs{Idx}.Adr)
                fprintf(hFile,'dReg["Val"]          =   %d\n',obj.caRegs{Idx}.Val)
                fprintf(hFile,'lFields              =   list()\n\n')
                
                
                for IdxField = 1:numel(obj.caRegs{Idx}.Fields)
                    fprintf(hFile,'dField               =   dict()\n')
                    fprintf(hFile,'dField["Name"]       =   "%s"\n', obj.caRegs{Idx}.Fields{IdxField}.Name)
                    fprintf(hFile,'dField["Strt"]       =   %d\n', obj.caRegs{Idx}.Fields{IdxField}.Strt)
                    fprintf(hFile,'dField["Stop"]       =   %d\n', obj.caRegs{Idx}.Fields{IdxField}.Stop)
                    fprintf(hFile,'dField["Val"]        =   %d\n', obj.caRegs{Idx}.Fields{IdxField}.Val)
                    fprintf(hFile,'dField["Res"]        =   %d\n', obj.caRegs{Idx}.Fields{IdxField}.Res)
                    fprintf(hFile,'lFields.append(dField)\n\n')
                end
                fprintf(hFile,'dReg["lFields"]      =   lFields\n')
                fprintf(hFile,'self.lRegs.append(dReg)\n\n')
                
              
            end
        end
        
    end

    
    
    methods (Access = protected)

        function Ret    =   IniCfg(self, Cfg)
            Ret     =   obj.Ini();
        end

        function RegVal     =   GenRegSetDefault(obj, RegVal, RegIdx)
        %   @function       GenRegSetDefault                                                             
        %   @author         Haderer Andreas (HaAn)                                                  
        %   @date           2015-07-27          
        %   @brief          Set default value: ensure res and adr field
        %   values
        %   @param[in]      RegVal: register value
        %   @param[in]      RegIdx: Index of register in caRegs array 
            Fields      =   obj.caRegs{RegIdx}.Fields;
            RegVal      =   RegVal;
            for Idx = 1:numel(Fields)
                if strcmp(Fields{Idx}.Name, 'Res')
                    Low         =   2.^Fields{Idx}.Strt;
                    High        =   2.^(Fields{Idx}.Stop + 1);
                    Lim         =   2.^(Fields{Idx}.Stop + 1 - Fields{Idx}.Strt);
                    RegValLow   =   mod(RegVal, Low);
                    RegValHigh  =   floor(RegVal/High);
                    Val         =   mod(Fields{Idx}.Val,Lim);
                    RegVal      =   RegValLow + Val.*Low + RegValHigh*High;
                    %disp([ 'Res :', dec2hex(RegVal)])
                end
                if strcmp(Fields{Idx}.Name, 'Ctrl')
                    Low         =   2.^Fields{Idx}.Strt;
                    High        =   2.^(Fields{Idx}.Stop + 1);
                    Lim         =   2.^(Fields{Idx}.Stop + 1 - Fields{Idx}.Strt);
                    RegValLow   =   mod(RegVal, Low);
                    RegValHigh  =   floor(RegVal/High);
                    Val         =   mod(Fields{Idx}.Val,Lim);
                    RegVal      =   RegValLow + Val.*Low + RegValHigh*High;
                    %disp([ 'Ctrl :', dec2hex(RegVal)])
                end
            end        
        end
        
        function RegVal     =   GenRegSetField(obj, RegVal, RegIdx, stField, Val)
        %   @function       GenRegSetField                                                             
        %   @author         Haderer Andreas (HaAn)                                                  
        %   @date           2015-07-27          
        %   @brief          Set Field of Register
        %   @param[in]      RegVal: register value
        %   @param[in]      RegIdx: Index of register in caRegs array
        %   @param[in]      stField: Name of field
        %   @param[in]      Value of field
        %   @return         New register value
            Fields      =   obj.caRegs{RegIdx}.Fields;
            RegVal      =   RegVal;
            Ini         =   0;
            for Idx = 1:numel(Fields)
                if strcmp(Fields{Idx}.Name, stField)
                    Ini         =   1;
                    Low         =   2.^Fields{Idx}.Strt;
                    High        =   2.^(Fields{Idx}.Stop + 1);
                    if High < Low
                        error('Field definition')
                    end
                    Lim         =   2.^(Fields{Idx}.Stop + 1 - Fields{Idx}.Strt);
                    RegValLow   =   mod(RegVal, Low);
                    RegValHigh  =   floor(RegVal/High);
                    %disp([stField, ' :', num2str(Val)])
                    Val         =   mod(Val,Lim);
                    RegVal      =   RegValLow + Val.*Low + RegValHigh*High;
                    %disp([stField, ' :', dec2hex(RegVal)])
                end
            end
            if Ini == 0
                disp([ stField, ' not known']);
                RegIdx
            end
        
        end


        function Idx = FindRegByAdr(obj, Adr)
            Idx = -1;
            for SearchIdx = 1:numel(obj.caRegs)
                if obj.caRegs{SearchIdx}.Adr == Adr
                    Idx     = SearchIdx;
                end
            end            
        end
   
        function Idx = FindRegByName(obj, stName)
            Idx = -1;
            for SearchIdx = 1:numel(obj.caRegs)
                if strcmp(obj.caRegs{SearchIdx}.Name,stName)
                    Idx     = SearchIdx;
                end
            end
        end

        function DefineConst(obj)
            % Define Register 0
            Reg.Name                =   'R0';
            Reg.Adr                 =   0;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   0;
            Reg.Fields{1}.Res       =   1;            
            Reg.Fields{2}.Name      =   'PupLo';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   5;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'PupTx1';
            Reg.Fields{3}.Strt      =   6;
            Reg.Fields{3}.Stop      =   6;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'PupTx2';
            Reg.Fields{4}.Strt      =   7;
            Reg.Fields{4}.Stop      =   7;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;            
            Reg.Fields{5}.Name      =   'PupAdc';
            Reg.Fields{5}.Strt      =   8;
            Reg.Fields{5}.Stop      =   8;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   0; 
            Reg.Fields{6}.Name      =   'VcoCal';
            Reg.Fields{6}.Strt      =   9;
            Reg.Fields{6}.Stop      =   9;
            Reg.Fields{6}.Val       =   0;
            Reg.Fields{6}.Res       =   0; 
            Reg.Fields{7}.Name      =   'PupVco';
            Reg.Fields{7}.Strt      =   10;
            Reg.Fields{7}.Stop      =   10;
            Reg.Fields{7}.Val       =   0;
            Reg.Fields{7}.Res       =   0; 
            Reg.Fields{8}.Name      =   'Tx1AmpCal';
            Reg.Fields{8}.Strt      =   11;
            Reg.Fields{8}.Stop      =   11;
            Reg.Fields{8}.Val       =   0;
            Reg.Fields{8}.Res       =   0; 
            Reg.Fields{9}.Name      =   'Tx2AmpCal';
            Reg.Fields{9}.Strt      =   12;
            Reg.Fields{9}.Stop      =   12;
            Reg.Fields{9}.Val       =   0;
            Reg.Fields{9}.Res       =   0; 
            Reg.Fields{10}.Name     =   'Res';
            Reg.Fields{10}.Strt     =   13;
            Reg.Fields{10}.Stop     =   13;
            Reg.Fields{10}.Val      =   1;
            Reg.Fields{10}.Res      =   1;
            Reg.Fields{11}.Name     =   'PupNCntr';
            Reg.Fields{11}.Strt     =   14;
            Reg.Fields{11}.Stop     =   14;
            Reg.Fields{11}.Val      =   0;
            Reg.Fields{11}.Res      =   0;
            Reg.Fields{12}.Name     =   'PupRCntr';
            Reg.Fields{12}.Strt     =   15;
            Reg.Fields{12}.Stop     =   15;
            Reg.Fields{12}.Val      =   0;
            Reg.Fields{12}.Res      =   0;
            Reg.Fields{13}.Name     =   'Res';
            Reg.Fields{13}.Strt     =   16;
            Reg.Fields{13}.Stop     =   19;
            Reg.Fields{13}.Val      =   15;
            Reg.Fields{13}.Res      =   1;
            Reg.Fields{14}.Name     =   'AuxDiv';
            Reg.Fields{14}.Strt     =   20;
            Reg.Fields{14}.Stop     =   20;
            Reg.Fields{14}.Val      =   0;
            Reg.Fields{14}.Res      =   0;
            Reg.Fields{15}.Name     =   'AuxBufGain';
            Reg.Fields{15}.Strt     =   21;
            Reg.Fields{15}.Stop     =   23;
            Reg.Fields{15}.Val      =   0;
            Reg.Fields{15}.Res      =   0;
            Reg.Fields{16}.Name     =   'Res';
            Reg.Fields{16}.Strt     =   24;
            Reg.Fields{16}.Stop     =   31;
            Reg.Fields{16}.Val      =   2^7;
            Reg.Fields{16}.Res      =   1;
            caReg{1}                =   Reg;
            
            % Define Register 1
            Reg                     =   [];            
            Reg.Name                =   'R1';
            Reg.Adr                 =   1;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   1;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'TxAmpCalRefCode';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   12;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'Res';
            Reg.Fields{3}.Strt      =   13;
            Reg.Fields{3}.Stop      =   31;
            Reg.Fields{3}.Val       =   2^19 - 1 - 2^4 - 2^6;
            Reg.Fields{3}.Res       =   1;
            caReg{2}                =   Reg;
            
            % Define Register 2
            Reg                     =   [];  
            Reg.Name                =   'R2';
            Reg.Adr                 =   2;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   2;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'AdcClkDiv';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   12;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'AdcAv';
            Reg.Fields{3}.Strt      =   13;
            Reg.Fields{3}.Stop      =   14;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'AdcStrt';
            Reg.Fields{4}.Strt      =   15;
            Reg.Fields{4}.Stop      =   15;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;
            Reg.Fields{5}.Name      =   'Res';
            Reg.Fields{5}.Strt      =   16;
            Reg.Fields{5}.Stop      =   31;
            Reg.Fields{5}.Val       =   2^1;
            Reg.Fields{5}.Res       =   0;                        
            caReg{3}                =   Reg;

            
            % Define Register 3
            Reg                     =   [];  
            Reg.Name                =   'R3';
            Reg.Adr                 =   3;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   3;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'ReadBackCtrl';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   10;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'IoLev';
            Reg.Fields{3}.Strt      =   11;
            Reg.Fields{3}.Stop      =   11;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'MuxOut';
            Reg.Fields{4}.Strt      =   12;
            Reg.Fields{4}.Stop      =   15;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;
            Reg.Fields{5}.Name      =   'Res';
            Reg.Fields{5}.Strt      =   16;
            Reg.Fields{5}.Stop      =   31;
            Reg.Fields{5}.Val       =   1 + 2^3 + 2^7 + 2^8;
            Reg.Fields{5}.Res       =   1;
            caReg{4}                =   Reg;
            
            
            % Define Register 4
            Reg                     =   [];  
            Reg.Name                =   'R4';
            Reg.Adr                 =   4;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   4;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'AnaTstBus';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   14;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'TstBusToPin';
            Reg.Fields{3}.Strt      =   15;
            Reg.Fields{3}.Stop      =   15;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'TstBusToAdc';
            Reg.Fields{4}.Strt      =   16;
            Reg.Fields{4}.Stop      =   16;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;
            Reg.Fields{5}.Name      =   'Res';
            Reg.Fields{5}.Strt      =   17;
            Reg.Fields{5}.Stop      =   31;
            Reg.Fields{5}.Val       =   2^4;
            Reg.Fields{5}.Res       =   1;
            caReg{5}                =   Reg;

            % Define Register 5
            Reg                     =   [];  
            Reg.Name                =   'R5';
            Reg.Adr                 =   5;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   5;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'FracMsb';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   16;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'Int';
            Reg.Fields{3}.Strt      =   17;
            Reg.Fields{3}.Stop      =   28;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'Res';
            Reg.Fields{4}.Strt      =   29;
            Reg.Fields{4}.Stop      =   31;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   1;
            caReg{6}                =   Reg;

            % Define Register 6
            Reg                     =   [];  
            Reg.Name                =   'R6';
            Reg.Adr                 =   6;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   6;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'FracLsb';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   17;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'Res';
            Reg.Fields{3}.Strt      =   18;
            Reg.Fields{3}.Stop      =   31;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   1;
            caReg{7}                =   Reg;
         
            % Define Register 7
            Reg                     =   [];  
            Reg.Name                =   'R7';
            Reg.Adr                 =   7;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   7;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'RDiv';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   9;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'RefDoub';
            Reg.Fields{3}.Strt      =   10;
            Reg.Fields{3}.Stop      =   10;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'RDiv2';
            Reg.Fields{4}.Strt      =   11;
            Reg.Fields{4}.Stop      =   11;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;
            Reg.Fields{5}.Name      =   'ClkDiv';
            Reg.Fields{5}.Strt      =   12;
            Reg.Fields{5}.Stop      =   23;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   0;
            Reg.Fields{6}.Name      =   'Res';
            Reg.Fields{6}.Strt      =   24;
            Reg.Fields{6}.Stop      =   24;
            Reg.Fields{6}.Val       =   1;
            Reg.Fields{6}.Res       =   1;
            Reg.Fields{7}.Name      =   'MsRst';
            Reg.Fields{7}.Strt      =   25;
            Reg.Fields{7}.Stop      =   25;
            Reg.Fields{7}.Val       =   0;
            Reg.Fields{7}.Res       =   0;
            Reg.Fields{8}.Name      =   'Res';
            Reg.Fields{8}.Strt      =   26;
            Reg.Fields{8}.Stop      =   31;
            Reg.Fields{8}.Val       =   0;
            Reg.Fields{8}.Res       =   1;
            caReg{8}                =   Reg;            
            
            % Define Register 8
            Reg                     =   [];  
            Reg.Name                =   'R8';
            Reg.Adr                 =   8;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   8;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'FreqCalDiv';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   14;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'Res';
            Reg.Fields{3}.Strt      =   15;
            Reg.Fields{3}.Stop      =   31;
            Reg.Fields{3}.Val       =   2^15;
            Reg.Fields{3}.Res       =   1;
            caReg{9}                =   Reg;  
            
            % Define Register 9
            Reg                     =   [];  
            Reg.Name                =   'R9';
            Reg.Adr                 =   9;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   9;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'Res';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   31;
            Reg.Fields{2}.Val       =   1 + 2^3 + + 2^6 + 2^7 + 2^8 + 2^10 + 2^16 + 2^20 + 2^22 + 2^24;
            %Reg.Fields{2}.Val       =   1 + 2^3 + + 2^6 + 2^7 + 2^8 + 2^10 + 2^22 + 2^24;
            Reg.Fields{2}.Res       =   1;
            caReg{10}               =   Reg;              
            
            % Define Register 10
            Reg                     =   [];  
            Reg.Name                =   'R10';
            Reg.Adr                 =   10;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   4;
            Reg.Fields{1}.Val       =   10;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'Res';
            Reg.Fields{2}.Strt      =   5;
            Reg.Fields{2}.Stop      =   31;
            Reg.Fields{2}.Val       =   2^24 - 1;
            Reg.Fields{2}.Res       =   1;
            caReg{11}               =   Reg;  
                        
            obj.caRegs              =   caReg;
        end
        
        
    end
end

