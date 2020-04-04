% AN24_02 -- FMCW Basics 
clear all;
close all;

% (1) Connect to DemoRad: Check if Brd exists: Problem with USB driver
% (3) Configure RX
% (4) Configure TX
% (5) Start Measurements
% (6) Configure calculation of range profile

%--------------------------------------------------------------------------
% Include all necessary directories
%--------------------------------------------------------------------------
CurPath = pwd();
addpath([CurPath,'/../../DemoRadUsb']);
addpath([CurPath,'/../../Class']);

%--------------------------------------------------------------------------
% Setup Connection
%--------------------------------------------------------------------------
Brd         =   Adf24Tx2Rx4();

Brd.BrdRst();

%--------------------------------------------------------------------------
% Software Version
%--------------------------------------------------------------------------
Brd.BrdDispSwVers();

%--------------------------------------------------------------------------
% Configure Receiver
%--------------------------------------------------------------------------
Brd.RfRxEna();
TxPwr           =   50;
NrFrms          =   4;

%--------------------------------------------------------------------------
% Configure Transmitter (Antenna 0 - 4, Pwr 0 - 31)
%--------------------------------------------------------------------------
Brd.RfTxEna(2, TxPwr);

%--------------------------------------------------------------------------
% Configure Up-Chirp
% TRamp is only used for chirp rate calculation!!
% TRamp, N, Tp can not be altered in the current framework
% Effective bandwidth is reduced as only 256 us are sampled from the 280 us
% upchirp.
% Only the bandwidth can be altered
%--------------------------------------------------------------------------

Cfg.fStrt       =   24.0e9;
Cfg.fStop       =   24.25e9;
Cfg.TRampUp     =   280e-6;
Cfg.Tp          =   284e-6;
Cfg.N           =   256;
Cfg.StrtIdx     =   1;
Cfg.StopIdx     =   2;

Brd.RfMeas('Adi', Cfg);


disp('Get Measurement data')
for Idx = 1:1000
    
    Data        =   Brd.BrdGetData();     
       
    plot(Data)
    drawnow()
    
end

