% Getting Started
close all;

% (1) Connect to Radarbook
% (2) Get Board Information (Temp, Voltage)
% (3) Display FPGA software version
% (4) Display Board Status (Frontend configuration)


%--------------------------------------------------------------------------
% Include all necessary directories
%--------------------------------------------------------------------------
CurPath = pwd();
addpath([CurPath,'/../../DemoRadUsb']);
addpath([CurPath,'/../../Class']);

%--------------------------------------------------------------------------
% Setup Connection
%--------------------------------------------------------------------------
Brd     =   Adf24Tx2Rx4();

Brd.BrdDispSwVers()

Brd.BrdGetUID();







