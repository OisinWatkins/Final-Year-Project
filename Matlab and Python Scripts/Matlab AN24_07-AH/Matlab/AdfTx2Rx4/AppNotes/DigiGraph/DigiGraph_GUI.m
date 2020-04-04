% DigiGraph : Digitize images 
%     Copyright (C) 2007, Arun K. Subramaniyan
% 
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License along
%     with this program; if not, write to the Free Software Foundation, Inc.,
%     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

%  Contact : Email :  sarunkarthi@gmail.com
%            Arun K. Subramaniyan
%            School of Aeronautics and Astronautics
%            Purdue University, West Lafayette, IN - 47907, USA.
%

% Todo
% 1. Deleting points after digitizing before saving data
% 2. Undo (almost built in since most functions can be redone to erase old
% actions
% 3. Zooming modified image and original image (may not be practical)

function varargout = DigiGraph_GUI(varargin)
% DIGIGRAPH_GUI M-file for DigiGraph_GUI.fig
%      DIGIGRAPH_GUI, by itself, creates a new DIGIGRAPH_GUI or raises the existing
%      singleton*.
%
%      H = DIGIGRAPH_GUI returns the handle to a new DIGIGRAPH_GUI or the handle to
%      the existing singleton*.
%
%      DIGIGRAPH_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIGIGRAPH_GUI.M with the given input arguments.
%
%      DIGIGRAPH_GUI('Property','Value',...) creates a new DIGIGRAPH_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DigiGraph_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DigiGraph_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DigiGraph_GUI

% Last Modified by GUIDE v2.5 26-Dec-2006 00:08:53


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DigiGraph_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DigiGraph_GUI_OutputFcn, ...
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


% --- Executes just before DigiGraph_GUI is made visible.
function DigiGraph_GUI_OpeningFcn(hObject, eventdata, handles, varargin)


% Defaults
handles.rotateID = 0;
handles.cropstatus = 0;
handles.intensitystatus = 0;
handles.setXScale_status = 0;
handles.setYScale_status = 0;
handles.int_uppercutoff = 200;
handles.int_lowercutoff = 0;
handles.foundpoint = 0;
handles.maxhorstatus = 0;
handles.maxverstatus = 0;

handles.X_min = 0;
handles.X_max = 1;
handles.Y_min = 0;
handles.Y_max = 1;
handles.npoint = 2000;
set(handles.uipanel_Original_Image,'Title','Original Image');
set(handles.uipanel_Operations,'Title','Modified Image');
% Choose default command line output for DigiGraph_GUI
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = DigiGraph_GUI_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when Total_Figure is resized.
function Total_Figure_ResizeFcn(hObject, eventdata, handles)



% --------------------------------------------------------------------
function Menu_File_Callback(hObject, eventdata, handles)
% Nothing needed here. Just opens the file drop down menu.
set(handles.uipanel_InitialNotice,'Visible','off');
guidata(hObject, handles);

% --------------------------------------------------------------------
function Menu_File_Open_Callback(hObject, eventdata, handles)
filetype={'*.tif';'*.jpg';'*.bmp';'*.gif';'*.png'};
[handles.filename,handles.pathname] = uigetfile(filetype,'Select the Image File');
handles.graph_original = imread([handles.pathname handles.filename]);

set(handles.uipanel_Process,'Visible','on');
set(handles.axes_Original_Image,'Visible','on');
set(handles.uipanel_Operations,'Visible','off');
set(handles.axes_Current,'Visible','off');
set(handles.uipanel_Digitize,'Visible','off');
set(handles.axes_Digitized,'Visible','off');
axes(handles.axes_Original_Image);
imagesc(handles.graph_original);
colormap(gray);
handles.OriginalImage.gca = get(gca);
set(gca,'Visible','off');

if length(handles.graph_original(1,1,:)) > 1
    set(handles.uipanel_Message,'Visible','on');
    set(handles.uipanel_ColorImage_Warning,'Visible','on');
else
    handles.graph = handles.graph_original;
    axes(handles.axes_Current);
    imagesc(handles.graph);
    colormap(gray);
end


% Enabling all menus
set(handles.Menu_OriginalImage,'Enable','on');
set(handles.Menu_Modify,'Enable','on');
set(handles.Menu_Properties,'Enable','on');
set(handles.Menu_Run,'Enable','on');


% Opening log
set(handles.uipanel_Log,'Visible','on');
wlog(handles,['Open File : ' handles.pathname handles.filename]);

guidata(hObject, handles);

% --------------------------------------------------------------------
function Menu_File_Exit_Callback(hObject, eventdata, handles)

ButtonName=questdlg('Are you sure you want to quit?','Verify',...
                    'Yes','No','No');
 
 
switch ButtonName,
   case 'Yes',
       close DigiGraph_GUI;
end



% --------------------------------------------------------------------
function Menu_OriginalImage_View_Callback(hObject, eventdata, handles)

set(handles.uipanel_Original_Image,'Visible','on');
set(handles.uipanel_Operations,'Visible','off');
set(handles.uipanel_Digitize,'Visible','off');
set(handles.axes_Digitized,'Visible','off');

guidata(hObject, handles);

% --------------------------------------------------------------------
function Menu_OriginalImage_Callback(hObject, eventdata, handles)

% Nothing needs to be done.

% --------------------------------------------------------------------
function Menu_OriginalImage_Box_Callback(hObject, eventdata, handles)
if strcmp(get(hObject,'Checked'),'off')
    axes(handles.axes_Original_Image);
    set(gca,'Visible','on');
    set(gca,'XTick',handles.OriginalImage.gca.XTick);
    set(gca,'YTick',handles.OriginalImage.gca.YTick);
    set(hObject,'Checked','on');
    set(handles.Menu_OriginalImage_XTick,'Checked','on');
    set(handles.Menu_OriginalImage_YTick,'Checked','on');
    wlog(handles,'Box On');
else
    axes(handles.axes_Original_Image);
    set(gca,'Visible','off');
    set(hObject,'Checked','off');
    set(handles.Menu_OriginalImage_XTick,'Checked','off');
    set(handles.Menu_OriginalImage_YTick,'Checked','off');
    wlog(handles,'Box Off');
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function Menu_OriginalImage_XTick_Callback(hObject, eventdata, handles)
if strcmp(get(hObject,'Checked'),'off')
    axes(handles.axes_Original_Image);
    set(gca,'Visible','on');
    set(gca,'XTick',handles.OriginalImage.gca.XTick);
    set(hObject,'Checked','on');
    wlog(handles,'XTick On');
else
    axes(handles.axes_Original_Image);
    set(gca,'XTick',[]);
    set(hObject,'Checked','off');
    wlog(handles,'XTick Off');
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function Menu_OriginalImage_YTick_Callback(hObject, eventdata, handles)
if strcmp(get(hObject,'Checked'),'off')
    axes(handles.axes_Original_Image);
    set(gca,'Visible','on');
    set(gca,'YTick',handles.OriginalImage.gca.YTick);
    set(hObject,'Checked','on');
    wlog(handles,'YTick On');
else
    axes(handles.axes_Original_Image);
    set(gca,'YTick',[]);
    set(hObject,'Checked','off');
    wlog(handles,'YTick On');
end
guidata(hObject, handles);




% --------------------------------------------------------------------
function Menu_Modify_Callback(hObject, eventdata, handles)
% Do not need to do anything.


% --------------------------------------------------------------------
function Menu_Modify_Rotate_Callback(hObject, eventdata, handles)
set(handles.uipanel_Original_Image,'Visible','off');
set(handles.uipanel_Operations,'Visible','on');
set(handles.uipanel_Rotate,'Visible','on');
set(handles.uipanel_Digitize,'Visible','off');
set(handles.axes_Digitized,'Visible','off');
handles.rotateID = handles.rotateID+1;
handles.rotate.angle = 0; % default
guidata(hObject, handles);
% --------------------------------------------------------------------
function Menu_Modify_Crop_Callback(hObject, eventdata, handles)
set(handles.uipanel_Original_Image,'Visible','off');

set(handles.uipanel_Original_Image,'Visible','off');
set(handles.uipanel_Operations,'Visible','on');
set(handles.uipanel_Digitize,'Visible','off');
set(handles.axes_Digitized,'Visible','off');
axes(handles.axes_Current);
title('Select Crop Limits : Top Left followed by Bottom Right',...
    'Fontweight','bold','Color','red');
handles.crop(1,:) = ginput(1);
hold on;
plot(handles.crop(1,1),handles.crop(1,2),'+');
handles.crop(2,:) = ginput(1);
plot(handles.crop(2,1),handles.crop(2,2),'+r');
graph_crop=handles.graph(round(handles.crop(1,2)):round(handles.crop(2,2)),...
    round(handles.crop(1,1)):round(handles.crop(2,1)));

hold off;
imagesc(graph_crop);
colormap(gray);
title('Cropped Image');
t = handles.crop;
wlog(handles,['Cropped Image UL(' num2str(t(1,1)) ',' num2str(t(1,2)) '), LR(' num2str(t(2,1)) ',' num2str(t(2,2)) ')']);

clear handles.graph
handles.graph = graph_crop;

% Recalculating intensities if it is on
if handles.intensitystatus == 1
    Menu_Intensity_Callback(hObject, eventdata, handles);
end

handles.cropstatus = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------


% --- Executes on selection change in listbox_Log.
function listbox_Log_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function listbox_Log_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Log Function
function wlog(handles,s)
    a = get(handles.listbox_Log,'String');
    if length(a) == 1
        if strcmp(a,'')
            s = ['1 : ' s];
        else
            s = [num2str(length(a)+1) ' : ' s];
        end
    else
        s = [num2str(length(a)+1) ' : ' s];
    end
    if length(a) == 1
        if strcmp(a,'')
            a = {s};
        else
            a{length(a)+1} = s;
        end
    else
        a{length(a)+1} = s;
    end
    set(handles.listbox_Log,'String',a);
    
    



    



function edit_rotate_angle_Callback(hObject, eventdata, handles)
handles.rotate.angle(handles.rotateID,1) = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_rotate_angle_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_rotate_OK.
function pushbutton_rotate_OK_Callback(hObject, eventdata, handles)
if get(handles.radiobutton_ccw,'Value') == 1
    % leave angle as it is
    wlog(handles,['Rotate ' ...
        num2str(handles.rotate.angle(handles.rotateID,1)) ' degrees ccw']);
elseif get(handles.radiobutton_cw,'Value') == 1
    handles.rotate.angle(handles.rotateID,1) = ...
        -handles.rotate.angle(handles.rotateID,1);
    wlog(handles,['Rotate ' ...
        num2str(handles.rotate.angle(handles.rotateID,1)) ' degrees cw']);
else
    error('One of the two directions have to be checked');
end

graph = imrotate(handles.graph,...
                handles.rotate.angle(handles.rotateID,1));
            
clear handles.graph;
handles.graph = graph;

set(handles.uipanel_Rotate,'Visible','off');

axes(handles.axes_Current);
imagesc(handles.graph);
colormap(gray);

% Recalculating intensities if it is on
if handles.intensitystatus == 1
    Menu_Intensity_Callback(hObject, eventdata, handles);
end

guidata(hObject, handles);



% --- Executes on button press in pushbutton_Convert2Grayscale.
function pushbutton_Convert2Grayscale_Callback(hObject, eventdata, handles)
if length(handles.graph_original(1,1,:)) > 1
    % Making sure that it is RGB file before converting
    if length(handles.graph_original(1,1,:))== 3
        handles.graph = rgb2gray(handles.graph_original);
        handles.graph_gray_original = handles.graph;
        wlog(handles,['Converted RGB image to Grayscale']);
    else
        handles.graph = handles.graph_original(:,:,1);
        handles.graph_gray_original = handles.graph;
        wlog(handles,['Taking only the 1st color component']);
        uiwait(msgbox('The color image is not in RGB format. Just taking the red component',...
                 'Not RGB Format','modal'));
    end
else
    handles.graph = handles.graph_original;
    handles.graph_gray_original = handles.graph;
    wlog(handles,['Gray convertor keeping image as is.']);
end
set(handles.uipanel_Message,'Visible','off');
set(handles.uipanel_ColorImage_Warning,'Visible','off');

set(handles.uipanel_Original_Image,'Visible','off');
set(handles.uipanel_Operations,'Visible','on');
set(handles.uipanel_Digitize,'Visible','off');
set(handles.axes_Digitized,'Visible','off');
axes(handles.axes_Current);
imagesc(handles.graph);
colormap(gray);

guidata(hObject, handles);


% --- Executes on button press in pushbutton_1stColor.
function pushbutton_1stColor_Callback(hObject, eventdata, handles)
handles.graph = handles.graph_original(:,:,1);
handles.graph_gray_original = handles.graph;
wlog(handles,['Taking only the 1st color component']);
set(handles.uipanel_Message,'Visible','off');
set(handles.uipanel_ColorImage_Warning,'Visible','off');
guidata(hObject, handles);



% --------------------------------------------------------------------
function Menu_Intensity_Callback(hObject, eventdata, handles)
set(handles.uipanel_Operations,'Visible','on');
set(handles.uipanel_Original_Image,'Visible','off');
set(handles.axes_Current,'Visible','on');
set(handles.uipanel_Digitize,'Visible','off');
set(handles.axes_Digitized,'Visible','off');
set(handles.axes_row_intensity,'Visible','on');
set(handles.axes_col_intensity,'Visible','on');
if ~isempty(handles.graph)
    handles.rowintensity = mean(handles.graph);
    handles.colintensity = mean(handles.graph');
    axes(handles.axes_Current);
    c=get(gca,'YLim');
    d=get(gca,'XLim');
    
    axes(handles.axes_row_intensity);
    if length(handles.colintensity) < 10
        plot(handles.colintensity,[1:length(handles.colintensity)],'.');
    else
        plot(handles.colintensity,[1:length(handles.colintensity)]);
    end
    set(gca,'YLim',c,'YDir','reverse');
    xlabel('Intensity');
    set(gca,'YTickLabel',{});
    axes(handles.axes_col_intensity);
    if length(handles.rowintensity) < 10
        plot(handles.rowintensity,'.');
    else
        plot(handles.rowintensity);
    end
    set(gca,'XLim',d);
    ylabel('Intensity');
    set(gca,'XTickLabel',{});
end

handles.intensitystatus = 1;
wlog(handles,'Intensity On');

    
guidata(hObject, handles);
% --------------------------------------------------------------------
function Menu_Properties_Callback(hObject, eventdata, handles)
% Nothing needed here.




% --------------------------------------------------------------------
function Menu_XScale_Callback(hObject, eventdata, handles)
set(handles.uipanel_Original_Image,'Visible','off');

set(handles.uipanel_Original_Image,'Visible','off');
set(handles.uipanel_Operations,'Visible','on');
set(handles.uipanel_Digitize,'Visible','off');
set(handles.axes_Digitized,'Visible','off');
axes(handles.axes_Current);
title('Select X min followed by X max',...
    'Fontweight','bold','Color','red');
handles.Xlimits(1,:) = ginput(1);
hold on;
plot(handles.Xlimits(1,1),handles.Xlimits(1,2),'xr');
plot(handles.Xlimits(1,1),handles.Xlimits(1,2),'ob');
handles.Xlimits(2,:) = ginput(1);
plot(handles.Xlimits(2,1),handles.Xlimits(2,2),'xr');
plot(handles.Xlimits(2,1),handles.Xlimits(2,2),'ob');

set(handles.uipanel_XScale,'Visible','on');



handles.setXScale_status = 1;

Xlimits = handles.Xlimits;
wlog(handles,...
 ['Setting Xlimits (pixels): (' num2str(Xlimits(1,1)) ',' num2str(Xlimits(1,2)) ') -- (' num2str(Xlimits(2,1)) ',' num2str(Xlimits(2,2)) ')']);

title('Modified Image');

guidata(hObject, handles);
% --------------------------------------------------------------------
function Menu_YScale_Callback(hObject, eventdata, handles)
set(handles.uipanel_Original_Image,'Visible','off');

set(handles.uipanel_Original_Image,'Visible','off');
set(handles.uipanel_Operations,'Visible','on');
set(handles.uipanel_Digitize,'Visible','off');
set(handles.axes_Digitized,'Visible','off');
axes(handles.axes_Current);
title('Select Y min followed by Y max',...
    'Fontweight','bold','Color','red');
handles.Ylimits(1,:) = ginput(1);
hold on;
plot(handles.Ylimits(1,1),handles.Ylimits(1,2),'xb');
plot(handles.Ylimits(1,1),handles.Ylimits(1,2),'sr');
handles.Ylimits(2,:) = ginput(1);
plot(handles.Ylimits(2,1),handles.Ylimits(2,2),'xb');
plot(handles.Ylimits(2,1),handles.Ylimits(2,2),'sr');
set(handles.uipanel_YScale,'Visible','on');
handles.setYScale_status = 1;

Ylimits = handles.Ylimits;
wlog(handles,...
 ['Setting Ylimits (pixels): (' num2str(Ylimits(1,1)) ',' num2str(Ylimits(1,2)) ') -- (' num2str(Ylimits(2,1)) ',' num2str(Ylimits(2,2)) ')']);

title('Modified Image');

guidata(hObject, handles);





function edit_XMin_Callback(hObject, eventdata, handles)

handles.X_min = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_XMin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.X_min = 0;
guidata(hObject, handles);
% --- Executes on button press in pushbutton_XScale_OK.
function pushbutton_XScale_OK_Callback(hObject, eventdata, handles)
set(handles.uipanel_XScale,'Visible','off');
wlog(handles,...
 ['Setting Xlimits (real units): (' num2str(handles.X_min) ',' num2str(handles.X_max) ')']);
guidata(hObject, handles);

function edit_XMax_Callback(hObject, eventdata, handles)
handles.X_max = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_XMax_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.X_max = 1;

guidata(hObject, handles);

function edit_YMin_Callback(hObject, eventdata, handles)
handles.Y_min = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_YMin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Y_min = 0;
guidata(hObject, handles);

% --- Executes on button press in pushbutton_YScale_OK.
function pushbutton_YScale_OK_Callback(hObject, eventdata, handles)
set(handles.uipanel_YScale,'Visible','off');
wlog(handles,...
 ['Setting Ylimits (real units): (' num2str(handles.Y_min) ',' num2str(handles.Y_max) ')']);
guidata(hObject, handles);


function edit_YMax_Callback(hObject, eventdata, handles)
handles.Y_max = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_YMax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Y_max = 1;

guidata(hObject, handles);



% --------------------------------------------------------------------
function Menu_Run_Callback(hObject, eventdata, handles)
% Nothing needs to be added here


% --------------------------------------------------------------------
function Menu_extract_Callback(hObject, eventdata, handles)
set(handles.uipanel_running_message,'Visible','on');
set(handles.text_running_message,'Visible','on');
set(handles.text_pat,'Visible','on');
drawnow;
foundpoint = 0;
handles.foundpoint = 0;
for i = 1 : 1 : length(handles.graph(:,1))
    k=1;
    for j = 1 : 1 : length(handles.graph(1,:))
        if handles.graph(i,j) <= handles.int_uppercutoff & ...
                handles.graph(i,j) >= handles.int_lowercutoff
            handles.c(i).x(k) = j; 
            handles.c(i).y(k) = i;
            handles.c(i).i(k) = handles.graph(i,j);
            k=k+1;
            foundpoint = 1;
        end
    end
end

% Checking if any points were found
if foundpoint == 0 
    msg = ['No points within intensity range : ' num2str(handles.int_lowercutoff) ' - ' num2str(handles.int_uppercutoff) ' found!'];
    m=msgbox(msg,'Warning','warn');
    uiwait(m); % To stop execution till user presses OK in the message box
end

% Finding scales
if handles.setXScale_status == 0
    a = get(handles.axes_Current,'Xlim');
    b = get(handles.axes_Current,'Ylim');
    handles.Xlimits(1,1) = a(1);
    handles.Xlimits(1,2) = b(1);
    handles.Xlimits(2,1) = a(2);
    handles.Xlimits(2,2) = b(1);
end

if handles.setYScale_status == 0
    a = get(handles.axes_Current,'Xlim');
    b = get(handles.axes_Current,'Ylim');
    handles.Ylimits(1,1) = a(1);
    handles.Ylimits(1,2) = b(1);
    handles.Ylimits(2,1) = a(1);
    handles.Ylimits(2,2) = b(2);
end

handles.scale_x = abs((handles.X_max-handles.X_min)/(handles.Xlimits(2,1)-handles.Xlimits(1,1))); %taking only the x component
handles.scale_y = abs((handles.Y_max-handles.Y_min)/(handles.Ylimits(2,2)-handles.Ylimits(1,2))); %taking only the y component

%calculating offsets in axis
handles.x_offset = handles.X_min - (handles.Xlimits(1,1)*handles.scale_x);
handles.y_offset = -handles.Y_min - (handles.Ylimits(1,2)*handles.scale_y);

% Removing X grid points if not already removed
if handles.maxhorstatus == 0 | handles.maxhorstatus == 1
    c = handles.c;
    m = 1;
    for i = 1 : 1: length(handles.c)
        if length(c(i).y) < handles.npoint && isempty(c(i).x) ~= 1
            handles.g(m).x = c(i).x;
            handles.g(m).y = c(i).y;
            handles.g(m).i = c(i).i;
            m=m+1;
        end
    end
    %putting all points in one vector
    clear k;
    k=0;
    for i = 1 : 1 : length(handles.g)
        X(k+1:k+length(handles.g(i).x)) = handles.g(i).x;
        Y(k+1:k+length(handles.g(i).y)) = handles.g(i).y;
        handles.Intensity(k+1:k+length(handles.g(i).i)) = handles.g(i).i;
        k=k+length(handles.g(i).x);
    end
    [handles.X_sort,id]=sort(X);
    for i = 1 : 1 : length(Y)
        handles.Y_sort(i)=Y(id(i));
    end
end

% Removing the Y Grid Points
removey_flag = 0;
if handles.maxverstatus == 1
    a=diff(handles.X_sort);
    % Finding the y points with same x location
    k = 1;
    s = 0;
    for i = 1 : 1 : length(a)
        if s == 0
            if a(i)==0
                s=1;
                chunk(k,1)=i;
            end
        else
            if a(i) ~=0
                chunk(k,2)=i-1;
                k=k+1;
                s=0;
            end
        end
    end
    if s==1 % Then after the last start point till the end of the vector a it is all zeros
        chunk(k,2) = length(a); % last end is the end of vector
    end

    % Checking if the chunks have more than 10 points

    % ymax_points = 10;
    d = chunk(:,2)-chunk(:,1);
    ry = 1;
    removey_flag=0;
    for i = 1 : 1: length(d)
        if d(i) > handles.ymax_points
            remove_y(ry,1) = chunk(i,1);
            remove_y(ry,2) = chunk(i,2);
            ry = ry+1;
            removey_flag=1;
        end
    end
end

% Actually removing the points
if removey_flag==1
    ry = 1;
    f = 1;
    i = 1;
    while i <= length(handles.X_sort)
        if ry <= length(remove_y(:,1))
            if i == remove_y(ry,1)
                i = remove_y(ry,2)+1;
                ry = ry+1;
            end
            if i >= length(handles.X_sort)
                break;
            end
        end
        handles.X_f(f) = handles.X_sort(i);
        handles.Y_f(f) = handles.Y_sort(i);
        f = f+1;
        i = i +1;
    end
else
    handles.X_f = handles.X_sort;
    handles.Y_f = handles.Y_sort;
end
        
% ---


%final data
handles.X_final = handles.X_f*handles.scale_x+handles.x_offset;
handles.Y_final = -(handles.Y_f*handles.scale_y+handles.y_offset);

%---------

% Showing the digitized points
if foundpoint == 1
    set(handles.uipanel_Operations,'Visible','off');
    set(handles.uipanel_Original_Image,'Visible','off');
    set(handles.uipanel_Digitize,'Visible','on');
    set(handles.axes_Digitized,'Visible','on');
    axes(handles.axes_Digitized);
    plot(handles.X_final,handles.Y_final,'.')
    title(['Digitized Points with intensity between : ' num2str(handles.int_lowercutoff) ' < I < ' num2str(handles.int_uppercutoff)]);
    handles.foundpoint = 1;
    set(handles.Menu_DigitizedImage_view,'Enable','on');
%     set(handles.Menu_maxhor,'Enable','on');
%     set(handles.Menu_maxver,'Enable','on');
    set(handles.Menu_SaveData,'Enable','on');
end

set(handles.uipanel_running_message,'Visible','off');
set(handles.text_running_message,'Visible','off');
set(handles.text_pat,'Visible','off');
wlog(handles,['Digitizing image ... ']);



guidata(hObject, handles);
% --------------------------------------------------------------------
function Menu_IntensityLimits_Callback(hObject, eventdata, handles)
prompt  = {'Maximum Intensity',...
            'Minimum Intensity'};
title2   = 'Intensity Cutoff';
lines= 1;
def     = {'20','0'};
done = 0;
while done == 0
    answer  = inputdlg(prompt,title2,lines,def);
    handles.int_uppercutoff = str2num(answer{1});
    handles.int_lowercutoff = str2num(answer{2});
    if handles.int_uppercutoff > 255
        msg = 'Intensity cannot be greater than 255. Please enter a value lesser than or equal to 255';
        m=msgbox(msg,'Warning','warn');
        uiwait(m); % To stop execution till user presses OK in the message box
    else
        done = 1;
    end
end

wlog(handles,...
 ['Setting Intensity limits (Max, Min): (' num2str(handles.int_uppercutoff) ',' num2str(handles.int_lowercutoff) ')']);

guidata(hObject, handles);


% --------------------------------------------------------------------
function Menu_ModifiedImage_view_Callback(hObject, eventdata, handles)
set(handles.uipanel_Operations,'Visible','on');

set(handles.uipanel_Original_Image,'Visible','off');
set(handles.axes_Current,'Visible','on');
set(handles.uipanel_Digitize,'Visible','off');
set(handles.axes_Digitized,'Visible','off');

guidata(hObject, handles);
% --------------------------------------------------------------------
function Menu_DigitizedImage_view_Callback(hObject, eventdata, handles)
set(handles.uipanel_Operations,'Visible','off');
set(handles.uipanel_Original_Image,'Visible','off');
set(handles.axes_Current,'Visible','off');
set(handles.uipanel_Digitize,'Visible','on');
set(handles.axes_Digitized,'Visible','on');

guidata(hObject, handles);


% --------------------------------------------------------------------
function Menu_maxhor_Callback(hObject, eventdata, handles)
clear handles.g;
%removing grid line data
m=1;
prompt  = {'Maximum Number of points in a horizontal line' };
title2   = 'Filter';
lines= 1;
if handles.maxhorstatus == 1
    def = {num2str(handles.npoint)};
else
    def     = {'50'};
end
answer  = inputdlg(prompt,title2,lines,def);
handles.npoint = str2num(answer{1});

handles.maxhorstatus = 1;

wlog(handles,...
 ['Setting Maximum Hor. Points: ' num2str(handles.npoint) ]);

guidata(hObject, handles);
% --------------------------------------------------------------------
function Menu_maxver_Callback(hObject, eventdata, handles)
m3=1;
prompt3  = {'Maximum Number of points in a vertical line' };
title3   = 'Filter';
lines= 1;
if handles.maxverstatus == 1
    def = {num2str(handles.ymax_points)};
else
    def     = {'10'};
end
answer  = inputdlg(prompt3,title3,lines,def);
handles.ymax_points = str2num(answer{1});

handles.maxverstatus = 1;

wlog(handles,...
 ['Setting Maximum Ver. Points: ' num2str(handles.npoint) ]);


guidata(hObject, handles);


% --------------------------------------------------------------------
function Menu_SaveData_Callback(hObject, eventdata, handles)
%Writing data to file


prompt4  = {'Enter data filename                                        .',...
           'Enter log filename                                          .'};
title4   = 'Save extracted data';
lines= 1;
def4 = {[handles.pathname handles.filename(1:length(handles.filename)-4) '.dat']
    [handles.pathname handles.filename(1:length(handles.filename)-4) '.log']};
answer4  = inputdlg(prompt4,title4,lines,def4);
handles.datafile = answer4{1};
handles.logfile = answer4{2};



txt = fopen(handles.logfile,'w+');
%writing intensity cutoff in line 1 and max number of points  in a line in
%line 2 and then followed by X and Y data
fprintf(txt,['Created on ' datestr(now) '\n']);
fprintf(txt,['Intensity Upper Cutoff =' '\t%f\n'],handles.int_uppercutoff);
fprintf(txt,['Intensity Lower Cutoff =' '\t%f\n'],handles.int_lowercutoff);
fprintf(txt,['Maximum Number of horizontal points =' '\t%d\n'],handles.npoint);
if handles.maxverstatus == 1
    fprintf(txt,['Maximum Number of vertical points =' '\t%d\n'],handles.ymax_points);
end
fprintf(txt,['X_min selected in pixel =' '\t(%f,%f)\n'],handles.Xlimits(1,1),handles.Xlimits(1,2)); 
fprintf(txt,['X_max selected in pixel =' '\t(%f,%f)\n'],handles.Xlimits(2,1),handles.Xlimits(2,2)); 
fprintf(txt,['Y_min selected in pixel =' '\t(%f,%f)\n'],handles.Ylimits(1,1),handles.Ylimits(1,2)); 
fprintf(txt,['Y_max selected in pixel =' '\t(%f,%f)\n'],handles.Ylimits(2,1),handles.Ylimits(2,2)); 
fprintf(txt,['X_min value entered =' '\t%f\n'],handles.X_min);
fprintf(txt,['X_max value entered =' '\t%f\n'],handles.X_max);
fprintf(txt,['Y_min value entered =' '\t%f\n'],handles.Y_min);
fprintf(txt,['Y_max value entered =' '\t%f\n'],handles.Y_max);
fprintf(txt,['Data file :' '\t%s'],[handles.pathname handles.filename(1:length(handles.filename)-4) '.dat']);
fclose(txt);

fid = fopen(handles.datafile,'w+');
for i = 1 : 1 : length(handles.X_final)
    fprintf(fid,'%f\t%f\n',handles.X_final(i),handles.Y_final(i));
end
fclose(fid);

wlog(handles,...
 ['Saved data and log to : ' handles.datafile ' ; ' handles.logfile]);
guidata(hObject, handles);




% --------------------------------------------------------------------
function Menu_Reset_Callback(hObject, eventdata, handles)

% Reseting everything as if gui was just opened
% Still have to add code




% --------------------------------------------------------------------
function Menu_Help_Callback(hObject, eventdata, handles)
% Nothing is needed here
set(handles.uipanel_InitialNotice,'Visible','off');
guidata(hObject, handles);

% --------------------------------------------------------------------
function Menu_Help_About_Callback(hObject, eventdata, handles)
msg1 = {'DigiGraph beta 1.0, Copyright (C) 2007 Arun K. Subramaniyan'
        'DigiGraph comes with ABSOLUTELY NO WARRANTY. '
        'This is free software, and you are welcome to redistribute it'
        ' under certain conditions (GPL, see license for details).'};
uiwait(helpdlg(msg1,'DigiGraph'));

% --------------------------------------------------------------------
function Menu_Help_License_Callback(hObject, eventdata, handles)
HelpPath = which('gpl.html');
web(HelpPath); 


