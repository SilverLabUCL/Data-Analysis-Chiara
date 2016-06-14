function [EyeMov] = AnalyseEyeMov(PupilCentroid, TimeStamps)

TimeVisStim = [4 6]; % time during which visual stimulus is on, in seconds

% find beginning of each trial
StartTrials = [ find(TimeStamps == 0) length(TimeStamps)];
n_trials = length(StartTrials)-1;

if n_trials == 16 % check this is a stack with gratings presentation, 16 trials
    % initialise stuff
    EyeMovAng = NaN(n_trials, (TimeVisStim(2) - TimeVisStim(1))*30+3); % eye movement in angle, degrees
    EyeMov = NaN(1,n_trials); % measure if there was an eye movement bigger than 5 degrees
    
    % measure eye movements during visual stimulus presentation in each trial
    for t = 1:n_trials
        
        TimeTrial = TimeStamps(StartTrials(t) : StartTrials(t+1)-1);
        [ ~, StartVisStim] = min( abs(TimeTrial - TimeVisStim(1)*1e3) );
        [ ~, EndVisStim] = min( abs(TimeTrial - TimeVisStim(2)*1e3) );
        
        StartVisStim = StartVisStim + StartTrials(t)-1;
        EndVisStim = EndVisStim + StartTrials(t)-1;
        
        EyeMovAng(t, 1: (EndVisStim-StartVisStim+1)) = MeasureEyeMovements( PupilCentroid(StartVisStim:EndVisStim, :), 1 );
        
        EyeMov(t) = isempty( EyeMovAng(t, EyeMovAng(t,:) > 5));
    end
    
    EyeMov = abs(EyeMov-1);
    
else
    EyeMov = [];
end

end

