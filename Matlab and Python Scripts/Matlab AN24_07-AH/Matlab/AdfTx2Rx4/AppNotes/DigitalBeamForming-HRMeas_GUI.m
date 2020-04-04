function varargout = DigitalBeamForming-HRMeas_GUI(varargin)
% RANGEDOPPLERATTEMPT_GUI MATLAB code for RangeDopplerAttempt_GUI.fig
%      RANGEDOPPLERATTEMPT_GUI, by itself, creates a new RANGEDOPPLERATTEMPT_GUI or raises the existing
%      singleton*.
%
%      H = RANGEDOPPLERATTEMPT_GUI returns the handle to a new RANGEDOPPLERATTEMPT_GUI or the handle to
%      the existing singleton*.
%
%      RANGEDOPPLERATTEMPT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RANGEDOPPLERATTEMPT_GUI.M with the given input arguments.
%
%      RANGEDOPPLERATTEMPT_GUI('Property','Value',...) creates a new RANGEDOPPLERATTEMPT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RangeDopplerAttempt_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RangeDopplerAttempt_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RangeDopplerAttempt_GUI

% Last Modified by GUIDE v2.5 24-Jan-2019 10:16:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RangeDopplerAttempt_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @RangeDopplerAttempt_GUI_OutputFcn, ...
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


% --- Executes just before RangeDopplerAttempt_GUI is made visible.
function RangeDopplerAttempt_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RangeDopplerAttempt_GUI (see VARARGIN)

% Choose default command line output for RangeDopplerAttempt_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes RangeDopplerAttempt_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RangeDopplerAttempt_GUI_OutputFcn(hObject, eventdata, handles) 
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
Cfg.NrFrms          =   int32(1/(0.05*Resolution)); % 0.05 is an estimate for the sampling period of the for loop below on this machine
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
% Initialising data for the measurement buffer, number of measurements,
% maximum duration of the test and the save directories of all files
% generated.
%------------------------------------------------------------------------------
buffer = zeros(1,Cfg.NrFrms-1);

itr = str2double(get(handles.NumMeas,'String'));
current = 0;

MaxDur = str2double(get(handles.TestDur, 'String'));
Time_of_Test = clock;
Time_of_Test_Int = int32(Time_of_Test);
Day_Hour_Minute_Second = strcat(' ',num2str(Time_of_Test_Int(:,1)),' ',num2str(Time_of_Test_Int(:,2)),' ', num2str(Time_of_Test_Int(:,3)),' ',num2str(Time_of_Test_Int(:,4)),'-',num2str(Time_of_Test_Int(:,5)),'-',num2str(Time_of_Test_Int(:,6)));
CurrentDuration = 0;

% FileInit = strcat('C:\Users\Oisin Watkins\Desktop\FYP\Contactless HR\Matlab and Python Scripts\Matlab AN24_07-AH\Matlab\AdfTx2Rx4\AppNotes\Wave Files\BeatSigData_',Day_Hour_Minute_Second);

HR_File = strcat(get(handles.SaveDirect, 'String'),'\HeartRateMeas_',Day_Hour_Minute_Second,'.xlsx');
Heart_Info_Array = [];
HR_buffer = [0];
Heart_Rate = 0;

%------------------------------------------------------------------------------
% Clear all data printed to the terminal and begin measurement
%------------------------------------------------------------------------------
clc
while true
    for Idx = 1:(Cfg.NrFrms-1)
        tic
        if Idx > 1
            Ts = ((timerValStop) + Ts)/2;   % Sampling period for the range profile
        else
            Ts = 0.1;       % Initial guess for Ts, likely inaccurate
        end
        
        %----------------------------------------------------------------------
        % Record data for Tx1
        %----------------------------------------------------------------------
%         num = num2str(Idx);
%         FileName1 = strcat(FileInit, '_Rx0_', num, '.wav');
%         FileName2 = strcat(FileInit, '_Rx1_', num, '.wav');
%         FileName3 = strcat(FileInit, '_Rx2_', num, '.wav');
%         FileName4 = strcat(FileInit, '_Rx3_', num, '.wav');
        
        Data            =   Brd.BrdGetData();
        Data = smoothdata(Data);
        
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
        % Filter data based on size of movement (Threshold) and based
        % on location of movement relative to the device
        %----------------------------------------------------------------------
        maximum = -10000; % Sufficiently small, most magnitudes will be <0
        Range_Of_Interest = 0;
        for x = 1:233
            for k = 1:256
                if abs(Diff(x,k)) < 0.5 % Threshold the detected movement
                    Diff(x,k) = 0;
                end
                if Diff(x,k) > maximum
                    maximum = Diff(x,k);
                    Range_Of_Interest = x;
                end
            end
        end
        
        %----------------------------------------------------------------------
        % Measurement of interest. Save to first index of buffer
        %----------------------------------------------------------------------
        buffer = circshift(buffer,1);
        buffer(1) = vRangeExt(Range_Of_Interest,1);
        
        clc
        timerValStop = toc;
    end
    
    %--------------------------------------------------------------------------
    % Preform FFT and plot to GUI inside a try-catch
    %--------------------------------------------------------------------------
    try
        P2 = fft(buffer);
        P1 = P2(1:((length(buffer))/2)+1);
        P1(2:end-1) = 2*P1(2:end-1);
        P1 = smoothdata(P1);
        f = double((1/Ts)/(length(buffer)))*double((0:((length(buffer))/2)));
        
        axes(handles.axes1)
        plot(f,P1);
        xticks([1:1:12]);
        xlabel('Frequency (Hz)');
        ylabel('Power');
    
        %--------------------------------------------------------------------------
        % Print Differenced Range Profile for context
        %--------------------------------------------------------------------------
        axes(handles.axes2)
        surf(vAngDeg, vRangeExt, Diff);
        xlabel('Ang (°)');
        ylabel('Range (m)');
        zlabel('Magnitude (dB)');
        colormap('jet');
    
        %--------------------------------------------------------------------------
        %Find the breath info in here
        %--------------------------------------------------------------------------
        Breath_is_in = real(P1(int32(0.2*(Ts*(Cfg.NrFrms-1))):int32(0.8*(Ts*(Cfg.NrFrms-1)))+1)); % 0.2Hz - 0.8Hz
        [peaks, freq] = findpeaks(Breath_is_in);
    
        Highest_peak = max(peaks);
        for idx = 1:length(peaks)
            if peaks(idx) == Highest_peak
                break
            end
        end
    
        Respiratory_Rate = f(freq(idx));
        
        %--------------------------------------------------------------------------
        %Find the HR info in here
        %--------------------------------------------------------------------------
        HR_is_in = real(P1(int32(0.8*(Ts*(Cfg.NrFrms-1))):int32(2*(Ts*(Cfg.NrFrms-1))))); % 0.8Hz - 2Hz
        [peaks, freq] = findpeaks(HR_is_in);
    
        Highest_peak = max(peaks);
        for idx = 1:length(peaks)
            if peaks(idx) == Highest_peak
                break
            end
        end

          % 8 Beat Sliding Window
%         if HR_buffer(1) == 0
%             HR_buffer(1) = f(int32(freq(idx)) + int32(0.8*(Ts*(Cfg.NrFrms-1)))); % place new data at 1st index
%         elseif length(HR_buffer) <= 8
%             HR_buffer(length(HR_buffer)+1) = 0; % add new index in array
%             HR_buffer = circshift(HR_buffer,1); % shift data over 1 index
%             HR_buffer(1) = f(int32(freq(idx)) + int32(0.8*(Ts*(Cfg.NrFrms-1)))); % place new data at 1st index
%         else
%             HR_buffer = circshift(HR_buffer,1); % shift data over 1 index
%             HR_buffer(1) = f(int32(freq(idx)) + int32(0.8*(Ts*(Cfg.NrFrms-1)))); % place new data at 1st index
%         end

%--------------------------------------------------------------------------
% Choose one filter design out of the two given below if using sliding
% window
%--------------------------------------------------------------------------
%         Heart_Rate = mean(HR_buffer); % implement moving average filter

        % Gaussian Filter Design
%         HR_buffer = smoothdata(HR_buffer, 'gaussian'); % apply gaussian filter to sliding window
%         Heart_Rate = HR_buffer(1); % Take heart rate as newest measured value
%--------------------------------------------------------------------------
        
        % 8/4 Tap Moving Average Filter Design
        if HR_buffer(1) == 0
            HR_buffer(1) = f(int32(freq(idx)) + int32(0.8*(Ts*(Cfg.NrFrms-1)))); % place new data at 1st index
            if Heart_Rate == 0
                Heart_Rate = HR_buffer(1);
            end
        elseif length(HR_buffer) < 4 % Choose either 8 or 4 here for length of buffer
            HR_buffer(length(HR_buffer)+1) = 0; % add new index in array
            HR_buffer = circshift(HR_buffer,1); % shift data over 1 index
            HR_buffer(1) = f(int32(freq(idx)) + int32(0.8*(Ts*(Cfg.NrFrms-1)))); % place new data at 1st index
            %=> Do not update Heart_Rate
        else
            Heart_Rate = mean(HR_buffer); % take average of previous 8 measurements
            HR_buffer = [0]; % Reinitialise HR_buffer for next 8 measurements
        end
        
        %--------------------------------------------------------------------------
        % Print data
        %--------------------------------------------------------------------------
        clc
        Respiratory_Rate_Str = num2str(Respiratory_Rate*60);
        Heart_Rate_Str = num2str(Heart_Rate*60);
    
        info1 = strcat(Heart_Rate_Str,' bpm');
        info2 = strcat(Respiratory_Rate_Str,' breaths/minute');
    
        set(handles.HR_Out,'String',info1);
        set(handles.Res_Out,'String',info2); % Printing info to the GUI
    catch
        info1 = 'No Heart Detected';
        info2 = 'No Breathing Detected';
    
        set(handles.HR_Out,'String',info1);
        set(handles.Res_Out,'String',info2); % Printing error to the GUI
    end
    
    %--------------------------------------------------------------------------
    % Control Number of Measurements and save info to array
    %--------------------------------------------------------------------------
    current = current+1;
    
    RunContinuous = get(handles.RunCtnd, 'Value');
    CurrentTime = clock;
    CurrentDuration = (CurrentTime(1,4) + (CurrentTime(1,5)/60) + (CurrentTime(1,6)/3600)) - (Time_of_Test(1,4) + (Time_of_Test(1,5)/60) + (Time_of_Test(1,6)/3600));
    
    Heart_Info_Array(current,1:6) =  CurrentTime(1:6); %Saving a timestamp
%     Heart_Info_Array(current,7) = str2num(strcat(num2str(CurrentTime(4)),':',num2str(CurrentTime(5)),':',num2str(CurrentTime(6))));
    Heart_Info_Array(current,7) = Heart_Rate*60; %Saving info to array
    
    if RunContinuous
        itr = itr+1;
    end
    
    if current == itr || CurrentDuration >= (MaxDur/60)
       break 
    end

end
%------------------------------------------------------------------------------
% Reset board and display reason for ceasing the measurement
%------------------------------------------------------------------------------
Brd.BrdRst();
clc
if CurrentDuration >= (MaxDur/60)
    disp('Timed Out');
else
    disp('Measurement Complete');
end
%------------------------------------------------------------------------------
% Save data into Excel
%------------------------------------------------------------------------------
xlswrite(HR_File, Heart_Info_Array);

function NumMeas_Callback(hObject, eventdata, handles)
% hObject    handle to NumMeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumMeas as text
%        str2double(get(hObject,'String')) returns contents of NumMeas as a double

% --- Executes during object creation, after setting all properties.

function NumMeas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumMeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RunCtnd.
function RunCtnd_Callback(hObject, eventdata, handles)
% hObject    handle to RunCtnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RunCtnd

function FreqRes_Callback(hObject, eventdata, handles)
% hObject    handle to FreqRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FreqRes as text
%        str2double(get(hObject,'String')) returns contents of FreqRes as a double

% --- Executes during object creation, after setting all properties.
function FreqRes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FreqRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TestDur_Callback(hObject, eventdata, handles)
% hObject    handle to TestDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TestDur as text
%        str2double(get(hObject,'String')) returns contents of TestDur as a double


% --- Executes during object creation, after setting all properties.

function TestDur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaveDirect_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDirect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveDirect as text
%        str2double(get(hObject,'String')) returns contents of SaveDirect as a double


% --- Executes during object creation, after setting all properties.
function SaveDirect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveDirect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
