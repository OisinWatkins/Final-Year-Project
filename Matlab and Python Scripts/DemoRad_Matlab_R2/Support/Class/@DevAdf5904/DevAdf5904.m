%< @file        DevAdf5904.m                                                                
%< @author      Haderer Andreas (HaAn)                                                  
%< @date        2013-06-13          
%< @brief       Class for configuration of Adf5904 receiver
%< @version     1.0.1

classdef DevAdf5904<handle
    
    properties (Access = public)
        
    end

    properties (Access = private)
        Brd                         =   []
        caRegs                      =   cell(0);
        stVers                      =   '1.0.0';
        USpiCfg_Mask                =   1;
        USpiCfg_Chn                 =   0;
        USpiCfg_Type                =   'USpi';
        RegR3                       =   0;
        RegR2                       =   0;
        RegR0                       =   0;
                       
    end
    
    methods (Access = public)
        
        % DOXYGEN ------------------------------------------------------
        %> @brief Class constructor
        %>
        %> Construct a class object to configure the receiver with an existing Frontend class object.
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
        %>   Adf5904    =   DevAdf5904(Brd,USpiCfg)
        %>   @endcode          
        function obj    =   DevAdf5904(Brd, USpiCfg)       
            obj.Brd     =   Brd; 
            if obj.Brd.DebugInf > 10
                disp('ADF5904 Initialize')
            end
            if ~isfield(USpiCfg, 'Mask')
                warning('DevAdf5904: Mask not specified')
                obj.USpiCfg_Mask    =   1;
            else
                obj.USpiCfg_Mask    =   USpiCfg.Mask;
            end
            if ~isfield(USpiCfg, 'Chn')
                warning('DevAdf5904: Chn not specified')
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

            obj.RegR3       =   obj.GenRegFlag('R3',0);   
            obj.RegR2       =   obj.GenRegFlag('R2',0);  
            obj.RegR0       =   obj.GenRegFlag('R0',0, 'PupLo', 1, 'PupChn1', 1, 'PupChn2', 1, 'PupChn3', 1, 'PupChn4', 1); 

        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Class destructor
        %>
        %> Delete class object           
        function delete(obj)         
        end
        
        % DOXYGEN ------------------------------------------------------
        %> @brief Get version information of Adf5904 class
        %>
        %> Get version of class 
        %>      - Version String is returned as string
        %>
        %> @return  Returns the version string of the class (e.g. 1.0.0)          
        function Ret    =   GetVers(obj)            
            Ret         =   obj.stVers
        end

        % DOXYGEN -------------------------------------------------
        %> @brief Displays version information in Matlab command window  
        %>
        %> Display version of class in Matlab command window             
        function DispVers(obj)     
            disp(['ADF5904 Class Version: ', obj.stVers])
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Set device configuration
        %>
        %> This method is used to set the configuration of the device. A configuration structure is used to set the desired parameters.
        %> If a field is not present in the structure, then the parameter is not changed. The function only changes the local parameters of the class.
        %> The IniCfg methos must be called, so that the configuration takes place.       
        %>
        %> @param[in]     Cfg: structure with the desired configuration
        %>          -   <span style="color: #ff9900;"> 'Rx1': </span>: Enable disable Rx1; 0 to disable, 1 to enable channel
        %>          -   <span style="color: #ff9900;"> 'Rx2': </span>: Enable disable Rx2; 0 to disable, 1 to enable channel
        %>          -   <span style="color: #ff9900;"> 'Rx3': </span>: Enable disable Rx3; 0 to disable, 1 to enable channel
        %>          -   <span style="color: #ff9900;"> 'Rx4': </span>: Enable disable Rx4; 0 to disable, 1 to enable channel
        %>          -   <span style="color: #ff9900;"> 'Lo': </span>: Enable disable Lo ; 0 to disable, 1 to enable channel
        %>          -   <span style="color: #ff9900;"> 'All': </span>: Enable disable all channels and Lo; 0 to disable, 1 to enable channel        
        %>
        %> @return  Returns a object of the class with the desired USpi interface configuration
        %>
        %> e.g. Disable all receive channels and the LO path
        %>   @code
        %>   Brd        =   Radarbook('PNet','192.168.1.1')
        %>   USpiCfg.Mask   =   1
        %>   USpiCfg.Chn    =   1
        %>   Adf5904    =   DevAdf5904(Brd,USpiCfg)
        %>   Cfg.All        =   0
        %>   Adf5904.SetCfg(Cfg)
        %>   @endcode         
        function SetCfg(obj, Cfg)
            if isfield(Cfg, 'Rx1')
                obj.RegR0       =   obj.GenRegFlag('R0',obj.RegR0, 'PupChn1', Cfg.Rx1);
            end
            if isfield(Cfg, 'Rx2')
                obj.RegR0       =   obj.GenRegFlag('R0',obj.RegR0, 'PupChn2', Cfg.Rx2);
            end
            if isfield(Cfg, 'Rx3')
                obj.RegR0       =   obj.GenRegFlag('R0',obj.RegR0, 'PupChn3', Cfg.Rx3);
            end
            if isfield(Cfg, 'Rx4')
                obj.RegR0       =   obj.GenRegFlag('R0',obj.RegR0, 'PupChn4', Cfg.Rx4);
            end
            if isfield(Cfg, 'Lo')
                obj.RegR0       =   obj.GenRegFlag('R0',obj.RegR0, 'PupLo', Cfg.Lo);
            end
            if isfield(Cfg, 'All')
                obj.RegR0       =   obj.GenRegFlag('R0',obj.RegR0, 'PupChn1', Cfg.All, 'PupChn2', Cfg.All, 'PupChn3', Cfg.All, 'PupChn4', Cfg.All, 'PupLo', Cfg.All);
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
        %>          -   <span style="color: #ff9900;"> 'RegR2': </span>: Desired value for register R2
        %>          -   <span style="color: #ff9900;"> 'RegR3': </span>: Desired value for register R3
        %>         
        function SetRegCfg(obj, Cfg)
            if isfield(Cfg, 'RegR0')
                obj.RegR0       =   Cfg.RegR0;
            end
            if isfield(Cfg, 'RegR2')
                obj.RegR2       =   Cfg.RegR2;
            end
            if isfield(Cfg, 'RegR3')
                obj.RegR3       =   Cfg.RegR3;
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
        %>  
        function DevSetCfg(obj, Cfg)
        % reset this function is currently not implemented
            if isfield(Cfg, 'Mask')
                obj.USpiCfg_Mask    =   Cfg.Mask;
            end
            if isfield(Cfg, 'Chn')
                obj.USpiCfg_Chn     =   Cfg.Chn;
            end
            if isfield(Cfg, 'Type')
                obj.USpiCfg_Type    =   Cfg.Type;
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
        %> @brief Programm device registers to the receiver 
        %>  
        %> This function programms the register to the device. The function expects an array with register values. That are programmed to the device.
        %>
        %> @param[in]     Regs array with register values <br>
        %>                The register values are programmed to the device over the selected SPI interface.
        %>
        %> @return     Return code of the command
        function Ret    =   DevSetReg(obj, Regs)
        %   @function       SetCfg                                                             
        %   @author         Haderer Andreas (HaAn)                                                  
        %   @date           2015-07-27          
        %   @brief          Set Device Configuration
        %   @param[in]      Regs: register values beeing programmed over spi
            Ret     =   [];
            Regs    =   Regs(:);
            if strcmp(obj.USpiCfg_Type,'USpi')
                if numel(Regs) > 28
                    Regs    =   Regs(:);
                end
                USpiCfg.Mask    =   obj.USpiCfg_Mask;
                USpiCfg.Chn     =   obj.USpiCfg_Chn;
                Ret     =   obj.Brd.Fpga_SetUSpiData(USpiCfg, Regs);
            end
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Programm device registers to the receiver directly
        %>  
        %> Is identical to DevSetReg as no programming sequence is required.
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
        %> e.g. Configure the device: The following sequence enables all transmit channels on the device (default class setting)
        %>   @code
        %>   Brd        =   Radarbook('PNet','192.168.1.1')
        %>   USpiCfg.Mask   =   1
        %>   USpiCfg.Chn    =   1
        %>   Adf5904    =   DevAdf5904(Brd,USpiCfg)
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
        %   @function       GenRegs                                                             
        %   @author         Haderer Andreas (HaAn)                                                  
        %   @date           2015-07-27          
        %   @brief          Generate registers for programming      
            Data            =   [];
            Data            =   [Data; obj.RegR3];
            Data            =   [Data; obj.RegR2];
            Data            =   [Data; obj.GenRegFlag('R1', 0, 'ChnSel', 1)];
            Data            =   [Data; obj.GenRegFlag('R1', 0, 'ChnSel', 2)];
            Data            =   [Data; obj.GenRegFlag('R1', 0, 'ChnSel', 3)];
            Data            =   [Data; obj.GenRegFlag('R1', 0, 'ChnSel', 4)];
            Data            =   [Data; obj.RegR0];
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
        %>   Adf5904    =   DevAdf5904(Brd,USpiCfg)
        %>   RegR0      =   Adf5904.GenRegFlg('R0', 0, 'PupLo', 1)
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
        %>  Field: Ctrl
        %>  Field: Res
        %>  Field: DoutVSel
        %>  Field: LoPinBias
        %>  Field: PupLo
        %>  Field: PupChn1
        %>  Field: PupChn2
        %>  Field: PupChn3
        %>  Field: PupChn4
        %>  Field: Res
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
        %   @function       Ini                                                             
        %   @author         Haderer Andreas (HaAn)                                                  
        %   @date           2015-07-27          
        %   @brief          Programm initialization to device          
        % self.SetCfg(dCfg)
            Ret     =   obj.Ini();
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
        
        function DefineConst(obj)
            % Define Register 0
            Reg.Name                =   'R0';
            Reg.Adr                 =   0;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   1;
            Reg.Fields{1}.Val       =   0;
            Reg.Fields{1}.Res       =   1;            
            Reg.Fields{2}.Name      =   'Res';
            Reg.Fields{2}.Strt      =   2;
            Reg.Fields{2}.Stop      =   7;
            Reg.Fields{2}.Val       =   2.^3 + 2.^5;
            Reg.Fields{2}.Res       =   1;
            Reg.Fields{3}.Name      =   'DoutVSel';
            Reg.Fields{3}.Strt      =   8;
            Reg.Fields{3}.Stop      =   8;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'LoPinBias';
            Reg.Fields{4}.Strt      =   9;
            Reg.Fields{4}.Stop      =   9;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;            
            Reg.Fields{5}.Name      =   'PupLo';
            Reg.Fields{5}.Strt      =   10;
            Reg.Fields{5}.Stop      =   10;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   0; 
            Reg.Fields{6}.Name      =   'PupChn1';
            Reg.Fields{6}.Strt      =   11;
            Reg.Fields{6}.Stop      =   11;
            Reg.Fields{6}.Val       =   0;
            Reg.Fields{6}.Res       =   0; 
            Reg.Fields{7}.Name      =   'PupChn2';
            Reg.Fields{7}.Strt      =   12;
            Reg.Fields{7}.Stop      =   12;
            Reg.Fields{7}.Val       =   0;
            Reg.Fields{7}.Res       =   0; 
            Reg.Fields{8}.Name      =   'PupChn3';
            Reg.Fields{8}.Strt      =   13;
            Reg.Fields{8}.Stop      =   13;
            Reg.Fields{8}.Val       =   0;
            Reg.Fields{8}.Res       =   0; 
            Reg.Fields{9}.Name      =   'PupChn4';
            Reg.Fields{9}.Strt      =   14;
            Reg.Fields{9}.Stop      =   14;
            Reg.Fields{9}.Val       =   0;
            Reg.Fields{9}.Res       =   0; 
            Reg.Fields{10}.Name     =   'Res';
            Reg.Fields{10}.Strt     =   15;
            Reg.Fields{10}.Stop     =   31;
            Reg.Fields{10}.Val      =   2.^16;
            Reg.Fields{10}.Res      =   1; 
            caReg{1}                =   Reg;
            
            % Define Register 1
            Reg                     =   [];            
            Reg.Name                =   'R1';
            Reg.Adr                 =   1;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   1;
            Reg.Fields{1}.Val       =   1;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'Res';
            Reg.Fields{2}.Strt      =   2;
            Reg.Fields{2}.Stop      =   28;
            Reg.Fields{2}.Val       =   2.^1+2.^2+2.^5+2.^8+2.^10;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'ChnSel';
            Reg.Fields{3}.Strt      =   29;
            Reg.Fields{3}.Stop      =   31;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            caReg{2}                =   Reg;
            
            % Define Register 2
            Reg                     =   [];  
            Reg.Name                =   'R2';
            Reg.Adr                 =   2;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   1;
            Reg.Fields{1}.Val       =   2;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'Res';
            Reg.Fields{2}.Strt      =   2;
            Reg.Fields{2}.Stop      =   9;
            Reg.Fields{2}.Val       =   1;
            Reg.Fields{2}.Res       =   1;
            Reg.Fields{3}.Name      =   'ChnTstSel';
            Reg.Fields{3}.Strt      =   10;
            Reg.Fields{3}.Stop      =   14;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'Res';
            Reg.Fields{4}.Strt      =   15;
            Reg.Fields{4}.Stop      =   31;
            Reg.Fields{4}.Val       =   2.^2;
            Reg.Fields{4}.Res       =   1;
            caReg{3}                =   Reg;

            % Define Register 3
            Reg                     =   [];  
            Reg.Name                =   'R3';
            Reg.Adr                 =   3;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   1;
            Reg.Fields{1}.Val       =   3;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'Res';
            Reg.Fields{2}.Strt      =   2;
            Reg.Fields{2}.Stop      =   31;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   1;
            caReg{4}                =   Reg;
            
            obj.caRegs              =   caReg;
        end
        
        
    end
end

