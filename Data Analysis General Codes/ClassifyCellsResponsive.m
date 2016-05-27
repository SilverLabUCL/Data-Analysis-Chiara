function [ Classification, PValue] = ClassifyCellsResponsive( AllStacksConcat, TimeAllStacks)
%calculates if a cell is responsive to visual stimuli, repressed by visual
%stimuli or non responsive.

% CAREFUL! DOESN'T DIVIDE BY TIME OF PRESENTATION, SO TIME OF VIS STIM AND
% GREY SCREEN NEED TO BE THE SAME. It works for gratings

% AllStacksConcat(trial, timepoint): DeltaF/F or binarized responses of all trials concatenated

% parameters visual stimuli
StartGrey = 1;
VisStimOn = 2; % when visual stimulus comes on, in seconds
VisStimOff = 3; % when visual stimulus comes off, in seconds
[ ~, VisStimOnIndex ] = min( abs(TimeAllStacks - 1e3*VisStimOn) );
[ ~, VisStimOffIndex ] = min( abs(TimeAllStacks - 1e3*VisStimOff) );
%[ ~, VisStimOnInter ] = min( abs(TimeAllStacks - 1e3*(VisStimOn + 2) ) );
[ ~, StartGreyIndex ] = min( abs(TimeAllStacks - 1e3*StartGrey) );

% calculate integral of Df/f during visual stim and gray screen
n_trials = size(AllStacksConcat,1);
ActivityVisStim = NaN(1,n_trials);
ActivityGrayScreen = NaN(1,n_trials);

for t = 1:n_trials
    
    % compare all the time period when visual stim is on with all time
    % period with gray screem
    ActivityVisStim(t) = nansum( AllStacksConcat(t, VisStimOnIndex:VisStimOffIndex) );
    %ActivityGrayScreen(t) = nansum([ AllStacksConcat(t, 1:VisStimOnIndex) AllStacksConcat(t, VisStimOffIndex:end) ]);    
    ActivityGrayScreen(t) = nansum( AllStacksConcat(t, StartGreyIndex:VisStimOnIndex));    

%     % compare first 2 seconds when visual stim comes on with 2 s after vis stim goes off 
%     ActivityVisStim(t) = nansum( AllStacksConcat(t, VisStimOnIndex:VisStimOnInter) );
%     ActivityGrayScreen(t) = nansum(AllStacksConcat(t, VisStimOffIndex:end));

end

% use paired-sample t-test to measure if responses during visual stimuli and
% during gray screen are significantly different with 5% significance level
alpha = 0.05; % significance level: usually 5%, can use bonferroni correction and divide by number of t-test run
[ ResponsesAreDifferent, PValue] = ttest(ActivityVisStim, ActivityGrayScreen,alpha);
%[ ResponsesAreDifferent, PValue] = ttest(ActivityVisStim, ActivityGrayScreen);

% classify in responsive or repressed by visual stimuli
if ResponsesAreDifferent
    
    if nanmean(ActivityVisStim) > nanmean(ActivityGrayScreen)
        Classification = 'Responsive';
    elseif nanmean(ActivityVisStim) < nanmean(ActivityGrayScreen)
        Classification = 'Repressed';
    end

else
    Classification = 'NonResponsive';
end

end

