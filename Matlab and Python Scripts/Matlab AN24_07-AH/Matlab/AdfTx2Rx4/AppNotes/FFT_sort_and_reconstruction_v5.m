%% This script uses cell mode
% Every cell starts with %% and will be displayed in yellow when selected
% A cell can be executed by pressing Ctrl + Enter, so you can execute the
% script piece by piece
% Change history
% Date:13/01/2010: file FFT_test.m first version
% Date:13/01/2010: to show fft and ifft or a signal
% single-sided FFT example
% file name: 

%%
clear all
close all
clc


%% set up varibles
Fs = 8000;                  % was 1000 Sampling frequency
T  = 1/Fs;                  % Sample time
L  = 8000;                  % was 1000 Length of signal
f1 = 50;                    %  50/8000 = 
f2 = 100;                   % 100/8000 = 
f3 = 200;                   % 200/8000 = 
f4 = 300;
f5 = 400;                   % 400/8000 = 0.05, while 500/8000 = 0.0625
f6 = 430;                   % 430/8000 = 
f7 = 450;                   % 450/8000 = 
f8 = 480;                   % 480/8000 = 
f9 = 500;                   % 500/8000 = 
f10= 550;                   % 550/8000 = 

a1 = 1;
a2 = 0.5;
% vary these amplitude from 0.1 to 5
a3 = 1;
a4 = 0.4;
a5 = 0.3;
a6 = 0.2;
a7 = 2;
a8 = 3;
a9 = 4;
a10= 5;
fft_n = 2^nextpow2(L);      % Next power of 2 from length of y
f     = Fs/2*linspace(0,1,fft_n/2); % +1 freq vector
fdisplay = 1:fft_n/2; %+1
end_thd = 35;     % currently on two signal components change when more.
seed_n  = 1;     % noise seed
t = (0:L-1)*T;   % Time vector
%    ^  ^   ¦* lenght recursively step sizes)
%    ¦  ¦to (recursively end point)
%    ¦from (start point)

% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
s3_to_6  = a3*cos(2*pi*f3*t) + a4*sin(2*pi*f4*t) + a5*cos(2*pi*f5*t) + a6*sin(2*pi*f6*t);
s7_to_10 = a7*sin(2*pi*f7*t) + a8*cos(2*pi*f8*t) + a9*sin(2*pi*f9*t) + a10*cos(2*pi*f10*t);
y_others = s3_to_6 + s7_to_10;

y = a1*sin(2*pi*f1*t) + a2*sin(2*pi*f2*t) + y_others; 
noise = seed_n*randn(size(t));     % Sinusoids plus noise
yn = y + noise;

% plot(Fs*t(1:50),y(1:50)) % plot x-axis (time scale),and y (variable) 
figure(1) ;
subplot(2,1,1); 
plot(t, y);
legend('Original Signal')
xlabel('time (seconds)');
grid;
subplot(2,1,2); 
plot(t,y,'r', t,yn,'b');
title('noisy Signal');               % randn, Gausian Random Noise.
legend('Signal Embedded in noise'); 
xlabel('time (seconds)');
grid;
% Plot single-sided amplitude spectrum.
%plot(f,abs(Y(1:fft_n/2+1)));
Y = fft(y,  fft_n)/L;    % normalised by L
Yn = fft(yn, fft_n)/L;   % normalised by L

figure(2);
subplot(2,2,1); 
plot(f, abs(Y(fdisplay)));
legend('noise-free');
title('Spectrum of y(t)');
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
grid;
subplot(2,2,3); 
plot(f, abs(Yn(fdisplay)));
legend('with noise');
title('Spectrum of yn(t)');
xlabel('Frequency (Hz)');
ylabel('|Yn(f)|');
grid;

% do log scale
%figure(3);
subplot(2,2,2); 
dBplot(abs(Y(fdisplay)));
legend('noise-free');
title('Spectrum of y(t) dBs');
xlabel('Frequency (Hz)');
subplot(2,2,4); 
dBplot(abs(Yn(fdisplay)));
legend('with noise');
title('Spectrum of yn(t) dBs');
xlabel('Frequency (Hz)');

%% create bar chart of signal + noise in freq domain (fft)
% # Question how can re-aligned the the magnitude and freq 
% => To relaign magnitude (divide) and scale with i.e. 1/(norm_value) see above freq_fig_y plot
% => to realign freq scale see doc axis
bar_Yn_fig = figure (3);         % new figure
absYn = abs(Yn); 
%bar(absYn(1:Fs/2));                   % plot bar chart of fft
%hold;
%bar(absYn(1:fft_n));
subplot(2,1,1); 
bar(absYn(fdisplay));
grid;
xlabel('(Normalised bar graph plot)');
ylabel('(Magnitude)|Yn|');
%  Sort the data to find the largest components
% # Question how can re-aligned the the magnitude and freq 
sortabsYn = sort(absYn(fdisplay));      % Sort the data to find the largest components
%sort_bar_Yn_fig = figure (5); % new figure
subplot(2,1,2); 
bar(sortabsYn(fdisplay));             % plot bar chart of fft
grid;
xlabel('(Normalised ascending bar graph');
ylabel('(Magnitude)|Yn|');

%% Everything below cut_off should be removed
% As we have all data twice (mirroring effect in FFT) we need to use the
% 3rd or 4th value from the sorted data. (Normally this would have been the
% second)
cut_off = sortabsYn(end - end_thd); % Change the value for n freq. component) 
Yn_filt = Yn;                 % Copy the original vector
Yn_filt(absYn < cut_off) = 0; % Set all components below the cut off point to 0

%% Plot the new spectrum
% figure(freq_fig_y);
figure(4);
plot(abs(Yn_filt(fdisplay)));
legend('sorted,thresthold of FFT');
xlabel('(Signal(yn) with noise removed) f');
grid;

%% Compute IFFT of filtered signal and compare original signal
yn_filt = ifft(Yn_filt)*L; %scale back up
figure(5);
plot(t(1:L), y(1:L)); % Plot the original signal
hold;
plot(t(1:L), yn_filt(1:L), 'r'); % Plot the filtered signal
%plot(t(1:L/2), yn_filt(1:fft_n/2), 'r'); % Plot the filtered signal
legend('Original signal', 'IFFT signal');
xlabel('(Superimpose of reconstructed Signal) t');
grid;

%% Compute FFT of the IFFT of filtered signal and compare original signal
% compare fft for the signal + noise in log scale
dbplot_fig_yn = figure(6);
grid;
subplot(2,1,1); 
dbplot(abs(Yn(fdisplay))); % fft of Yn
xlabel('(Original Signal + Random Noise in Freq. Domain) f');
ylabel('|Yn(f)| dB');
legend('FFT of yn signal (dBs)');

subplot(2,1,2); 
Yn_filt_sort = fft(yn_filt, fft_n)/L;
dbplot(abs(Yn_filt_sort(fdisplay)));
title('fft and ifft sorted Spectrum of yn(t)');
xlabel('Frequency (Hz)');
ylabel('|Yn_filt(f)| dB');
legend('FFT of sorted yn signal (dBs)');

%%  probability statistics for detection of noise removal

% evaluating the fft (Yn) data
figure(7);
subplot(2,2,1); 
probplot(absYn);
legend('fft of yn');
grid;
subplot(2,2,2); 
normplot(absYn);
legend('fft of yn');
subplot(2,2,3); 
qqplot(absYn);
legend('fft of yn');
grid;

% statistic for noise reduction using sort algorithm
% evaluating the (frequency domain) fft (Yn) sorted data
figure(8);
subplot(2,2,1); 
probplot(sortabsYn);
legend('Using sorting algorithm');
grid;
subplot(2,2,2); 
normplot(sortabsYn);
legend('Using sorting algorithm');
subplot(2,2,3); 
qqplot(sortabsYn);
legend('Using sorting algorithm');
grid;

% evaluating the time domain of filter_sorted (ifft Yn) data (yn_filt)
figure(9); 
subplot(2,2,1); 
probplot(yn_filt);
legend('sorted algorithm (yn filt) in time domain');
grid;
subplot(2,2,2); 
normplot(yn_filt);
legend('sorted algorithm (yn filt) in time domain');
subplot(2,2,3); 
qqplot(yn_filt);
legend('sorted algorithm (yn filt) in time domain');
grid;

% evaluating the frequency domain (fft) of filter_sorted (Yn) data (Yn_filt_sort)
%  Yn_filt_sort
figure(10); 
test_abs = abs(Yn_filt_sort);
subplot(2,2,1); 
probplot(test_abs);
legend('sorted algorithm (Yn filt sort) in freq domain');
grid;
subplot(2,2,2); 
normplot(test_abs);
legend('sorted algorithm (Yn filt sort) in freq domain');
subplot(2,2,3); 
qqplot(test_abs);
legend('sorted algorithm (Yn filt sort) in freq domain');
grid;

%% do fit comparasion here
%rho = corr(y(1:1000)*T,yn_filt((1:1000)*T));
figure(11); 
%see 
%[x_sorted, i] = sort(y);
%y_sorted = y(i);
% see Modelling Data with the Generalized Extreme Value Distribution
%x = linspace(-3,6,1000);
%plot(x,gevpdf(x,-.5,1,0),'-', x,gevpdf(x,0,1,0),'-', x,gevpdf(x,.5,1,0),'-');
%xlabel('(x-mu) / sigma'); ylabel('Probability Density');
%legend({'k < 0, Type III' 'k = 0, Type I' 'k > 0, Type II'});

%The Generalized Extreme Value Distribution
%x = linspace(-3,6,1000);
%plot(x,gevpdf(x,-.5,1,0),'-', x,gevpdf(x,0,1,0),'-', x,gevpdf(x,.5,1,0),'-');
%xlabel('(x-mu) / sigma'); ylabel('Probability Density');
%legend({'k < 0, Type III' 'k = 0, Type I' 'k > 0, Type II'});

% see empirical cumulative distribution function
% using the sortabsYn as the Univariate variable
p = ((1:fft_n/2)-0.5)' ./ fft_n/2;
stairs(sortabsYn,p,'k-');
xlabel('sortabsYn');
ylabel('Cumulative probability (p)');
legend('Cumulative Pr of sortabsYn');

grid;