function data = readDemoradData(FilePrefix,NFiles)

    data=[];
    for idx=0:(NFiles-1)
        data1=csvread([FilePrefix,num2str(idx),'.csv']);
        data2=reshape(data1',size(data1,2)/2,size(data1,1)*2)';
        data=[data;data2];
    end
    
    fs=1e6; %Sampling frequency = 1MHz
    plot(0:1/fs:(size(data,1)-1)/fs,data);

end