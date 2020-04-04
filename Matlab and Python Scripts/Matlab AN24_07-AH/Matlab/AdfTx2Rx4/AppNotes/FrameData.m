function [Frame_Info, Frames] = FrameData(Data_In, numFrames)
%FrameData -> Windows a data matirx and compares frames WRT time.
%   This function will inspect the changes in specific windows of a data
%   stream and provide information as to patterns which are present.
%   Frame_Info will have lngth and width equal to Data_In, with
%   depth = numFrames - 1.

[len,wit] = size(Data_In);

is_Frames = exist('Frames', 'var');

if  is_Frames ~= 1  % If 'Frames' doesn't exist
    
    Frames = zeros(len,wit,numFrames); % Create Frames
    Frames(:,:,1) = Data_In; % Initialise Frames
    
    Frame_Info = zeros(len,wit,(numFrames-1)); % Initialise Frame_Info
    Frame_Info(:,:,1) = Frames(:,:,1); % Give first Frame to Frame_Info
    
else % 'Frames' exists and must have AT LEAST one frame of data
    
    for i = 1:(numFrames+1) % Search for empty frames. Extra iteration acts as a flag
        if i<(numFrames+1)
            if Frames(:,:,i) == zeros(len,wit) % => Empty Frame, ready to fill
                Frames(:,:,i) = Data_In; % => Fill Frame with data
                break
            end
        end
    end
    
    if i == numFrames+1 % Flag to indicate Frames array is full
        for j = 1:numFrames
            if j ~= numFrames
                Frames(:,:,j) = Frames(:,:,j+1); % => Shift data in Frames by one frame until the newest frame is ready
            else % Newest frame is ready for new data
                Frames(:,:,j) = Data_In;
            end
        end
    end
    
    % Always compute the Frame_Info matrix
    for k = 1:(numFrames-1)
        Frame_Info(:,:,k) = Frames(:,:,k+1) - Frames(:,:,k);
    end
    
end


end