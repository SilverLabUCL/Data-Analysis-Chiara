function [ Duration, Integral, End ] = DetermineDurationAndIntegral( data, PosMax, Baseline, Onset, FlagPlot)
%Find onset and duration of responses occurred in PosMax
% determine end of response as 3 standard deviations above baseline, and
% calculate integral of response

NoiseBaseline=nanmean(data(Baseline(1):Baseline(2)));
Noise=nanstd(data(Baseline(1):Baseline(2)));

n_events=numel(PosMax);
Duration=zeros(1,n_events);
End=zeros(1,n_events);
Integral=zeros(1,n_events);

for e=1:n_events
    counter=PosMax(e);
    
    while data(counter) > (3*Noise + NoiseBaseline)
        counter=counter+1;
        
        if counter>numel(data) %if reaches the end of the recording
           counter=NaN; %gives up finding end of response
           break %exit while loop
        end
        
    end
    
    End(e)=counter;
    Duration(e)=End(e) - Onset(e);
    
    if isnan(Onset(e)) == 1 || isnan(End(e)) == 1
        Integral(e) = NaN;
    else
        Integral(e) = sum(data( Onset(e) : End(e) )) ;
    end
end

if FlagPlot
    
    OnsetNoNaN = Onset;
    OnsetNoNaN (isnan(Onset)==1) = [];
    
    EndNoNaN = End;
    EndNoNaN (isnan(End)==1) = [];
    
    figure;
    plot(1:numel(data),data,OnsetNoNaN,data(OnsetNoNaN),'m.', 'MarkerSize',20); 
    hold on;
    plot(EndNoNaN,data(EndNoNaN),'m.', 'MarkerSize',20); 
    title('Response duration')
    
end

end

