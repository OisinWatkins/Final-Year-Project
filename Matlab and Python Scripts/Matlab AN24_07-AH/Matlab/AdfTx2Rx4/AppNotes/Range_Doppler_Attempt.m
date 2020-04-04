% Range_Doppler_Attempt
%   This .m  file will attempt to track the movement on the surface of the
%   patient's chest using ranged-doppler methods. The vast majority of this
%   script will be copied from AN24_7.m
%@author: Oisín Watkins
%@date: 18/06/18

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
Cfg.NrFrms          =   100;
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

mymap = [0.2 0.1 0.5
    0.1 0.5 0.8
    0.2 0.7 0.6
    0.8 0.7 0.3
    0.9 1 0];
clc

buffer = zeros(1,Cfg.NrFrms-1);

for Idx = 1:(Cfg.NrFrms-1)
    tic
    if Idx > 1
        Ts = ((timerValStop) + Ts)/2;
    else
        Ts = 0.2;       % Initial guess for Ts, likely inaccurate
    end
    
    % Record data for Tx1
    Data            =   Brd.BrdGetData();
    
    % Tx
    DataTx1         =   Data(1:Cfg.N,:);
    DataTx2         =   Data(Cfg.N+1:end,:);
    
    % Generate data of virtual uniform linear array
    % use mean of overlapping element
    VirtData(:,1:3)     =   DataTx1(:,1:3);
    VirtData(:,4)       =   0.5*(DataTx1(:,4) + DataTx2(:,1));
    VirtData(:,5:end)   =   DataTx2(:,2:end); 
    
    % Calculate range profile including calibration
    RP          =   fft(VirtData.*Win2D,NFFT,1).*Brd.FuSca/ScaWin;
    RPExt       =   RP(RMinIdx:RMaxIdx,:);    

    % calculate fourier transform over receive channels
    JOpt        =   fftshift(fft(RPExt.*WinAnt2D,NFFTAnt,2)/ScaWinAnt,2);
        
    % normalize cost function
    JdB         =   20.*log10(abs(JOpt));
    JMax        =   max(JdB(:));
    JNorm       =   JdB - JMax;
    JNorm(JNorm < -18)  =   -18;
    
    if Idx == 1
        Frame_Odd = JNorm;
        Diff = JNorm;
    elseif (rem(Idx,2) == 0)
        Frame_Even = JNorm;
        Diff = Frame_Even - Frame_Odd;
    else
        Frame_Odd = JNorm;
        Diff = Frame_Odd - Frame_Even;
    end
    
%     Diff = smoothdata(smoothdata(Diff));
    Mean_Info = zeros(1,47);
    for x = 1:233
        for k = 1:256
            if abs(Diff(x,k)) < 0.25
                Diff(x,k) = 0;
            end
            if x >= 105 && x <= 152
                Mean_Info(x-104) = mean(Diff(x,1:28)); %-10deg -> +10deg ; 0.5m -> 1.5m
            end
        end
    end
    
    Diff_interest = mean(Mean_Info);
    
    buffer = circshift(buffer,1);
    buffer(1) = Diff_interest;

    clc
    timerValStop = toc;
end

P2 = fft(buffer);
P1 = P2(1:((length(buffer))/2)+1);
P1(2:end-1) = 2*P1(2:end-1);

f = double((1/Ts)/(length(buffer)))*double((0:((length(buffer))/2)));
plot(f,P1);

surf(vAngDeg, vRangeExt, Diff);
xlabel('Ang (°)');
ylabel('Range (m)');
zlabel('Magnitude (dB)');
colormap(mymap);

%--------------------------------------------------------------------------
%Find the breath info in here
%--------------------------------------------------------------------------
Breath_is_in = real(P1(1:6));
[peaks, freq] = findpeaks(Breath_is_in);

Highest_peak = max(peaks);
for idx = 1:length(peaks)
    if peaks(idx) == Highest_peak
        break
    end
end

Respiriatory_Rate = f(freq(idx));
%--------------------------------------------------------------------------
%Find the HR info in here
%--------------------------------------------------------------------------
HR_is_in = real(P1(6:12));
[peaks, freq] = findpeaks(HR_is_in);

Highest_peak = max(peaks);
for idx = 1:length(peaks)
    if peaks(idx) == Highest_peak
        break
    end
end

Heart_Rate = f(freq(idx)+37);
%--------------------------------------------------------------------------
% Print data and power down
%--------------------------------------------------------------------------

Respiriatory_Rate = Respiriatory_Rate*60;
Heart_Rate = Heart_Rate*60;

Brd.BrdRst();
% Brd.BrdPwrDi();