function varargout = Track_Mult_Objects(varargin)
% TRACK_MULT_OBJECTS MATLAB code for Track_Mult_Objects.fig
%      TRACK_MULT_OBJECTS, by itself, creates a new TRACK_MULT_OBJECTS or raises the existing
%      singleton*.
%
%      H = TRACK_MULT_OBJECTS returns the handle to a new TRACK_MULT_OBJECTS or the handle to
%      the existing singleton*.
%
%      TRACK_MULT_OBJECTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACK_MULT_OBJECTS.M with the given input arguments.
%
%      TRACK_MULT_OBJECTS('Property','Value',...) creates a new TRACK_MULT_OBJECTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Track_Mult_Objects_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Track_Mult_Objects_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Track_Mult_Objects

% Last Modified by GUIDE v2.5 24-Sep-2018 09:35:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Track_Mult_Objects_OpeningFcn, ...
                   'gui_OutputFcn',  @Track_Mult_Objects_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Track_Mult_Objects is made visible.
function Track_Mult_Objects_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Track_Mult_Objects (see VARARGIN)

% Choose default command line output for Track_Mult_Objects
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Track_Mult_Objects wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Track_Mult_Objects_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
Resolution = str2double(get(handles.FreqRes,'String'));

Cfg.fStrt           =   24e9;
Cfg.fStop           =   24.25e9;
Cfg.TRampUp         =   280e-6;
Cfg.Tp              =   284e-6;
Cfg.N               =   256;
Cfg.NrFrms          =   1000;
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

Freq            =   [0:NFFT-1].'./NFFT.*fs;

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

%------------------------------------------------------------------------------
% Provide colourmap for Range Profile
%------------------------------------------------------------------------------
mymap = [0.2 0.1 0.5
    0.1 0.5 0.8
    0.2 0.7 0.6
    0.8 0.7 0.3
    0.9 1 0];

MaxDur = str2double(get(handles.TestDuration, 'String'));
Time_of_Test = clock;
Time_of_Test_Int = int32(Time_of_Test);
CurrentDuration = 0;

Idx = 1;

while true
    
    Data            =   Brd.BrdGetData();
    %----------------------------------------------------------------------
    % Creat virtual 8 channels
    %----------------------------------------------------------------------
    DataTx1         =   Data(1:Cfg.N,:);
    DataTx2         =   Data(Cfg.N+1:end,:);
    
    %----------------------------------------------------------------------
    % Generate data of virtual uniform linear array
    % use mean of overlapping element
    %----------------------------------------------------------------------
    VirtData(:,1:3)     =   DataTx1(:,1:3);
    VirtData(:,4)       =   0.5*(DataTx1(:,4) + DataTx2(:,1));
    VirtData(:,5:end)   =   DataTx2(:,2:end);
    
    %----------------------------------------------------------------------
    % Calculate range profile including calibration
    %----------------------------------------------------------------------
    RP          =   fft(VirtData.*Win2D,NFFT,1).*Brd.FuSca/ScaWin;
    RPExt       =   RP(RMinIdx:RMaxIdx,:);
    
    %----------------------------------------------------------------------
    % calculate fourier transform over receive channels
    %----------------------------------------------------------------------
    JOpt        =   fftshift(fft(RPExt.*WinAnt2D,NFFTAnt,2)/ScaWinAnt,2);
    
    %----------------------------------------------------------------------
    % normalize cost function
    %----------------------------------------------------------------------
    JdB         =   20.*log10(abs(JOpt));
    JMax        =   max(JdB(:));
    JNorm       =   JdB - JMax;
    JNorm(JNorm < -18)  =   -18;
    
    %----------------------------------------------------------------------
    % Copy Range profile magnitudes to frames then preform differencing
    % algorithm. Provides movement information
    %----------------------------------------------------------------------
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
    
    %----------------------------------------------------------------------
    % Now find the peaks of this differenced range profile, use that
    % value to threshold the profile, the track the peaks
    %----------------------------------------------------------------------
    
    
    Idx = Idx+1;
    CurrentTime = clock;
    CurrentDuration = (CurrentTime(1,5) + CurrentTime(1,6)/60) - (Time_of_Test(1,5) + Time_of_Test(1,6)/60);

    if CurrentDuration >= MaxDur
        break
    end
end



function TestDuration_Callback(hObject, eventdata, handles)
% hObject    handle to TestDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TestDuration as text
%        str2double(get(hObject,'String')) returns contents of TestDuration as a double


% --- Executes during object creation, after setting all properties.
function TestDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
