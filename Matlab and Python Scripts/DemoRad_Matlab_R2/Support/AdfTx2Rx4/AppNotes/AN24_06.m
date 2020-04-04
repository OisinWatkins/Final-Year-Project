% AN24_06 -- Range-Doppler basics
% Evaluate the range-Doppler map for a single channel
clear all;
close all;

% (1) Connect to DemoRad: Check if Brd exists: Problem with USB driver
% (3) Configure RX
% (4) Configure TX
% (5) Start Measurements
% (6) Configure calculation of range profile and range doppler map for
% channel 1

c0          =   3e8;
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
TxPwr           =   80;
NrFrms          =   4;

%--------------------------------------------------------------------------
% Configure Transmitter (Antenna 0 - 4, Pwr 0 - 31)
%--------------------------------------------------------------------------
Brd.RfTxEna(1, TxPwr);

%--------------------------------------------------------------------------
% Configure Up-Chirp
% TRamp is only used for chirp rate calculation!!
% TRamp, N, Tp can not be altered in the current framework
% Effective bandwidth is reduced as only 256 us are sampled from the 280 us
% upchirp.
% Only the bandwidth can be altered
% 
% The maximum number of chirps is StrtIdx = 0 and StopIdx = 128
%--------------------------------------------------------------------------
Cfg.fStrt       =   24.0e9;
Cfg.fStop       =   24.3e9;
Cfg.TRampUp     =   280e-6;
Cfg.Tp          =   284e-6;
Cfg.N           =   256;
Cfg.StrtIdx     =   0;
Cfg.StopIdx     =   150;
Cfg.Np          =   Cfg.StopIdx - Cfg.StrtIdx;

Brd.RfMeas('Adi', Cfg);

%--------------------------------------------------------------------------
% Read actual configuration
%--------------------------------------------------------------------------
NrChn           =   Brd.Get('NrChn');
N               =   Brd.Get('N');
fs              =   Brd.Get('fs');

%--------------------------------------------------------------------------
% Configure Signal Processing
%--------------------------------------------------------------------------
% Processing of range profile
Win2D           =   Brd.hanning(N,Cfg.Np);
ScaWin          =   sum(Win2D(:,1));
NFFT            =   2^12;
NFFTVel         =   2^8;
kf              =   (Cfg.fStop - Cfg.fStrt)/Cfg.TRampUp;
vRange          =   [0:NFFT-1].'./NFFT.*fs.*c0/(2.*kf);
fc              =   (Cfg.fStop + Cfg.fStrt)/2;

RMin            =   0.5;
RMax            =   10;

[Val RMinIdx]   =   min(abs(vRange - RMin));
[Val RMaxIdx]   =   min(abs(vRange - RMax));
vRangeExt       =   vRange(RMinIdx:RMaxIdx);

WinVel          =   Brd.hanning(Cfg.Np);
ScaWinVel       =   sum(WinVel);
WinVel2D        =   repmat(WinVel.',numel(vRangeExt),1);

vFreqVel        =   [-NFFTVel./2:NFFTVel./2-1].'./NFFTVel.*(1/Cfg.Tp);
vVel            =   vFreqVel*c0/(2.*fc); 

disp('Get Measurement data')
for Idx = 1:1000
    
    Data        =   Brd.BrdGetData();     
    
    MeasChn     =   reshape(Data(:,1),N,Cfg.Np);
    % Calculate range profile including calibration
    RP          =   fft(MeasChn.*Win2D,NFFT,1).*Brd.FuSca/ScaWin;
    RPExt       =   RP(RMinIdx:RMaxIdx,:);    

    RD          =   fft(RPExt.*WinVel2D, NFFTVel, 2)./ScaWinVel;
    RD          =   fftshift(RD, 2);

    % Display range profile
%         figure(1)
%         plot(vRangeExt, 20.*log10(abs(RPExt)));
%         grid on;
%         xlabel('R (m)');
%         ylabel('X (dBV)');
%         axis([vRangeExt(1) vRangeExt(end) -120 -40])

    % Display range doppler map
    figure(2)
    imagesc(vVel, vRangeExt, abs(RD));
    grid on;
    xlabel('v (m/s)');
    ylabel('R (m)');
    colormap('jet')

    drawnow
    
end

