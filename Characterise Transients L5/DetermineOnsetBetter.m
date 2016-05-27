function [ Onset ] = DetermineOnsetBetter( data, TimesLin, PosMax, Amplitude, OnsetApprox, FlagPlot )
%determines onset as crossing between baseline and line that passes in
%10 and 20% of fluorescence of response

n_events=numel(PosMax);
TimeRes = nanmean(diff(TimesLin));
Onset=zeros(1,n_events);
ImageHandle = gcf;

for e=1:n_events
    
    if isnan(OnsetApprox(e))==0
        
        %find times corresponding to 10% and 20% of the peak fluorescence
        [~, Time10] = min( abs( data(OnsetApprox(e) : PosMax(e)) - Amplitude(e)*0.1 ) );
        [~, Time20] = min( abs( data(OnsetApprox(e) : PosMax(e)) - Amplitude(e)*0.2 ) );
        %correct to have indexes referring to vector data
        Time10 = Time10 + OnsetApprox(e);
        Time20 = Time20 + OnsetApprox(e);
        RiseResponseLine = LinePassing2Points( TimesLin(Time10),data(Time10),TimesLin(Time20),data(Time20));
        
        % find baseline: fit a line on data before response
        FirstPointBaseline = OnsetApprox(e) - round(1000/TimeRes); %take point 2 s before approximate onset
        SecondPointBaseline = OnsetApprox(e) - round(100/TimeRes); %take point 50 ms before approximate onset
        FilteredData = [ smooth(data(1:OnsetApprox(e)),800)' data(OnsetApprox(e):end) ];
        BaseLinet = polyfit( TimesLin(FirstPointBaseline: SecondPointBaseline), FilteredData(FirstPointBaseline: SecondPointBaseline),0 );
        BaseLine(1) = 0;
        BaseLine(2) = BaseLinet ;

        % measure onset
        [Onset(e), IntOnset] = CrossPoints2Lines( RiseResponseLine(1) , RiseResponseLine(2), BaseLine(1), BaseLine(2) );
        
        % plot
        if FlagPlot
            
            YPlot1 = TimesLin.*RiseResponseLine(1) + RiseResponseLine(2); % first line
            YPlot2 = TimesLin.*BaseLine(1) + BaseLine(2); %second line
            
            figure(ImageHandle+1); 
            subplot(1,n_events,e)
            plot(TimesLin*1e-3,data,'b') % plot data
            hold all; plot(TimesLin(Time10)*1e-3,data(Time10),'go',TimesLin(Time20)*1e-3,data(Time20),'go') % plot points used to trace line of rise of response 
            hold all; plot(TimesLin*1e-3,YPlot1,'g') % plot line for response rise
            hold all; plot(TimesLin(FirstPointBaseline)*1e-3,data(FirstPointBaseline),'mo',TimesLin(SecondPointBaseline)*1e-3,data(SecondPointBaseline),'mo') % plot points used to trace baseline 
            hold all; plot(TimesLin*1e-3,YPlot2,'m') % plot baseline
            hold all; plot(Onset(e)*1e-3, IntOnset,'r.','MarkerSize',20) % plot onset
            % set axis limits to zoom in on response
            xlim([ (TimesLin(OnsetApprox(e))*1e-3 - 3) (TimesLin(OnsetApprox(e))*1e-3+10) ])
            ylim([ -0.5 Amplitude(e)+1])
            xlabel('seconds'), ylabel('DeltaFoF')
        end
        
        
    else
        Onset(e) = NaN;
    end
    
    
    
end

end



function [ Line ] = LinePassing2Points( x1,y1,x2,y2 )

Slope = (y2 -y1) / (x2 - x1);
Offset = y1 - Slope*x1;
Line = [Slope; Offset];
end


function [ x, y ] = CrossPoints2Lines( Slope1, Offset1, Slope2, Offset2 )

x = (Offset2 - Offset1)/(Slope1 - Slope2);
y = Slope1*x + Offset1;

end


