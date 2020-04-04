% @date 04/12/17
% @author Oisin Watkins
% @description:
%
%       The goal of this file is to create a program which removes some
%       layers of abstraction from the previous files which have been
%       written to control the DemoRad. When this file is complete it's my
%       hope to be able to control the DemoRad from the command line.
%
%       Pending completion of this above goal, the next task is to make the
%       same program application specific, in this instance a contactless
%       vital-signs monitor application.
%
% @version 1.0.0

%--------------------------------------------------------------------------
% Clear command line and workspace before beginning
%--------------------------------------------------------------------------
clear
clc

%--------------------------------------------------------------------------
% Include all necessary directories
%--------------------------------------------------------------------------
CurPath = pwd();
addpath([CurPath,'/../../DemoRadUsb']);
addpath([CurPath,'/../../Class']);

%--------------------------------------------------------------------------
% Define Constants
%--------------------------------------------------------------------------
c0 = 3e8; 

Brd     =   Adf24Tx2Rx4();

%--------------------------------------------------------------------------
% Reset Board and Enable Power Supply
%--------------------------------------------------------------------------
Brd.BrdRst();

%--------------------------------------------------------------------------
% Read calibration data
% Generate cal data for Tx1 and Tx2
%--------------------------------------------------------------------------
CalDat          =   Brd.BrdGetCalDat();
CalDat          =   CalDat;
CalDatTx1       =   CalDat(1:4);
CalDatTx2       =   CalDat(5:8);

%--------------------------------------------------------------------------
% Enable Receive Chips
%--------------------------------------------------------------------------
Brd.RfRxEna();

%--------------------------------------------------------------------------
% Writing regesters individually for each device...? Not sure if it will
% work ;_;
%--------------------------------------------------------------------------
ADF4159_InitSeq      =    [ hex2dec('00000007'), ...
                            hex2dec('00001F46'), ...
                            hex2dec('00800006'), ...
                            hex2dec('00380835'), ...
                            hex2dec('01800005'), ...
                            hex2dec('00781904'), ...
                            hex2dec('00780144'), ...
                            hex2dec('00C20433'), ...
                            hex2dec('07408052'), ...
                            hex2dec('00000009'), ...
                            hex2dec('783C1000')];
                        
ADF5901_InitSeq      =    [ hex2dec('02000007'), ...
                            hex2dec('0000002B'), ...
                            hex2dec('0000000B'), ...
                            hex2dec('1D32A64A'), ...
                            hex2dec('2A20B929'), ...
                            hex2dec('40003E88'), ...
                            hex2dec('809FE520'), ...
                            hex2dec('011F4827'), ...
                            hex2dec('00000006'), ...
                            hex2dec('01E28005'), ...
                            hex2dec('02000004'), ...
                            hex2dec('01890803'), ...
                            hex2dec('00020642'), ...
                            hex2dec('FFF7FFE1'), ...
                            hex2dec('809FE720'), ...
                            hex2dec('809FE560'), ...
                            hex2dec('809FED60'), ...
                            hex2dec('809FE5A0'), ...
                            hex2dec('809FF5A0'), ...
                            hex2dec('2800B929'), ...
                            hex2dec('809F25A0')];
                        
ADF5904_InitSeq      =    [ hex2dec('00000003'), ...
                            hex2dec('00020406'), ...
                            hex2dec('20001499'), ...
                            hex2dec('40001499'), ...
                            hex2dec('60001499'), ...
                            hex2dec('80001499'), ...
                            hex2dec('A0000019'), ...
                            hex2dec('80007CA0')];
                        
ADR7251_Cfg           =   [ hex2dec('00000000'), ...
                            hex2dec('0000004B'), ...
                            hex2dec('00001203'), ...
                            hex2dec('00013307'), ...
                            hex2dec('01C20001'), ...
                            hex2dec('00000002'), ...
                            hex2dec('00010064'), ...            % M
                            hex2dec('0002004C'), ...            % N
                            hex2dec('00032833'), ...            % PLL Control
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
                        
Brd.RfAdf5904SetRegs(1, ADF5904_InitSeq);
%Readback Register Values, change reg values and read again to be certain
DevAdf5904.PrntRegMap()

prompt = 'Continue? ';
Cnt = input(prompt);

Brd.RfAdf4159SetRegs(1, ADF4159_InitSeq);
%--------------------------------------------------------------------------
% Configure Transmitter (Antenna 0 - 2, Pwr 0 - 100)
%--------------------------------------------------------------------------
Brd.RfTxEna(1, 100);

%--------------------------------------------------------------------------
% Will make while loop follow here, may move some of above code in here
% later
%--------------------------------------------------------------------------
% prompt = 'Enter Commands below this line: '
% Run = 1;

% while Run == 1
%     cmd = input(prompt, 's');
%     
%     if ~isempty(cmd)
%         switch cmd
%             case 'a'
%                 disp('That was an a')
%             case 'b'
%                 disp('That was a b')
%             case 'end'
%                 Run = 0;
%                 disp('Execution halted')
%         end
%     else
%         disp('No Command Given');
%     end
% end

Brd.BrdRst();
Brd.BrdPwrDi();