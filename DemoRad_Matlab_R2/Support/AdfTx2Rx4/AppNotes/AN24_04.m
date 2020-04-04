% AN24_04 -- Accessing Calibration Data 
clear all;
close all;

% (1) Connect to DemoRad: Check if Brd exists: Problem with USB driver
% (2) Read Calibration Data
% (3) Read Calibration Information

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

%--------------------------------------------------------------------------
% Software Version
%--------------------------------------------------------------------------
Brd.BrdDispSwVers();

CalDat          =   Brd.BrdGetCalDat();

CalInf          =   Brd.BrdGetCalInf();
