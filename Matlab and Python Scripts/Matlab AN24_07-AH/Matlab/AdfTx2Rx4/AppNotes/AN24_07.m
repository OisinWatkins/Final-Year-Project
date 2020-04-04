% AN24_07 -- Calculate DBF with two TX antenna
%
% (1) Connect to DemoRad: Check if Brd exists: Problem with USB driver
% (3) Configure RX
% (4) Configure TX
% (5) Start Measurements and configure MIMO mode with switching between TX
% (6) Configure calculation of range profile and DBF
% (7) Measure and eveluate cost function

clear;
%close all;

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
% Software Version
%--------------------------------------------------------------------------
Brd.BrdDispSwVers();

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
% Configure Transmitter (Antenna 0 - 2, Pwr 0 - 100)
%--------------------------------------------------------------------------
Brd.RfTxEna(1, 100);

%--------------------------------------------------------------------------
% Configure Up-Chirp
% TRamp is only used for chirp rate calculation!!
% TRamp, N, Tp can not be altered in the current framework
% Effective bandwidth is reduced as only 256 us are sampled from the 280 us
% upchirp.
% Only the bandwidth can be altered
%--------------------------------------------------------------------------
Cfg.fStrt           =   24.05e9;
Cfg.fStop           =   24.25e9;
Cfg.TRampUp         =   260e-6;
Cfg.Tp              =   300e-6;
Cfg.N               =   256;
Cfg.NrFrms          =   10000;
Cfg.StrtIdx         =   0;
Cfg.StopIdx         =   2;
Cfg.MimoEna         =   1;

%--------------------------------------------------------------------------
% Configure Mimo Mode
% 0: static activation of TX antenna no switching
% 1: TX1/Tx2 
%--------------------------------------------------------------------------
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
Win2D           =   Brd.hanning(N,2*NrChn-1);
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
WinAnt          =   Brd.hanning(2*NrChn-1);
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
VirtData        =   zeros(Cfg.N, 7);

mCalDatTx1      =   repmat(CalDatTx1.',Cfg.N,1);
mCalDatTx2      =   repmat(CalDatTx2.',Cfg.N,1);


for Idx = 1:Cfg.NrFrms
    
    % Record data for Tx1
    Data            =   Brd.BrdGetData(); 
    
    % Tx1 
    DataTx1         =   Data(1:Cfg.N,:).*mCalDatTx1;
    DataTx2         =   Data(Cfg.N+1:end,:).*mCalDatTx2;
    
    figure(100)
    plot(Data(1:Cfg.N,:))
    
    figure(200)
    plot(Data(Cfg.N+1:end,:))
    
    % Generate data of virtual uniform linear array
    % use mean of overlapping element
    VirtData(:,1:3)     =   DataTx1(:,1:3);
    VirtData(:,4)       =   0.5*(DataTx1(:,4) + DataTx2(:,1));
    VirtData(:,5:end)   =   DataTx2(:,2:end); 
    
    % Calculate range profile including calibration
    RP          =   fft(VirtData.*Win2D,NFFT,1).*Brd.FuSca/ScaWin;
    RPExt       =   RP(RMinIdx:RMaxIdx,:);    
    % After this point select FFT bin
    
    figure(20)
    plot(abs(fftshift(fft(DataTx1))))

    % calculate fourier transform over receive channels
    JOpt        =   fftshift(fft(RPExt.*WinAnt2D,NFFTAnt,2)/ScaWinAnt,2);
        
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

Brd.BrdRst();
Brd.BrdPwrDi();




