function [ CamData, TimeCamData ] = TimesCamData( TimeFrames, Data, LengthTrial )
% videos are acquired also between trials, this code removes frames between
% trials and concatenate camera data and times data

% check that TimesFrames and Data have the same length
if length(TimeFrames) ~= length(Data)
   disp('ERROR!!! Times and data do not have the same number of elements') 
end

% find beginning and end of each trial
TrialStart = find(TimeFrames == 0);
n_trials = length(TrialStart);
disp(['I found ' num2str(n_trials) ' trials'])

for t = 1:(n_trials-1)
    [~, p] = min(abs( TimeFrames(TrialStart(t):TrialStart(t+1)) - LengthTrial*1e3 ));
    TrialEnd(t) = p + TrialStart(t) -1;
end

[~, p] = min(abs( TimeFrames(TrialStart(n_trials):end) - LengthTrial*1e3 ));
TrialEnd(n_trials) = p + TrialStart(n_trials) -1;

% remove extra frames and concatenate data
TimeCamData = [];
CamData = [];
for t = 1:n_trials
    TimeCamData = [TimeCamData TimeFrames(TrialStart(t):TrialEnd(t)) + LengthTrial*1e3*(t-1)];
    CamData = [CamData Data(TrialStart(t):TrialEnd(t)) ];
end


end

