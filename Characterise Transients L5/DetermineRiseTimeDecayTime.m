function [ RiseTime, DecayTime ] = DetermineRiseTimeDecayTime( data, PosMax, Amplitude, Onset, Duration, FlagPlot )
% determine rise time:
%time to go from 10 to 90% of the peak
% and decay time:
% time to go from peak to 37% of the peak (tau)

n_events=numel(PosMax);

Time10=zeros(1,n_events);
Time90=zeros(1,n_events);
Time37=zeros(1,n_events);
RiseTime=zeros(1,n_events);
DecayTime=zeros(1,n_events);

for e=1:n_events
    
    %find times corresponding to 10%, 90% and 37% of the peak fluorescence
    if isnan(Onset(e))==0 && (PosMax(e) + Duration(e) + 2) <= length(data)
        [~, Time10(e)] = min( abs( data(Onset(e) : PosMax(e)) - Amplitude(e)*0.1 ) );
        [~, Time90(e)] = min( abs( data(Onset(e) : PosMax(e)) - Amplitude(e)*0.9 ) );
        [~, Time37(e)] = min( abs( data(PosMax(e) : (PosMax(e) + Duration(e))) - Amplitude(e)*0.37 ) );
    else
        Time10(e) = NaN;
        Time90(e) = NaN;
        Time37(e) = NaN;
    end

    %correct to have indexes referring to vector data
    Time10(e) = Time10(e) + Onset(e);
    Time90(e) = Time90(e) + Onset(e);
    Time37(e) = Time37(e) + PosMax(e);
    %calculate rise and decay time
    RiseTime(e) = Time90(e) - Time10(e);
    DecayTime(e) = Time37(e) - PosMax(e);
    
end

% plot
if FlagPlot
    
    figure;
    plot(1:numel(data),data)
    hold on
    
    for e = 1 : n_events
    if isnan(Time10(e))==0
        plot(Time10(e), data(Time10(e)),'c.', 'MarkerSize',20)
        hold all
        plot(Time90(e), data(Time90(e)),'g.', 'MarkerSize',20)
        hold all
        plot(Time37(e), data(Time37(e)),'m.', 'MarkerSize',20)
        hold all
    end
    end
    
    plot(PosMax, data(PosMax),'r.', 'MarkerSize',20)
    hold off
    title('Rise Time and Decay Time')
    
end

end

