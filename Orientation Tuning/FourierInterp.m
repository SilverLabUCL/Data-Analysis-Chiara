function yi=FourierInterp(y)

N=length(y);
f=fft(y);
if mod(N,2) == 0
    ff(1:N/2)=f(1:N/2);
    ff(360-N/2+2:360)=f(N/2+2:N);
    ff(N/2+1)=f(N/2+1)/2;
    ff(360-N/2+1)=f(N/2+1)/2;
else
    ff(1:floor(N/2)+1)=f(1:floor(N/2)+1);
    ff(360-floor(N/2)+1:360)=f(N-floor(N/2)+1:N);
end

yi=real(ifft(ff)*360/N);