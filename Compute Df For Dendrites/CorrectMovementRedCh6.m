function [ GreenOverRed ] = CorrectMovementRedCh6(DataGreenCh,DataRedCh, Times, FlagPlot)
%Correct for movement the green trace with the red channel

% 13 April 2015: version number 4: add scaling of red trace

% May 2015: version 5: discard data when the POI is out of dendrite (red trace is below a thresholdmeasured from "dark areas" in images in stacks)
% to discard data: substitute with NaN

%% parameters and basic stuff
WindowFilteringRed=1000; %in ms
WindowFilteringGreen=100; %in ms

n_trials=size(DataGreenCh,1);
n_POIs=size(DataGreenCh,2);
n_timepoints=size(DataGreenCh,3);


%% temporal filtering to remove noise
SmoothFactoRed=round(WindowFilteringRed/Times(1,1,2));
SmoothFactoGreen=round(WindowFilteringGreen/Times(1,1,2));

RedSmoothed=zeros(n_trials,n_POIs,n_timepoints);
GreenSmoothed=zeros(n_trials,n_POIs,n_timepoints);

for trial=1:n_trials
    for POI=1:n_POIs
        RedSmoothed(trial,POI,:)=squeeze(smooth(DataRedCh(trial,POI,:),SmoothFactoRed,'lowess'));
        GreenSmoothed(trial,POI,:)=squeeze(smooth(DataGreenCh(trial,POI,:),SmoothFactoGreen,'lowess'));
    end
end

%% substract red channel to the green and discard data when POI is out of dendrite

GreenOverRed=zeros(n_trials,n_POIs,n_timepoints);
ThrRedNoise=5;

for POI=1:n_POIs
    
    %scale red to the green, use mean value of trace in all trials
    GreenSmoothedConcat=reshape(GreenSmoothed(:,POI,:),1,[]);
    RedSmoothedConcat=reshape(RedSmoothed(:,POI,:),1,[]);
    ScalingFactor=mean(GreenSmoothedConcat)/mean(RedSmoothedConcat)*2;
    
    cv = std(RedSmoothedConcat)/mean(RedSmoothedConcat);
    
    for trial=1:n_trials
        for t=1:n_timepoints
%             %substract red trace to the green trace
%             if cv > 0.02
%                 GreenOverRed(trial,POI,t) = NaN;
%                 if trial == 1 && t == 1
%                     disp(['Discarded POI ' num2str(POI) ' because it has too much movement'])
%                 end
%             else
                GreenOverRed(trial,POI,t)=GreenSmoothed(trial,POI,t) - ScalingFactor*RedSmoothed(trial,POI,t);
%             end
        end
        
        GreenOverRed(trial,POI,find(RedSmoothed(trial,POI,:)<ThrRedNoise)) = NaN;
        
    end
    
end


%% reset mean value of trace and get rid of negative values

for POI=1:n_POIs
    
    GreenSmooothConcat=reshape(squeeze(GreenSmoothed(:,POI,:)),1,[]);
    GreenMean=mean(GreenSmooothConcat);
    
    for trial=1:n_trials
        
        GreenOverRed(trial,POI,:)=GreenOverRed(trial,POI,:) + GreenMean;
        
        % set to zero all values < 0
        NegativeValues=find(GreenOverRed(trial,POI,:)<0);
        GreenOverRed(trial,POI,NegativeValues)=0;
        clear NegativeValues
    end
    
    clear  RedSmooothConcat
end



%% plot one trace as example

if FlagPlot
    
    POI=43;
    
    if POI > n_POIs
        POI=n_POIs;
    end
    
    %concatenate data
    for trial=1:n_trials
        GreenORedConcat(1+(trial-1)*n_timepoints : n_timepoints*trial )=squeeze(GreenOverRed(trial,POI,:));
        RedConcat( 1+(trial-1)*n_timepoints : n_timepoints*trial )=squeeze(RedSmoothed(trial,POI,:));
        GreenConcat( 1+(trial-1)*n_timepoints : n_timepoints*trial )=squeeze(GreenSmoothed(trial,POI,:));
    end
    
    t=(1:length(GreenConcat)).*Times(1,1,2)*1e-3;
    figure;
    plot(t,GreenConcat,'g'); hold on; plot(t, RedConcat,'r'); hold all; plot(t,GreenORedConcat','k');
    box off
    
end

end

