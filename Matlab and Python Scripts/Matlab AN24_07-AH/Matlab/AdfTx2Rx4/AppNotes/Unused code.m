% audiowrite(FileName1, Data(:,1), 1200000);
% audiowrite(FileName2, Data(:,2), 1200000);
% audiowrite(FileName3, Data(:,3), 1200000);
% audiowrite(FileName4, Data(:,4), 1200000)); %Incorrect Fs, fix Insert
% code after reading data from the board

% Mean_Info = zeros(1,47);
% if x >= 105 && x <= 152
%    Mean_Info(x-104) = mean(Diff(x,1:11)); %-10deg -> +10deg ; 0.5m -> 1m
% end
% averaging function for HR data

%------------------------------------------------------------------------------
% Provide colourmap for Range Profile
%------------------------------------------------------------------------------
% mymap = [0.2 0.1 0.5
%     0.1 0.5 0.8
%     0.2 0.7 0.6
%     0.8 0.7 0.3
%     0.9 1 0];

%         for x = 1:length(P1) % Threshold the frequency to remove lower power harmonics
%             if abs(P1(x)) < 20
%                 P1(x) = 0;
%             end
%         end
%         