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
TxPwr           =   100;
NrFrms          =   4;

%--------------------------------------------------------------------------
% Configure Transmitter (Antenna 0 - 2, Pwr 0 - 100)
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
Cfg.fs          =   1.0e6;
Cfg.fStrt       =   23.95e9;
Cfg.fStop       =   24.25e9;
Cfg.TRampUp     =   260/Cfg.fs;             
Cfg.Tp          =   300/Cfg.fs;
Cfg.N           =   256;
Cfg.StrtIdx     =   0;
Cfg.StopIdx     =   1;
Cfg.MimoEna     =   1;

Brd.RfMeas('Adi', Cfg);

n   =   [0:Cfg.N-1].';

%--------------------------------------------------------------------------
% Read actual configuration
%--------------------------------------------------------------------------
NrChn           =   Brd.Get('NrChn');
N               =   Brd.Get('N');
fs              =   Brd.Get('fs');

Win2D           =   Brd.hanning(N,NrChn);
ScaWin          =   sum(Win2D(:,1));
NFFT            =   2^12;

Freq            =   [0:NFFT-1].'./NFFT.*fs;

disp('Get Measurement data')
RPPsd           =   zeros(NFFT,4);

for Idx = 1:10000
    
    Data        =   Brd.BrdGetData();     
    RP          =   fft(Data(:,:).*Win2D,NFFT,1).*Brd.FuSca/ScaWin;
    
    
    RPPsd       =   RPPsd + abs(RP)/100;
    
    figure(1)
    plot(Freq, 20.*log10(abs(RP)))
    axis([0 fs -160 -40])
    grid on;
    
    figure(2)
    plot(n, Data)
    drawnow()
    
   
end

figure(10)
plot(Freq/1e3, 20.*log10(abs(RPPsd)))
axis([0 fs/1e3 -160 -40])
grid on;
