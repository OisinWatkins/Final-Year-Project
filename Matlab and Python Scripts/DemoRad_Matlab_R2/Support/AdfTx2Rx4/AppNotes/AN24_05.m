% AN24_05 -- Calculate DBF with one TX antenna
clear all;
close all;

% (1) Connect to DemoRad: Check if Brd exists: Problem with USB driver
% (3) Configure RX
% (4) Configure TX
% (5) Start Measurements
% (6) Configure calculation of range profile and DBF
% (7) Measure and eveluate cost function

%--------------------------------------------------------------------------
% Include all necessary directories
%--------------------------------------------------------------------------
CurPath = pwd();
addpath([CurPath,'/../../DemoRadUsb']);
addpath([CurPath,'/../../Class']);


c0          =   3e8;
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
% Configure Transmitter (Antenna 0 - 4, Pwr 0 - 31)
%--------------------------------------------------------------------------
Brd.RfTxEna(1, TxPwr);

%--------------------------------------------------------------------------
% Read calibration data
%--------------------------------------------------------------------------
CalDat          =   Brd.BrdGetCalDat();
CalDat          =   CalDat(1:4);

%--------------------------------------------------------------------------
% Configure Up-Chirp
% TRamp is only used for chirp rate calculation!!
% TRamp, N, Tp can not be altered in the current framework
% Effective bandwidth is reduced as only 256 us are sampled from the 280 us
% upchirp.
% Only the bandwidth can be altered
%--------------------------------------------------------------------------
Cfg.fStrt       =   24.0e9;
Cfg.fStop       =   24.3e9;
Cfg.TRampUp     =   280e-6;
Cfg.Tp          =   284e-6;
Cfg.N           =   256;
Cfg.StrtIdx     =   1;
Cfg.StopIdx     =   2;
Brd.RfMeas('Adi', Cfg);

%--------------------------------------------------------------------------
% Read actual configuration
%--------------------------------------------------------------------------
NrChn           =   Brd.Get('NrChn');
N               =   Brd.Get('N');
fs              =   Brd.Get('fs');

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
Win2D           =   Brd.hanning(N,NrChn);
ScaWin          =   sum(Win2D(:,1));
NFFT            =   2^12;
kf              =   (Cfg.fStop - Cfg.fStrt)/Cfg.TRampUp;
vRange          =   [0:NFFT-1].'./NFFT.*fs.*c0/(2.*kf);

RMin            =   0.5;
RMax            =   10;

[Val RMinIdx]   =   min(abs(vRange - RMin));
[Val RMaxIdx]   =   min(abs(vRange - RMax));
vRangeExt       =   vRange(RMinIdx:RMaxIdx);

% Window function for receive channels
NFFTAnt         =   256;
WinAnt          =   Brd.hanning(NrChn);
ScaWinAnt       =   sum(WinAnt);
WinAnt2D        =   repmat(WinAnt.',numel(vRangeExt),1);
vAngDeg         =   asin(2*[-NFFTAnt./2:NFFTAnt./2-1].'./NFFTAnt)./pi*180;

% Calibration data
mCalData        =   repmat(CalDat.',N,1);

% Positions for polar plot of cost function
vU              =   linspace(-1,1,NFFTAnt);
[mRange , mU]   =   ndgrid(vRangeExt,vU);
mX              =   mRange.*mU;
mY              =   mRange.*cos(asin(mU));


disp('Get Measurement data')
for Idx = 1:1000
    
    Data        =   Brd.BrdGetData();     
    
    % Calculate range profile including calibration
    RP          =   fft(Data.*Win2D.*mCalData,NFFT,1).*Brd.FuSca/ScaWin;
    RPExt       =   RP(RMinIdx:RMaxIdx,:);    
    
    % Display range profile
    figure(1)
    plot(vRangeExt, 20.*log10(abs(RPExt)));
    grid on;
    xlabel('R (m)');
    ylabel('X (dBV)');
    axis([vRangeExt(1) vRangeExt(end) -100 -20])
    
    % calculate fourier transform over receive channels
    JOpt        =   fftshift(fft(RPExt.*WinAnt2D,NFFTAnt,2)/ScaWinAnt,2);
    
    figure(2)
    imagesc(vAngDeg, vRangeExt, 20.*log10(abs(JOpt)));
    xlabel('Ang (°)');
    ylabel('R (m)');
    colormap('jet');
    
    % normalize cost function
    JdB         =   20.*log10(abs(JOpt));
    JMax        =   max(JdB(:));
    JNorm       =   JdB - JMax;
    JNorm(JNorm < -18)  =   -18;
    
    figure(3)
    imagesc(vAngDeg, vRangeExt, JNorm);
    xlabel('Ang (°)');
    ylabel('R (m)');
    colormap('jet');    
    
    % generate polar plot
    figure(4);
    surf(mX,mY, JNorm); 
    shading flat;
    view(0,90);
    axis equal
    xlabel('x (m)');
    ylabel('y (m)');
    colormap('jet');
    drawnow;
    
end

