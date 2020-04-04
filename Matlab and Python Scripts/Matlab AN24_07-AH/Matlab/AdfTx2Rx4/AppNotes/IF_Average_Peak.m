% IF_Average_Peak
%   This matlab file takes the IF data of all 4 Rx channels, filters it,
%   computes its FFT then takes the Average frequency of the FFT's largest
%   peak frequencies. We then FFT that array in the hope that information
%   about the HR will be present 
%@author: Oisín Watkins
%@date: 15/06/18

clear;
clc;

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
Cfg.fStrt           =   24e9;
Cfg.fStop           =   24.25e9;
Cfg.TRampUp         =   280e-6;
Cfg.Tp              =   284e-6;
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

%--------------------------------------------------------------------------
% Next line was added by Oisín Watkins
Freq            =   [0:NFFT-1].'./NFFT.*fs;
%--------------------------------------------------------------------------

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


% All of above was taken from AN24_07.m
Modes = zeros(4,100);

for Idx = 1:(Cfg.NrFrms-1)
    
    Data            =   Brd.BrdGetData();
    
    DataTx1         =   Data(1:Cfg.N,:);
    DataTx2         =   Data(Cfg.N+1:end,:);
    
    FiltTX1         =   smoothdata(smoothdata(DataTx1));
    FiltTX2         =   smoothdata(smoothdata(DataTx2));
    
    filt_FFT1       =   abs(fftshift(fft(FiltTX1)));
    filt_FFT2       =   abs(fftshift(fft(FiltTX2)));
    
    [RX0_peaks,RX0_Freqs] = findpeaks(filt_FFT1(:,1));
    [RX1_peaks,RX1_Freqs] = findpeaks(filt_FFT1(:,2));
    [RX2_peaks,RX2_Freqs] = findpeaks(filt_FFT1(:,3));
    [RX3_peaks,RX3_Freqs] = findpeaks(filt_FFT1(:,4));
    
    if length(RX0_Freqs) > 6
        Peak_RX0 = mode(RX0_Freqs((int16(length(RX0_Freqs)/4):int16(3*length(RX0_Freqs)/4))));
    else
        Peak_RX0 = mode(RX0_Freqs);
    end
    
    if length(RX1_Freqs) > 6
        Peak_RX1 = mode(RX1_Freqs((int16(length(RX1_Freqs)/4):int16(3*length(RX1_Freqs)/4))));
    else
        Peak_RX1 = mode(RX1_Freqs);
    end
    
    if length(RX2_Freqs) > 6
        Peak_RX2 = mode(RX2_Freqs((int16(length(RX2_Freqs)/4):int16(3*length(RX2_Freqs)/4))));
    else
        Peak_RX2 = mode(RX2_Freqs);
    end
    
    if length(RX3_Freqs) > 6
        Peak_RX3 = mode(RX3_Freqs((int16(length(RX3_Freqs)/4):int16(3*length(RX3_Freqs)/4))));
    else
        Peak_RX3 = mode(RX3_Freqs);
    end
    
    Modes         =   circshift(Modes,[0,1]);
    Modes(:,1)    =   [Peak_RX0; Peak_RX1; Peak_RX2; Peak_RX3];
    Modes(:,50)   =   [0;0;0;0];
    
    Movement        =   abs(fftshift(fft(Modes)));
    Movement        =   Movement';
    
    figure(1)
    plot(Movement)
    axis([50,100,0,500]);
%     legend('Movement 1','Movement 2','Movement 3','Movement 4')
    
end

Brd.BrdRst();
Brd.BrdPwrDi();