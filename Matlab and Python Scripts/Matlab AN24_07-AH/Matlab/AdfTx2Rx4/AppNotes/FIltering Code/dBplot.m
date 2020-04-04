% This function calculates and plots in Db format

function dBplot(H,f,color)

if nargin > 2
   plot(f,dB(H),color);
   xlabel('Frequency in [Hz]');
elseif nargin > 1
   plot(f,dB(H));
   xlabel('Frequency in [Hz]');
else   
   plot(dB(H));
end

ylabel('Magnitude in [dB]');
grid;
