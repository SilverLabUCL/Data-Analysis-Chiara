function [ s3_fft,f ] = FourierT( data, SamplingRate )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


tmax=length(data)/SamplingRate;
Nsamps = tmax*SamplingRate;

t = 1/SamplingRate:1/SamplingRate:tmax;

f = SamplingRate*(0:Nsamps/2-1)/Nsamps;   %Prepare freq data for plot

%Original + High Freq
s3_fft = abs(fft(data));
s3_fft = s3_fft(1:Nsamps/2);      %Discard Half of Points

figure
plot(f, s3_fft)
xlabel('Freq Hz')


end

