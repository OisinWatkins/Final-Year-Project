%< @file        DevAdf4159.m                                                                
%< @author      Haderer Andreas (HaAn)                                                  
%< @date        2013-06-13          
%< @brief       Class for configuration of Adf4159 synthesizer
%< @version     1.1.0

classdef DevAdf4159<handle
    
    properties (Access = public)
        
    end

    properties (Access = private)
        Brd                         =   []
        caRegs                      =   cell(0);
        stVers                      =   '1.1.0';
        USpiCfg_Mask                =   1;
        USpiCfg_Chn                 =   1;
        USpiCfg_Type                =   'USpi';    


        fStrt                       =   24.0e9;
        fStop                       =   24.25e9;
        TRampUp                     =   512e-6;  
        TRampDo                     =   128e-6;  
        ClkInt                      =   1/1e6;
        ClkSel                      =   1;

        % Choose internal reference frequency settings
        VcoDiv                      =   2;
        fRefIn                      =   100e6;
        ValD                        =   0;                      %Reg doubler, 0: disabled, 1: enabled
        ValR                        =   1;                      %preset divide ratio to 1 (1 ... 32)
        ValT                        =   0;                      %REF_in divide-by-2, 0: disabled, 1: enabled

        fDev                        =   100e3;                                              %choosen frequency hop 
                
    end
    
    methods (Access = public)

        % DOXYGEN ------------------------------------------------------
        %> @brief Class constructor
        %>
        %> Construct a class object to configure the transmitter with an existing Frontend class object.
        %>
        %> @param[in]     Brd: Radarbook or Frontend class object         
        %>
        %> @param[in]     (optional) USpiCfg: Configuration of USpi interface: access of device from the baseboard
        %>          -   <span style="color: #ff9900;"> 'Mask': </span>: Bitmask to select the device
        %>          -   <span style="color: #ff9900;"> 'Chn': </span>: Channel of USPI interface; TX is connected to this channel        
        %>          -   <span style="color: #ff9900;"> 'Type': </span>: In the actual version only 'USpi' is supported for the type        
        %>          If USpiCfg is not stated then the default setting is used: Mask = 1, Chn = 0; Type = 'USpi'        
        %> @return  Returns a object of the class with the desired USpi interface configuration
        %>
        %> e.g. with PNet TCP/IP functions
        %>   @code
        %>   Brd        =   Radarbook('PNet','192.168.1.1')
        %>   USpiCfg.Mask   =   1
        %>   USpiCfg.Chn    =   1
        %>   Adf5901    =   DevAdf5901(Brd,USpiCfg)
        %>   @endcode           
        function obj    =   DevAdf4159(Brd, varargin)      
            obj.Brd     =   Brd; 
            if obj.Brd.DebugInf > 10
                disp('ADF4159 Initialize')
            end
            if nargin > 1
                USpiCfg     =   varargin{1};
                if ~isfield(USpiCfg, 'Mask')
                    warning('DevAdf4159: Mask not specified')
                    obj.USpiCfg_Mask    =   1;
                else
                    obj.USpiCfg_Mask    =   USpiCfg.Mask;
                end
                if ~isfield(USpiCfg, 'Chn')
                    warning('DevAdf4159: Chn not specified')
                    obj.USpiCfg_Chn     =   0;
                else
                    obj.USpiCfg_Chn     =   USpiCfg.Chn;   
                end
                if ~isfield(USpiCfg, 'Type')
                    obj.USpiCfg_Type    =   'USpi';
                else
                    obj.USpiCfg_Type    =   USpiCfg.Type;
                end   
            else
                disp('ADF4159: SPICfg not stated: use default')
                obj.USpiCfg_Mask    =   1; 
                obj.USpiCfg_Chn     =   0;
                obj.USpiCfg_Type    =   'USpi';    
            end     
            obj.DefineConst();
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
            disp(['ADF4159 Class Version: ',obj.stVers])
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Set device configuration
        %>
        %> This method is used to set the configuration of the device. A configuration structure is used to set the desired parameters.
        %> If a field is not present in the structure, then the parameter is not changed. The function only changes the local parameters of the class.
        %> The IniCfg methos must be called, so that the configuration takes place.       
        %>
        %> @param[in]     Cfg: structure with the desired configuration
        %>          -   <span style="color: #ff9900;"> 'fStrt': </span>: Desired start frequency <br>
        %>          -   <span style="color: #ff9900;"> 'fStop': </span>: Desired stop frequency <br>
        %>          -   <span style="color: #ff9900;"> 'TRampUp': </span>: Duration of upchirp <br>
        %>
        %> @return  Returns a object of the class with the desired USpi interface configuration
        %>  
        function SetCfg(obj, Cfg)
            if isfield(Cfg, 'fStrt')
                obj.fStrt           =   Cfg.fStrt;
            else
                warning('ADF4159: fStrt not set')
            end
            if isfield(Cfg, 'fStop')
                obj.fStop           =   Cfg.fStop;
            else
                warning('ADF4159: fStop not set')
            end
            if isfield(Cfg, 'TRampUp')
                obj.TRampUp           =   Cfg.TRampUp;
            else
                warning('ADF4159: TRampUp not set')
            end
            if isfield(Cfg, 'TRampDo')
                obj.TRampDo           =   Cfg.TRampDo;
            end
            if isfield(Cfg, 'ClkInt')
                obj.ClkInt          =   Cfg.ClkInt;
            end
            if isfield(Cfg, 'ClkSel')
                obj.ClkSel          =   Cfg.ClkSel;
            end
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Set device register configuration
        %>
        %> Not yet implemented; Function call has no effect; 
        %> Standard device driver function
        function SetRegCfg(obj, Cfg)
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Set device basic hardware and class configuration   
        %>
        %> Not yet implemented; Function call has no effect; 
        %> Standard device driver function
        function DevSetCfg(obj)
        % reset this function is currently not implemented
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
        %> @brief Programm device registers to the PLL 
        %>  
        %> This function programms the register to the device. The function expects an array with 19 register values according to the 
        %> device data sheet. In addition, a valid Radarbook object must be stated at the class constructor.
        %>
        %> @param[in]     Regs array with register values <br>
        %>                The register values are programmed to the device over the selected SPI interface.
        %>
        %> @return     Return code of the command
        function Ret    =   DevSetReg(obj, Regs)
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
        %> e.g. Configure PLL with default configuration
        %>   @code
        %>   Brd        =   Radarbook('PNet','192.168.1.1')
        %>   USpiCfg.Mask   =   1
        %>   USpiCfg.Chn    =   1
        %>   Adf4159        =   DevAdf4159(Brd,USpiCfg)
        %>   Adf4159.Ini()
        %>   @endcode    
        function Ini(obj)
            Data            =   obj.GenRegs();
            Ret             =   obj.DevSetReg(Data);
        end

        function Data   =   GenRegs(obj)
            %   @function       GenRegs                                                             
            %   @author         Haderer Andreas (HaAn)                                                  
            %   @date           2015-07-27          
            %   @brief          Generate registers for programming

            fStrtDiv            =   obj.fStrt./obj.VcoDiv;
            fStopDiv            =   obj.fStop./obj.VcoDiv;
            BDiv                =   fStopDiv - fStrtDiv;                                            % Bandwidth divided


            fPfd                =   obj.fRefIn*( (1+obj.ValD) / (obj.ValR*(1+obj.ValT)));           % calculate internal PFD frequency
            NStrt               =   fStrtDiv/fPfd;
            NStrtInt            =   floor(NStrt);
            NStrtFracMsb        =   floor((NStrt - NStrtInt) * 2.^12);
            NStrtFracLsb        =   floor(((NStrt - NStrtInt) * 2.^12 - NStrtFracMsb) * 2.^13);

            DevMax              =   2.^15;
            fRes                =   fPfd/(2.^25);
            DevOffs             =   ceil(log10(obj.fDev/(fRes*DevMax))/log10(2));
            fDevRes             =   fRes * 2.^DevOffs;
            DevVal              =   round(obj.fDev/(fRes * 2.^DevOffs));
            fDevVal             =   fPfd/(2.^25) * (DevVal * 2.^DevOffs);


            Clk2                =   2;                                                               % choosen value
            Clk1                =   50;
            
            NrStepsUp           =   obj.TRampUp/1e-6;
            NrStepsDown         =   obj.TRampDo/1e-6;
            NrStepsUp           =   floor(obj.TRampUp/1e-6);
            NrStepsDown         =   floor(obj.TRampDo/1e-6)+1;
            fDevUp              =   BDiv/NrStepsUp;
            DevUp               =   fDevUp/fRes;
            DevOffsUp           =   ceil(log10(DevUp/8000)/log10(2));
            DevValUp            =   round(DevUp/(2.^DevOffsUp)/4)*4;
            DevValDown          =   round(DevValUp*(NrStepsUp/NrStepsDown/8));
            DevOffsDown         =   DevOffsUp + 3;
            if DevOffsDown > 9
                warning('ADF4159 initialization failure')
            end
            

            Frac                =   NStrtFracMsb* (2.^13) + NStrtFracLsb;
            fStrt               =   2*(NStrtInt+Frac/(2.^25))*fPfd;
            BUp                 =   2*fPfd/(2.^25)*(DevValUp*(2.^DevOffsUp))*NrStepsUp;

            Tim                 =   Clk1*Clk2/fPfd;

            obj.fStrt                  =   fStrt;
            obj.fStop                  =   fStrt + BUp;
            obj.TRampUp                =   Tim*NrStepsUp; 
            obj.TRampDo                =   Tim*NrStepsDown;


            Data                =   [];
            Data(1)             =   obj.GenRegFlag('R7_Delay', 0, 'TxTrig',0, 'FastRamp', 1);
            Data(2)             =   obj.GenRegFlag('R6_Step', 0, 'StepWrd', NrStepsUp, 'StepSel', 0);
            Data(3)             =   obj.GenRegFlag('R6_Step', 0, 'StepWrd', NrStepsDown, 'StepSel', 1);
            Data(4)             =   obj.GenRegFlag('R5_Dev', 0, 'DevWrd', DevValUp, 'DevOffs', DevOffsUp, 'DevSel', 0);
            Data(5)             =   obj.GenRegFlag('R5_Dev', 0, 'DevWrd', DevValDown, 'DevOffs', DevOffsDown, 'DevSel', 1);
            Data(6)             =   obj.GenRegFlag('R4_Clk', 0, 'ClkDivSel', 0, 'Clk2Div', Clk2, 'ClkDivMod', 3, 'RampSts', 4);
            Data(7)             =   obj.GenRegFlag('R4_Clk', 0, 'ClkDivSel', 1, 'Clk2Div', Clk2, 'ClkDivMod', 3, 'RampSts', 4);
            Data(8)             =   obj.GenRegFlag('R3_Func', 0, 'PDPol', 1, 'RampMod', 1, 'NegBleedCur', 3);
            Data(9)             =   obj.GenRegFlag('R2_Div', 0, 'Clk1Div', Clk1, 'RCntr', obj.ValR, 'RefDoub', obj.ValD, 'RDiv2', obj.ValT, 'PreSca', 1, 'CP', 7);
            Data(10)            =   obj.GenRegFlag('R1_LsbFrac', 0, 'Frac', NStrtFracLsb);
            Data(11)            =   obj.GenRegFlag('R0_FracInt', 0, 'Frac', NStrtFracMsb, 'Int', NStrtInt, 'MuxCtrl', 15);
            
            
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
        %>   Adf5901    =   DevAdf4159(Brd,USpiCfg)
        %>   RegR0      =   Adf4159.GenRegFlg('R0_FracInt', 0, 'Frac', 100)
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
        %> Register Name:  R0_FracInt @Adr: 0
        %> Register Name:  R1_LsbFrac @Adr: 1
        %> Register Name:  R2_Div @Adr: 2
        %> Register Name:  R3_Func @Adr: 3
        %> Register Name:  R4_Clk @Adr: 4
        %> Register Name:  R5_Dev @Adr: 5
        %> Register Name:  R6_Step @Adr: 6
        %> Register Name:  R7_Delay @Adr: 7
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
        %>Reg: R0_FracInt @Adr: 0
        %>  Field: Ctrl
        %>  Field: Frac
        %>  Field: Int
        %>  Field: MuxCtrl
        %>  Field: RampOn
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
                fprintf(hFile,'obj.lRegs.append(dReg)\n\n')
                
              
            end
        end         
        
    end

    methods (Access = protected)

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

        function IniCfg(obj, Cfg)
        end
        
        function DefineConst(obj)
            % Define Register 0
            Reg.Name                =   'R0_FracInt';
            Reg.Adr                 =   0;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   2;
            Reg.Fields{1}.Val       =   0;
            Reg.Fields{1}.Res       =   1;            
            Reg.Fields{2}.Name      =   'Frac';
            Reg.Fields{2}.Strt      =   3;
            Reg.Fields{2}.Stop      =   14;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'Int';
            Reg.Fields{3}.Strt      =   15;
            Reg.Fields{3}.Stop      =   26;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'MuxCtrl';
            Reg.Fields{4}.Strt      =   27;
            Reg.Fields{4}.Stop      =   30;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;            
            Reg.Fields{5}.Name      =   'RampOn';
            Reg.Fields{5}.Strt      =   31;
            Reg.Fields{5}.Stop      =   31;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   0;     
            caReg{1}                =   Reg;
            
            % Define Register 1
            Reg                     =   [];            
            Reg.Name                =   'R1_LsbFrac';
            Reg.Adr                 =   1;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   2;
            Reg.Fields{1}.Val       =   1;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'Phase';
            Reg.Fields{2}.Strt      =   3;
            Reg.Fields{2}.Stop      =   14;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'Frac';
            Reg.Fields{3}.Strt      =   15;
            Reg.Fields{3}.Stop      =   27;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'PhaseAdj';
            Reg.Fields{4}.Strt      =   28;
            Reg.Fields{4}.Stop      =   28;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;            
            Reg.Fields{5}.Name      =   'Res';
            Reg.Fields{5}.Strt      =   29;
            Reg.Fields{5}.Stop      =   31;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   1; 
            caReg{2}                =   Reg;
            
            % Define Register 2
            Reg                     =   [];  
            Reg.Name                =   'R2_Div';
            Reg.Adr                 =   2;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   2;
            Reg.Fields{1}.Val       =   2;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'Clk1Div';
            Reg.Fields{2}.Strt      =   3;
            Reg.Fields{2}.Stop      =   14;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'RCntr';
            Reg.Fields{3}.Strt      =   15;
            Reg.Fields{3}.Stop      =   19;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'RefDoub';
            Reg.Fields{4}.Strt      =   20;
            Reg.Fields{4}.Stop      =   20;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;
            Reg.Fields{5}.Name      =   'RDiv2';
            Reg.Fields{5}.Strt      =   21;
            Reg.Fields{5}.Stop      =   21;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   0;                          
            Reg.Fields{6}.Name      =   'PreSca';
            Reg.Fields{6}.Strt      =   22;
            Reg.Fields{6}.Stop      =   22;
            Reg.Fields{6}.Val       =   0;
            Reg.Fields{6}.Res       =   0;
            Reg.Fields{7}.Name      =   'Res';
            Reg.Fields{7}.Strt      =   23;
            Reg.Fields{7}.Stop      =   23;
            Reg.Fields{7}.Val       =   0;
            Reg.Fields{7}.Res       =   1;
            Reg.Fields{8}.Name      =   'CP';
            Reg.Fields{8}.Strt      =   24;
            Reg.Fields{8}.Stop      =   27;
            Reg.Fields{8}.Val       =   0;
            Reg.Fields{8}.Res       =   0;
            Reg.Fields{9}.Name      =   'CSR';
            Reg.Fields{9}.Strt      =   28;
            Reg.Fields{9}.Stop      =   28;
            Reg.Fields{9}.Val       =   0;
            Reg.Fields{9}.Res       =   0;      
            Reg.Fields{10}.Name     =   'Res';
            Reg.Fields{10}.Strt     =   29;
            Reg.Fields{10}.Stop     =   31;
            Reg.Fields{10}.Val      =   0;
            Reg.Fields{10}.Res      =   1;
            caReg{3}                =   Reg;

            % Define Register 3
            Reg                     =   [];  
            Reg.Name                =   'R3_Func';
            Reg.Adr                 =   3;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   2;
            Reg.Fields{1}.Val       =   3;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'CountrRst';
            Reg.Fields{2}.Strt      =   3;
            Reg.Fields{2}.Stop      =   3;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'CPTri';
            Reg.Fields{3}.Strt      =   4;
            Reg.Fields{3}.Stop      =   4;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'PwrDwn';
            Reg.Fields{4}.Strt      =   5;
            Reg.Fields{4}.Stop      =   5;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;
            Reg.Fields{5}.Name      =   'PDPol';
            Reg.Fields{5}.Strt      =   6;
            Reg.Fields{5}.Stop      =   6;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   0;              
            Reg.Fields{6}.Name      =   'LDP';
            Reg.Fields{6}.Strt      =   7;
            Reg.Fields{6}.Stop      =   7;
            Reg.Fields{6}.Val       =   0;
            Reg.Fields{6}.Res       =   0;              
            Reg.Fields{7}.Name      =   'FSK';
            Reg.Fields{7}.Strt      =   8;
            Reg.Fields{7}.Stop      =   8;
            Reg.Fields{7}.Val       =   0;
            Reg.Fields{7}.Res       =   0;
            Reg.Fields{8}.Name      =   'PSK';
            Reg.Fields{8}.Strt      =   9;
            Reg.Fields{8}.Stop      =   9;
            Reg.Fields{8}.Val       =   0;
            Reg.Fields{8}.Res       =   0;
            Reg.Fields{9}.Name      =   'RampMod';
            Reg.Fields{9}.Strt      =   10;
            Reg.Fields{9}.Stop      =   11;
            Reg.Fields{9}.Val       =   0;
            Reg.Fields{9}.Res       =   0;
            Reg.Fields{10}.Name     =   'Res';
            Reg.Fields{10}.Strt     =   12;
            Reg.Fields{10}.Stop     =   13;
            Reg.Fields{10}.Val      =   0;
            Reg.Fields{10}.Res      =   1;      
            Reg.Fields{11}.Name     =   'SDRst';
            Reg.Fields{11}.Strt     =   14;
            Reg.Fields{11}.Stop     =   14;
            Reg.Fields{11}.Val      =   0;
            Reg.Fields{11}.Res      =   0;
            Reg.Fields{12}.Name     =   'NSel';
            Reg.Fields{12}.Strt     =   15;
            Reg.Fields{12}.Stop     =   15;
            Reg.Fields{12}.Val      =   0;
            Reg.Fields{12}.Res      =   0;
            Reg.Fields{13}.Name     =   'LOL';
            Reg.Fields{13}.Strt     =   16;
            Reg.Fields{13}.Stop     =   16;
            Reg.Fields{13}.Val      =   0;
            Reg.Fields{13}.Res      =   0;
            Reg.Fields{14}.Name     =   'Res';
            Reg.Fields{14}.Strt     =   17;
            Reg.Fields{14}.Stop     =   17;
            Reg.Fields{14}.Val      =   1;
            Reg.Fields{14}.Res      =   1;
            Reg.Fields{15}.Name     =   'Res';
            Reg.Fields{15}.Strt     =   18;
            Reg.Fields{15}.Stop     =   20;
            Reg.Fields{15}.Val      =   0;
            Reg.Fields{15}.Res      =   1;
            Reg.Fields{16}.Name     =   'NBleedEna';
            Reg.Fields{16}.Strt     =   21;
            Reg.Fields{16}.Stop     =   21;
            Reg.Fields{16}.Val      =   0;
            Reg.Fields{16}.Res      =   0;
            Reg.Fields{17}.Name     =   'NegBleedCur';
            Reg.Fields{17}.Strt     =   22;
            Reg.Fields{17}.Stop     =   24;
            Reg.Fields{17}.Val      =   0;
            Reg.Fields{17}.Res      =   0;
            Reg.Fields{18}.Name     =   'Res';
            Reg.Fields{18}.Strt     =   25;
            Reg.Fields{18}.Stop     =   31;
            Reg.Fields{18}.Val      =   0;
            Reg.Fields{18}.Res      =   1;
            caReg{4}                =   Reg;
            
            % Define Register 4
            Reg                     =   [];  
            Reg.Name                =   'R4_Clk';
            Reg.Adr                 =   4;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   2;
            Reg.Fields{1}.Val       =   4;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'Res';
            Reg.Fields{2}.Strt      =   3;
            Reg.Fields{2}.Stop      =   5;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   1;
            Reg.Fields{3}.Name      =   'ClkDivSel';
            Reg.Fields{3}.Strt      =   6;
            Reg.Fields{3}.Stop      =   6;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'Clk2Div';
            Reg.Fields{4}.Strt      =   7;
            Reg.Fields{4}.Stop      =   18;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;
            Reg.Fields{5}.Name      =   'ClkDivMod';
            Reg.Fields{5}.Strt      =   19;
            Reg.Fields{5}.Stop      =   20;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   0;              
            Reg.Fields{6}.Name      =   'RampSts';
            Reg.Fields{6}.Strt      =   21;
            Reg.Fields{6}.Stop      =   25;
            Reg.Fields{6}.Val       =   0;
            Reg.Fields{6}.Res       =   0;              
            Reg.Fields{7}.Name      =   'ModuMod';
            Reg.Fields{7}.Strt      =   26;
            Reg.Fields{7}.Stop      =   30;
            Reg.Fields{7}.Val       =   0;
            Reg.Fields{7}.Res       =   0;
            Reg.Fields{8}.Name      =   'LeSel';
            Reg.Fields{8}.Strt      =   31;
            Reg.Fields{8}.Stop      =   31;
            Reg.Fields{8}.Val       =   0;
            Reg.Fields{8}.Res       =   0;
            caReg{5}                =   Reg;

            % Define Register 5
            Reg                     =   [];  
            Reg.Name                =   'R5_Dev';
            Reg.Adr                 =   5;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   2;
            Reg.Fields{1}.Val       =   5;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'DevWrd';
            Reg.Fields{2}.Strt      =   3;
            Reg.Fields{2}.Stop      =   18;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'DevOffs';
            Reg.Fields{3}.Strt      =   19;
            Reg.Fields{3}.Stop      =   22;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'DevSel';
            Reg.Fields{4}.Strt      =   23;
            Reg.Fields{4}.Stop      =   23;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;
            Reg.Fields{5}.Name      =   'DualRamp';
            Reg.Fields{5}.Strt      =   24;
            Reg.Fields{5}.Stop      =   24;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   0;              
            Reg.Fields{6}.Name      =   'FSKRamp';
            Reg.Fields{6}.Strt      =   25;
            Reg.Fields{6}.Stop      =   25;
            Reg.Fields{6}.Val       =   0;
            Reg.Fields{6}.Res       =   0;              
            Reg.Fields{7}.Name      =   'Int';
            Reg.Fields{7}.Strt      =   26;
            Reg.Fields{7}.Stop      =   27;
            Reg.Fields{7}.Val       =   0;
            Reg.Fields{7}.Res       =   0;
            Reg.Fields{8}.Name      =   'ParaRamp';
            Reg.Fields{8}.Strt      =   28;
            Reg.Fields{8}.Stop      =   28;
            Reg.Fields{8}.Val       =   0;
            Reg.Fields{8}.Res       =   0;
            Reg.Fields{9}.Name      =   'TxRampClk';
            Reg.Fields{9}.Strt      =   29;
            Reg.Fields{9}.Stop      =   29;
            Reg.Fields{9}.Val       =   0;
            Reg.Fields{9}.Res       =   0;
            Reg.Fields{10}.Name     =   'TxDataInv';
            Reg.Fields{10}.Strt     =   30;
            Reg.Fields{10}.Stop     =   30;
            Reg.Fields{10}.Val      =   0;
            Reg.Fields{10}.Res      =   0;      
            Reg.Fields{11}.Name     =   'Res';
            Reg.Fields{11}.Strt     =   31;
            Reg.Fields{11}.Stop     =   31;
            Reg.Fields{11}.Val      =   0;
            Reg.Fields{11}.Res      =   1;         
            caReg{6}                =   Reg;            

            
            % Define Register 6
            Reg                     =   [];  
            Reg.Name                =   'R6_Step';
            Reg.Adr                 =   6;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   2;
            Reg.Fields{1}.Val       =   6;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'StepWrd';
            Reg.Fields{2}.Strt      =   3;
            Reg.Fields{2}.Stop      =   22;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'StepSel';
            Reg.Fields{3}.Strt      =   23;
            Reg.Fields{3}.Stop      =   23;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'Res';
            Reg.Fields{4}.Strt      =   24;
            Reg.Fields{4}.Stop      =   31;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   1;
            caReg{7}                =   Reg;                


            % Define Register 7
            Reg                     =   [];  
            Reg.Name                =   'R7_Delay';
            Reg.Adr                 =   7;
            Reg.Val                 =   0;
            Reg.Fields{1}.Name      =   'Ctrl';
            Reg.Fields{1}.Strt      =   0;
            Reg.Fields{1}.Stop      =   2;
            Reg.Fields{1}.Val       =   7;
            Reg.Fields{1}.Res       =   1;             
            Reg.Fields{2}.Name      =   'DelayStrt';
            Reg.Fields{2}.Strt      =   3;
            Reg.Fields{2}.Stop      =   14;
            Reg.Fields{2}.Val       =   0;
            Reg.Fields{2}.Res       =   0;
            Reg.Fields{3}.Name      =   'DelayStrtEna';
            Reg.Fields{3}.Strt      =   15;
            Reg.Fields{3}.Stop      =   15;
            Reg.Fields{3}.Val       =   0;
            Reg.Fields{3}.Res       =   0;
            Reg.Fields{4}.Name      =   'DelayClkSel';
            Reg.Fields{4}.Strt      =   16;
            Reg.Fields{4}.Stop      =   16;
            Reg.Fields{4}.Val       =   0;
            Reg.Fields{4}.Res       =   0;
            Reg.Fields{5}.Name      =   'RampDelay';
            Reg.Fields{5}.Strt      =   17;
            Reg.Fields{5}.Stop      =   17;
            Reg.Fields{5}.Val       =   0;
            Reg.Fields{5}.Res       =   0;              
            Reg.Fields{6}.Name      =   'RampDelayFl';
            Reg.Fields{6}.Strt      =   18;
            Reg.Fields{6}.Stop      =   18;
            Reg.Fields{6}.Val       =   0;
            Reg.Fields{6}.Res       =   0;              
            Reg.Fields{7}.Name      =   'FastRamp';
            Reg.Fields{7}.Strt      =   19;
            Reg.Fields{7}.Stop      =   19;
            Reg.Fields{7}.Val       =   0;
            Reg.Fields{7}.Res       =   0;
            Reg.Fields{8}.Name      =   'TxTrig';
            Reg.Fields{8}.Strt      =   20;
            Reg.Fields{8}.Stop      =   20;
            Reg.Fields{8}.Val       =   0;
            Reg.Fields{8}.Res       =   0;
            Reg.Fields{9}.Name      =   'SingFullTri';
            Reg.Fields{9}.Strt      =   21;
            Reg.Fields{9}.Stop      =   21;
            Reg.Fields{9}.Val       =   0;
            Reg.Fields{9}.Res       =   0;
            Reg.Fields{10}.Name     =   'TriDelay';
            Reg.Fields{10}.Strt     =   22;
            Reg.Fields{10}.Stop     =   22;
            Reg.Fields{10}.Val      =   0;
            Reg.Fields{10}.Res      =   0;      
            Reg.Fields{11}.Name     =   'TxTrigDelay';
            Reg.Fields{11}.Strt     =   23;
            Reg.Fields{11}.Stop     =   23;
            Reg.Fields{11}.Val      =   0;
            Reg.Fields{11}.Res      =   0;         
            Reg.Fields{12}.Name     =   'Res';
            Reg.Fields{12}.Strt     =   24;
            Reg.Fields{12}.Stop     =   31;
            Reg.Fields{12}.Val      =   0;
            Reg.Fields{12}.Res      =   0;         
            caReg{8}                =   Reg;              
            
            obj.caRegs              =   caReg;
        end
        
        
    end
end

