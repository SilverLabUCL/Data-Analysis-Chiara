function [ Y, F ] = PowerSpectrum( Vector, sampling_interval )
%Plot power spectrum of the timeseries Vector, with the timepoints specified in the vector time
% NB time needs to be in seconds!!

L=length(Vector);
%sampling_interval=mean(diff(time));

Y=fft(Vector)/L;

NyLimit = (1 / sampling_interval)/ 2;
F = linspace(0,1,L/2)*NyLimit;

figure;
plot(F,(Y(1:L/2).*conj(Y(1:L/2))))
xlabel('Hertz'), ylabel('Power')
axis tight

end

