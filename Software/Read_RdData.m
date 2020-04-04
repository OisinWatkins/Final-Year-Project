% (c) Inras GmbH
% 
% Description: Read hdf5 file from DemoRadTool range-Doppler map
%       StoreIf("xxx.h5",NrFrms)
% Extract the data from the file and store If signals to If array
% In the for loop the signals form the four channels are extracted


stFile      =   'xxx.h5';

% Number of samples
N           =   hdf5read(stFile,'/BrdCfg/N');
% Number of frames for RD map
Np          =   hdf5read(stFile,'/BrdCfg/Np');
% Sampling frequency
fs          =   hdf5read(stFile,'/BrdCfg/fs');
% Effective upchirp duration
TimUp       =   hdf5read(stFile,'/BrdCfg/TimUp');
% Start frequency
FreqStrt    =   hdf5read(stFile,'/BrdCfg/FreqStrt');
% Stop frequency
FreqStop    =   hdf5read(stFile,'/BrdCfg/FreqStop');

% Effective bandwidth:
% Tp is 284 us for start to stop frequency but only 256 samples are
% conducted
B           =   (FreqStop - FreqStrt)/284*256;

If          =   hdf5read(stFile,'/If');

% Read If signal for four channels
[Nx NrFrms] =   size(If);


% Extract the if signals for the four receive channels
for Idx = 1:NrFrms
    disp(['RD Fame: ', num2str(Idx)])
    Dat     =   If(:,Idx);
    
    Chn1    =   Dat(1:N*Np);
    Chn1    =   reshape(Chn1,N,Np);
    Chn2    =   Dat(N*Np+1:2*N*Np);
    Chn2    =   reshape(Chn2,N,Np);
    Chn3    =   Dat(2*N*Np+1:3*N*Np);
    Chn3    =   reshape(Chn3,N,Np);
    Chn4    =   Dat(3*N*Np+1:4*N*Np);
    Chn4    =   reshape(Chn4,N,Np);
    
    figure(1)
    imagesc(Chn1)
    xlabel('m')
    ylabel('n')
    title('Chn1 RD frame')
    
    drawnow();
end








