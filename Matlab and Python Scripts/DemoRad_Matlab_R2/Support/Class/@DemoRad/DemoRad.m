%< @file        DemoRad.m                                                                                                                 
%< @date        2017-07-18          
%< @brief       Matlab class for initialization of DemoRad board
%< @version     2.0.0

classdef DemoRad<UsbAdi

    properties (Access = public)

        DebugInf        =   0;
        stBlkSize       =   128*256*4*4/2;
        stChnBlkSize    =   128*256*4*4/2/4;
        ChirpSize       =   256*4*4/2;
        CalPage         =   0;

        Rad_MaskChn     =   15;
        Rad_NrChn       =   4;        
        
        % ------------------------------------------------------------------
        % Configure Sampling
        % ------------------------------------------------------------------
        Rad_N           =   256;
        
        FuSca           = 0.498 / 65536;
		
		stDemoRadVers 	= 	'2.0.0';

        ADR7251Cfg      = [ hex2dec('00000000'), ...
                            hex2dec('0000004B'), ...
                            hex2dec('00001203'), ...
                            hex2dec('00013307'), ...
                            hex2dec('01C20001'), ...
                            hex2dec('00000002'), ...
                            hex2dec('00010064'), ...
                            hex2dec('0002004C'), ...
                            hex2dec('00032833'), ...
                            hex2dec('01400003'), ...
                            hex2dec('00060000'), ...
                            hex2dec('00400001'), ...
                            hex2dec('004100FF'), ...
                            hex2dec('004203CF'), ...
                            hex2dec('00800000'), ...
                            hex2dec('00810000'), ...
                            hex2dec('00860000'), ...
                            hex2dec('01000055'), ...             % LNA Gain 4
                            hex2dec('01010055'), ...             % PGA 2.8
                            hex2dec('01022222'), ...
                            hex2dec('01030000'), ...
                            hex2dec('01410019'), ...
                            hex2dec('014210C0'), ...
                            hex2dec('01430000'), ...
                            hex2dec('01440002'), ...
                            hex2dec('014500C8'), ...
                            hex2dec('01C00040'), ...
                            hex2dec('01C10000'), ...
                            hex2dec('02100000'), ...
                            hex2dec('02110000'), ...
                            hex2dec('02500000'), ...
                            hex2dec('02510000'), ...
                            hex2dec('02600000'), ...
                            hex2dec('02610000'), ...
                            hex2dec('02700000'), ...
                            hex2dec('02710000'), ...
                            hex2dec('02800000'), ...
                            hex2dec('02810000'), ...
                            hex2dec('02820004'), ...
                            hex2dec('02830000'), ...
                            hex2dec('02840004'), ...
                            hex2dec('02850004'), ...
                            hex2dec('02860003'), ...
                            hex2dec('02870003'), ...
                            hex2dec('02880003'), ...
                            hex2dec('02890003'), ...
                            hex2dec('028A0003'), ...
                            hex2dec('028B0003'), ...
                            hex2dec('028C0003'), ...
                            hex2dec('028D0003'), ...
                            hex2dec('028E0003'), ...
                            hex2dec('02910003'), ...
                            hex2dec('02920000'), ...
                            hex2dec('03000000'), ...
                            hex2dec('03010306'), ...
                            hex2dec('03020000'), ...
                            hex2dec('03030000'), ...
                            hex2dec('03050001'), ...
                            hex2dec('03070000'), ...
                            hex2dec('03080013'), ...
                            hex2dec('030A0001'), ...
                            hex2dec('030C0000'), ...
                            hex2dec('030D0000'), ...
                            hex2dec('030E0000'), ...
                            hex2dec('030F0000'), ...
                            hex2dec('03100000'), ...
                            hex2dec('031100AA'), ...
                            hex2dec('031200AA'), ...
                            hex2dec('03130055'), ...
                            hex2dec('03140055'), ...
                            hex2dec('03150099'), ...
                            hex2dec('03160099'), ...
                            hex2dec('03170066'), ...
                            hex2dec('03180066'), ...
                            hex2dec('032000AA'), ...
                            hex2dec('032100AA'), ...
                            hex2dec('03220000'), ...
                            hex2dec('03230000') ];

        ADIFMCWCfg      = [ hex2dec('00000000'), ...
                            hex2dec('00000007'), ...
                            hex2dec('00001100'), ...
                            hex2dec('00000080'), ...
                            hex2dec('00000100'), ...
                            hex2dec('00000004'), ...
                            hex2dec('00000014'), ...
                            hex2dec('00000007'), ...
                            hex2dec('00000001'), ...
                            hex2dec('0000000A') ];

        ADICal          = [  hex2dec('00000000'), ...
                             hex2dec('00000027'), ...
                             hex2dec('00001002'), ...
                             hex2dec('00000002'), ...
                             hex2dec('00000010'), ...
                             hex2dec('00000020'), ...
                             hex2dec('00000030'), ...
                             hex2dec('00000040'), ...
                             hex2dec('00000012'), ...
                             hex2dec('00000022'), ...
                             hex2dec('00000032'), ...
                             hex2dec('00000042'), ...
                             hex2dec('00000010'), ...
                             hex2dec('00000020'), ...
                             hex2dec('00000030'), ...
                             hex2dec('00000040'), ...
                             hex2dec('00000012'), ...
                             hex2dec('00000022'), ...
                             hex2dec('00000032'), ...
                             hex2dec('00000042'), ...
                             hex2dec('00000010'), ...
                             hex2dec('00000020'), ...
                             hex2dec('00000030'), ...
                             hex2dec('00000040'), ...
                             hex2dec('00000012'), ...
                             hex2dec('00000022'), ...
                             hex2dec('00000032'), ...
                             hex2dec('00000042'), ...
                             hex2dec('00000010'), ...
                             hex2dec('00000020'), ...
                             hex2dec('00000030'), ...
                             hex2dec('00000040'), ...
                             hex2dec('00000012'), ...
                             hex2dec('00000022'), ...
                             hex2dec('00000032'), ...
                             hex2dec('00000042'), ...
                             hex2dec('00000010'), ...
                             hex2dec('00000020'), ...
                             hex2dec('00000030'), ...
                             hex2dec('00000040'), ...
                             hex2dec('00000012'), ...
                             hex2dec('00000022'), ...
                             hex2dec('00000032') ];

        ADICalGet       = [ hex2dec('00000001'), ...
                            hex2dec('00000005'), ...
                            hex2dec('00001002'), ...
                            hex2dec('00000004'), ...
                            hex2dec('00000003') ];
    end

    methods (Access = public)

        
        function obj    =   DemoRad()
            if obj.DebugInf > 10
                disp('DemoRad Initialize')
            end
        end        
        
        function    delete(obj)

        end
        
        function    Ret     =   Dsp_SendSpiData(obj, SpiCfg, Regs)
            % Sends Data to device (selected by mask) using spi
            Regs    =   Regs(:);
            if (numel(Regs) > 28)
                Regs    =   Regs(1:28);
            end

            DspCmd          =   zeros(3 + numel(Regs), 1);
            Cod             =   hex2dec('9017');
            DspCmd(1)       =   SpiCfg.Mask;
            DspCmd(2)       =   1;
            DspCmd(3)       =   SpiCfg.Chn;
            DspCmd(4:end)   =   Regs;
            Ret             =   obj.CmdExec(0, Cod, DspCmd);
        end

        function    Ret     =   BrdGetChirp(obj, StrtPosn, StopPosn)
            % Returns Chirp(s) starting at startpos, ending at stoppos"""
            StopPosn        =   obj.InLim(StopPosn, 1, 128);
            StrtPosn        =   obj.InLim(StrtPosn, 0, StopPosn - 1);
            DspCmd          =   zeros(3,1);
            Cod             =   hex2dec('7003');
            DspCmd(1)       =   1;
            DspCmd(2)       =   StrtPosn;
            DspCmd(3)       =   StopPosn;
            Ret             =   obj.CmdReadData(0, Cod, DspCmd);
%             Chirps          =   StopPosn - StrtPosn;
%             Ret             =   obj.DataRead((obj.ChirpSize*Chirps));
%             obj.CmdRecv();
        end 

        function    Ret     =   Dsp_GetSwVers(obj)
            % Reads the Software Version from the DSP and disps it
            DspCmd      =   zeros(1,1);
            Cod         =   hex2dec('900E');
            DspCmd(1)   =   0;
            Ret         =   obj.CmdExec(0, Cod, DspCmd);
        end

        function    Ret     =   BrdGetSwVers(obj)
            Ret     =   obj.Dsp_GetSwVers();
        end

        function    BrdDispSwVers(obj);
            disp(' ');
            disp('-------------------------------------------------------------------');
            disp('FPGA Software UID');
            Vers    =   obj.Dsp_GetSwVers();
            if numel(Vers) > 2
                Tmp         =   Vers(1);
                SwPatch     =   floor(mod(Tmp, 2.^8));
                Tmp         =   floor(Tmp/2.^8);
                SwMin       =   floor(mod(Tmp, 2.^8));
                SwMaj       =   floor(Tmp/2.^8);
                disp([' Sw-Rev: ', num2str(SwMaj),'-',num2str(SwMin),'-',num2str(SwPatch)])    
                disp([' Sw-UID: ', num2str(Vers(2))])
                disp([' Hw-UID: ', num2str(Vers(3))])
            else
                disp('No version information available')
            end
            disp('-------------------------------------------------------------------');        
        end
    
        function    Ret     =   Dsp_GetBrdSts(obj)
            % Returns the Dsp Status. """
            Cmd             =   ones(1,1);
            Cod             =   hex2dec('6008');
            Ret             =   obj.CmdExec(0, Cod, Cmd);
        end

        function    Ret     =   Dsp_SetTestDat(obj, Ena)
            % Enables sinwave instead of measured data, 0 = disable
            Cmd             =   ones(2,1);
            Cod             =   hex2dec('6005');
            Cmd(2)          =   Ena;
            Ret             =   obj.CmdExec(0, Cod, Cmd);
        end
    
        function    Dsp_SetAdiDefaultConf(obj)
            % Returns the Dsp Status. """
            disp('Set ADI Defaults')
            Cmd             =   ones(2,1);
            Cod             =   hex2dec('6006');

            % This is necessary until a valid reconfiguration for the ADAR7251 is
            % available. If the ADAR7251 gets reconfigured the same way, when
            % sampling is running, only one frame is returned (blocks on spi_data_done on dsp)
            Cmd(2)          =   3;
            Ret             =   obj.CmdSend(0, Cod, Cmd);
            obj.DataSend(uint32(obj.ADR7251Cfg));
            Ret             =   obj.CmdRecv();

            Cmd(2)          =   4;
            Ret             =   obj.CmdSend(0, Cod, Cmd);
            obj.DataSend(uint32(obj.ADIFMCWCfg));
            Ret             =   obj.CmdRecv();
        end

        function    Ret     =   BrdRdEEPROM(obj, Addr)
            % Reads a 32bit value, starting at given address"""
            Cmd     =   ones(3, 1);
            Cod     =   hex2dec('9030');
            Cmd(2)  =   2;
            Cmd(3)  =   Addr;
            Ret     =   obj.CmdExec(0, Cod, Cmd);
        end
        
        function    Ret     =   BrdGetCalInf(obj)
            % Returns Cal Data from EEPROM
            disp('Get Cal Data');
            CalDat                  =   zeros(16,1);
            for Idx = 0:16-1
                CalDat(Idx + 1)     =   obj.BrdRdEEPROM(64 + Idx*4);
            end
            Idcs            =   find(CalDat > 2.^31);
            CalDat(Idcs)    =   CalDat(Idcs) - 2.^32;
            
            Ret.Type        =   CalDat(1);
            Ret.Date        =   CalDat(2);
            Ret.R           =   CalDat(3)./2^16;
            Ret.RCS         =   CalDat(4)./2^16;
            Ret.TxGain      =   CalDat(5)./2^16;
            Ret.IfGain      =   CalDat(6)./2^16;
            
        end
        
        function    Ret     =   BrdGetCalDat(obj)
            % Returns Cal Data from EEPROM
            disp('Get Cal Info');
            CalDat                  =   zeros(16,1);
            for Idx = 0:16-1
                CalDat(Idx + 1)     =   obj.BrdRdEEPROM(Idx*4);
            end
            Idcs            =   find(CalDat > 2.^31);
            CalDat(Idcs)    =   CalDat(Idcs) - 2.^32;
            
            CalDat          =   CalDat./2.^24;
            Ret             =   CalDat(1:2:end) + i.*CalDat(2:2:end); 
        end        

        function    Ret     = BrdGetUID(obj)
            % Returns the UID of the Device"""
            Cmd     = ones(2,1);
            Cod     = hex2dec('9030');
            Cmd(2)  = 0;
            Ret     =   obj.CmdExec(0, Cod, Cmd);
        end

        function    Ret     =   BrdRst(obj)
            % Resets the board, currently has no effect as there is no reliable way to
            % do this without reinitializing the usb connection"""
            disp('DemoRad.BrdRst')
            Cmd             =   ones(2,1);
            Cod             =   hex2dec('6006');
            Cmd(2)          =   5;
            Ret             =   obj.CmdExec(0, Cod, Cmd);
            obj.Dsp_MimoSeqRst();
        end

        function    Ret     =   BrdSampStp(obj)
            disp('Stop sampling')
            Cmd             =   ones(2,1);
            Cod             =   hex2dec('6006');
            Cmd(2)          =   6;
            Ret             =   obj.CmdExec(0, Cod, Cmd);
        end

        function    Ret     =   BrdPwrEna(obj)
            %   @function       BrdPwrEna
            %   @author         Philipp Wagner
            %   @date           07.12.2016
            %   @brief          Enable all power supplies for RF frontend
            PwrCfg      = [];
            Ret         = obj.Dsp_SetRfPwr(PwrCfg);
        end

        function    Ret     =   Dsp_Strt(obj)
            %   @function       Dsp_Strt
            %   @author         Philipp Wagner
            %   @date           07.12.2016
            %   @brief          Start application
            Cmd             =   ones(1,1);
            Cod             =   hex2dec('0x6004');
            Ret             =   obj.CmdExec(0, Cod, Cmd);
        end

        function    Dsp_SeqTrigRst(obj, Mask)
            disp('DemoRad.Dsp_SeqTrigRst not implemented')
        end

        function    Dsp_MimoSeqRst(obj)
            % TODO: not implemented, not needed?
            disp('DemoRad.Dsp_MimoSeqRst not implemented')
        end 

        function    Dsp_SetRfPwr(obj, Cfg)
            % TODO: not implemented, not needed. No option to enable/disable power for RF
            disp('DemoRad.Dsp_SetRfPwr not implemented')
        end

        function    Set(obj, stVal, varargin)
            
            switch stVal
                case 'DebugInf'
                    if nargin > 2
                        obj.DebugInf    =   varargin{1};
                    end 
                case 'Name'
                    if nargin > 2
                        if isstr(varargin{1})
                            obj.Name    =   varargin{1};
                        end 
                    end 
                case 'N'
                    if nargin > 2
                        Val         =   varargin{1};
                        Val         =   floor(Val);
                        Val         =   ceil(Val/8)*8;
                        obj.Rad_N   =   Val;
                    end 
                case 'Samples'
                    if nargin > 2
                        Val         =   varargin{1};
                        Val         =   floor(Val);
                        Val         =   ceil(Val/8)*8;
                    end
                case 'NrFrms'
                    if nargin > 2
                        NrFrms      =   floor(varargin{1});
                        if NrFrms < 1
                            NrFrms  =   1;
                        end
                        if NrFrms > 2.^31
                            NrFrms  =   2.^31;
                            disp('Limit Number of Frames');
                        end
                        obj.Rad_NrFrms  =   NrFrms;
                    end
                case 'NrChn'
                    if nargin > 2
                        NrChn       =   floor(varargin{1});
                        if NrChn < 1
                            NrChn   =   1;
                        end
                        if NrChn > 4
                            NrChn   =   4;
                        end
                        disp(['Set NrChn to: ', num2str(NrChn)]);
                        Mask4                       =   2.^4 - 1;
                        Mask                        =   2.^NrChn - 1;
                        obj.Rad_MaskChn             =   Mask;
                        obj.Rad_NrChn               =   NrChn;
                    end
                otherwise
            end
        end
        
        function    Ret     =   InLim(obj, Val, Low, High)
            Ret     =   Val;
            if Val < Low
                Val     =   Low;
            end
            if Val > High
                Val     =   High;
            end
        end
        
        % DOXYGEN ------------------------------------------------------
        %> @brief <span style="color: #ff0000;"> LowLevel: </span> Generate hanning window
        %>
        %> This function returns a hanning window.
        %>
        %>  @param[in]   M: window size
        %>
        %>  @param[In]   N (optional): Number of copies in second dimension
        function Win    =   hanning(obj, M, varargin)
            m   =   [-(M-1)/2: (M-1)/2].';
            Win =   0.5 + 0.5.*cos(2.*pi.*m/M);
            if nargin > 2
                M       =   varargin{1};
                M       =   M(1);
                Win     =   repmat(Win, 1, M);
            end
        end

        % DOXYGEN ------------------------------------------------------
        %> @brief <span style="color: #ff0000;"> LowLevel: </span> Generate hanning window
        %>
        %> This function returns a hamming window.
        %>
        %>  @param[in]   M: window size
        %>
        %>  @param[In]   N (optional): Number of copies in second dimension
        function Win    =   hamming(obj, M, varargin)
            m   =   [-(M-1)/2: (M-1)/2].';
            Win =   0.54 + 0.46.*cos(2.*pi.*m/M);
            if nargin > 2
                M       =   varargin{1};
                M       =   M(1);
                Win     =   repmat(Win, 1, M);
            end
        end        
        
        % DOXYGEN ------------------------------------------------------
        %> @brief <span style="color: #ff0000;"> LowLevel: </span> Generate boxcar window
        %>
        %> This function returns a boxcar window.
        %>
        %>  @param[in]   M: window size
        %>
        %>  @param[In]   N (optional): Number of copies in second dimension
        function Win    =   boxcar(obj, M, varargin)
            Win             =   ones(M,1);
            if nargin > 2
                M       =   varargin{1};
                M       =   M(1);
                Win     =   repmat(Win, 1, M);
            end
        end
        
        function    Ret     =   Get(obj, stVal)
            % TODO: decide what to do here.
            Ret     = [];
            switch stVal
                case 'DebugInf'
                    Ret     =   obj.DebugInf;
                case 'Name'
                    Ret     =   obj.Name;
                case 'N'
                    Ret     =   obj.Rad_N;
                case 'Samples'
                    Ret     =   obj.Rad_N;
                case 'NrFrms'
                    Ret     =   obj.Rad_NrFrms;
                case 'NrChn'
                    Ret     =   obj.Rad_NrChn;
                case 'FuSca'
                    obj.FuSca   = 0.498 / 65536;
                    Ret         = obj.FuSca;
                case 'fs'
                    Ret     =   1e6;
                otherwise
                    Ret     =   []; 
            end
        end

    end 
end
