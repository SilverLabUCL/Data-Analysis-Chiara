function [ Onset ] = DetermineOnset( data, PosMax, Baseline, FlagPlot )
%Find onset and duration of responses occurred in PosMax
% determine onset as first point 3 standard deviations above baseline
% determine end of response with same criterion

NoiseBaseline=nanmean(data(Baseline(1):Baseline(2)));
Noise=nanstd(data(Baseline(1):Baseline(2)));

n_events=numel(PosMax);
Onset=zeros(1,n_events);

for e=1:n_events
    
    %% determine onset
    counter=PosMax(e);
    
    while data(counter) > (3*Noise + NoiseBaseline)
        counter=counter-1;
        
        if counter<1 %if reaches the beginning of the recording
           counter=NaN; %gives up finding onset
           break %exit while loop
        end
        
    end
    
    Onset(e)=counter;
    
end

%plot
if FlagPlot
   
   OnsetNoNaN = Onset;
   OnsetNoNaN (isnan(Onset)==1) = [];
   
   figure;
   plot(1:numel(data),data,OnsetNoNaN,data(OnsetNoNaN),'c.', 'MarkerSize',20); 
   title('Onsets')
   
end

end

