%< @file        Adf24Tx2Rx4.m                                                                                                                 
%< @date        2017-07-18          
%< @brief       Matlab class for initialization of Adf24Tx2Rx4 board
%< @version     1.0.0

classdef Adf24Tx2Rx4<DemoRad


    properties (Access = public)

        %>  Object of first receiver (DevAdf5904 class object)
        Adf_Rx                      =   [];
        %>  Object of transmitter (DevAdf5901 class object)
        Adf_Tx                      =   [];
        %>  Object of transmitter Pll (DevAdf4159 class object)
        Adf_Pll                     =   [];
    end

    properties (Access = private)
        
        Rf_USpiCfg_Mask             =   1;
        Rf_USpiCfg_Pll_Chn          =   2;
        Rf_USpiCfg_Tx_Chn           =   1;
        Rf_USpiCfg_Rx_Chn           =   0;

        Rf_Adf5904_FreqStrt         =   24.125e9;
        Rf_Adf5904_RefDiv           =   1;
        Rf_Adf5904_SysClk           =   80e6;

        Rf_fStrt                    =   76e9;
        Rf_fStop                    =   77e9;
        Rf_TRampUp                  =   256e-6;
        Rf_TRampDo                  =   256e-6;
        
        Rf_VcoDiv                   =   2;

        stRfVers                    =   '1.0.0';

        StrtIdx                     =   0;
        StopIdx                     =   1;
        
    end

    methods (Access = public)

        function obj    =   Adf24Tx2Rx4()

            if obj.DebugInf > 10
                disp('AnalogBoard Initialize')
            end

            % Initialize Receiver
            USpiCfg.Mask    =   obj.Rf_USpiCfg_Mask;
            USpiCfg.Chn     =   obj.Rf_USpiCfg_Rx_Chn;
            obj.Adf_Rx      =   DevAdf5904(obj, USpiCfg);

            USpiCfg.Chn     =   obj.Rf_USpiCfg_Tx_Chn;
            obj.Adf_Tx      =   DevAdf5901(obj, USpiCfg);

            USpiCfg.Chn     =   obj.Rf_USpiCfg_Pll_Chn;
            obj.Adf_Pll     =   DevAdf4159(obj, USpiCfg);
            
            % Set only four channels
            obj.Set('NrChn',4);
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Class destructor
        %>
        %> Delete class object  
        function delete(obj)

        end


        % DOXYGEN ------------------------------------------------------
        %> @brief Get Version information of Adf24Tx2Rx8 class
        %>
        %> Get version of class 
        %>      - Version string is returned as string
        %>
        %> @return  Returns the version string of the class (e.g. 0.5.0)           
        function    Ret     =   RfGetVers(obj)            
            Ret     =   obj.stVers;
        end


        % DOXYGEN ------------------------------------------------------
        %> @brief Get attribute of class object
        %>
        %> Reads back different attributs of the object
        %>
        %> @param[in]   stSel: String to select attribute
        %> 
        %> @return      Val: value of the attribute (optional); can be a string or a number  
        %>  
        %>      -   <span style="color: #ff9900;"> 'TxPosn': </span> Array containing positions of Tx antennas 
        %>      -   <span style="color: #ff9900;"> 'RxPosn': </span> Array containing positions of Rx antennas
        %>      -   <span style="color: #ff9900;"> 'ChnDelay': </span> Channel delay of receive channels
        function    Ret     =   RfGet(obj, varargin)
            Ret     =   [];
            if nargin > 1
                stVal       = varargin{1};
                switch stVal
                    case 'TxPosn'
                        Ret     =   zeros(2,1);
                        Ret(1)  =   -18.654e-3;
                        Ret(2)  =   0.0e-3;
                    case 'RxPosn'
                        Ret     =   [0:3].';
                        Ret     =   Ret.*6.2170e-3 + 32.014e-3;           
                    case 'B'
                        Ret     =   (obj.Rf_fStop - obj.Rf_fStrt);  
                    case 'kf'
                        Ret     =   (obj.Rf_fStop - obj.Rf_fStrt)./obj.Rf_TRampUp;
                    case 'fc'
                        Ret     =   (obj.Rf_fStop + obj.Rf_fStrt)/2;
                    otherwise

                end
            end
        end
            
        % DOXYGEN ------------------------------------------------------
        %> @brief Enable all receive channels
        %>
        %> Enables all receive channels of frontend
        %>
        %>  
        %> @note: This command calls the Adf4904 objects Adf_Rx
        %>        In the default configuration all Rx channels are enabled. The configuration of the objects can be changed before 
        %>        calling the RxEna command.
        %>
        %> @code 
        %> CfgRx1.Rx1      =   0;
        %> Brd.Adf_Rx1.SetCfg(CfgRx1); 
        %> @endcode
        %>  In the above example Chn1 of receiver 1 is disabled and all channels of receiver Rx2 are disabled
        function    RfRxEna(obj)
            disp('RfRxEna');
            obj.RfAdf5904Ini(1);
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Configure receivers 
        %>
        %> Configures selected receivers
        %>
        %> @param[in]   Mask: select receiver: 1 receiver 1; 2 receiver 2
        %>  
        function    RfAdf5904Ini(obj, Mask)
            if Mask == 1
                obj.Adf_Rx.Ini();
                if obj.DebugInf > 10
                    disp('Rf Initialize Rx1 (ADF5904)')
                end
            end
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Configure registers of receiver
        %>
        %> Configures registers of receivers
        %>
        %> @param[in]   Mask: select receiver: 1 receiver 1; 2 receiver 2
        %>  
        %> @param[in]   Data: register values
        %>
        %> @note Function is obsolete in class version >= 1.0.0: use function Adf_Rx1.SetRegs() and Adf_Rx2.SetRegs() to configure receiver 
        function    RfAdf5904SetRegs(obj, Mask, Data)
            if Mask == 1
                obj.Adf_Rx.SetRegs(Data);
                if obj.DebugInf > 10
                    disp('Rf Initialize Rx (ADF5904)')
                end 
            end
        end
  

        % DOXYGEN ------------------------------------------------------
        %> @brief Configure registers of transmitter
        %>
        %> Configures registers of transmitter
        %>
        %> @param[in]   Mask: select receiver: 1 transmitter 1
        %>  
        %> @param[in]   Data: register values
        %>
        %> @note Function is obsolete in class version >= 1.0.0: use function Adf_Tx.SetRegs() to configure transmitter 
        function    RfAdf5901SetRegs(obj, Mask, Data)
            if Mask == 1
                obj.Adf_Tx.SetRegs(Data);
                disp('Rf Initialize Tx (ADF5901)')
            end
        end


        % DOXYGEN ------------------------------------------------------
        %> @brief Configure registers of PLL
        %>
        %> Configures registers of PLL
        %>
        %> @param[in]   Mask: select receiver: 1 transmitter 1
        %>  
        %> @param[in]   Data: register values
        %>
        %> @note Function is obsolete in class version >= 1.0.0: use function Adf_Pll.SetRegs() to configure PLL 
        function    Ret     =   RfAdf4159SetRegs(obj, Mask, Data)
            Data                =   Data(:);

            USpiCfg.Mask        =   obj.Rf_USpiCfg_Mask;
            USpiCfg.Chn         =   obj.Rf_USpiCfg_Pll_Chn;
            Ret                 =   obj.Dsp_SetUSpiData(USpiCfg, Data);
        end

        % DOXYGEN -------------------------------------------------
        %> @brief Displays status of frontend in Matlab command window  
        %>
        %> Display status of frontend in Matlab command window         
        function    BrdDispSts(obj)
            obj.BrdDispInf();
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief Enable transmitter
        %>
        %> Configures TX device
        %>
        %> @param[in]   TxChn
        %>                  - 0: off
        %>                  - 1: Transmitter 1 on
        %>                  - 2: Transmitter 2 on
        %> @param[in]   TxPwr: Power register setting 0 - 256; only 0 to 100 has effect
        %>
        %>  
        function    RfTxEna(obj, TxChn, TxPwr)
            TxChn           =   floor(mod(TxChn, 3));
            TxPwr           =   floor(mod(TxPwr, 2.^8));

            Cfg.TxChn       =   TxChn;
            Cfg.TxPwr       =   TxPwr;
            obj.Adf_Tx.SetCfg(Cfg);
            obj.Adf_Tx.Ini();
        end

        function    Ret     =   BrdGetData(obj)
            Ret     =   BrdGetChirp(obj, obj.StrtIdx, obj.StopIdx);
        end
        
        function    ErrCod      =   RfMeas(obj, varargin)   

            ErrCod      =   0;       
            if nargin > 2
                stMod       =   varargin{1};

                if stMod == 'Adi'

                    obj.Dsp_SetAdiDefaultConf();

                    disp('Simple Measurement Mode: Analog Devices')
                    Cfg             =   varargin{2};

                    if ~isfield(Cfg, 'fStrt')
                        disp('RfMeas: fStrt not specified!')
                        ErrCod      =   -1;
                    end
                    if ~isfield(Cfg, 'fStop')
                        disp('RfMeas: fStop not specified!')
                        ErrCod      =   -1;
                    end
                    if ~isfield(Cfg, 'TRampUp')
                        disp('RfMeas: TRampUp not specified!')
                        ErrCod      =   -1;
                    end
                    
                    if isfield(Cfg, 'StrtIdx')
                        obj.StrtIdx    =   Cfg.StrtIdx;
                    end
                    if isfield(Cfg, 'StopIdx')
                        obj.StopIdx    =   Cfg.StopIdx;
                    end
                        
                    obj.Rf_fStrt       =   Cfg.fStrt;
                    obj.Rf_fStop       =   Cfg.fStop;
                    obj.Rf_TRampUp     =   278e-6;           

                    obj.RfAdf4159Ini(Cfg);
                end 
            end 
        end
            


        % DOXYGEN ------------------------------------------------------
        %> @brief Initialize PLL with selected configuration
        %>
        %> Configures PLL
        %>
        %> @param[in]   Cfg: structure with PLL configuration
        %>      -   <span style="color: #ff9900;"> 'fStrt': </span> Start frequency in Hz
        %>      -   <span style="color: #ff9900;"> 'fStrt': </span> Stop frequency in Hz
        %>      -   <span style="color: #ff9900;"> 'TRampUp': </span> Upchirp duration in s
        %>
        %> %> @note Function is obsolete in class version >= 1.0.0: use function Adf_Pll.SetCfg() and Adf_Pll.Ini()          
        function    RfAdf4159Ini(obj, Cfg)
            obj.Adf_Pll.SetCfg(Cfg);
            obj.Adf_Pll.Ini();
        end
        
        
        function    Ret     =   Fpga_SetUSpiData(obj, SpiCfg, Regs)
            Ret     =   obj.Dsp_SendSpiData(SpiCfg, Regs);
        end
            
    end 
end