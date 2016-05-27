function [ FiringRateRun, FiringRateStat, n_responsesRun, TimeRunSec, n_responsesStat, TimeStatSec] = FiringRateBranchRunStat( nStacks, FlagSave, FilesLoaded)
% takes binarized responses (only if branch is on/off) and calculates
% firing rate (number of events/s) for each branch when the animal is
% stationary or running

%% beginning stuff: default inputs, parameters and initialisation of variables

if nargin<1
    nStacks = inputdlg('How many stacks do you want to analyze?');
    nStacks = str2double(nStacks{1});
end

if nargin<2
    FlagSave = 0;
end

if nargin < 3
    FilesLoaded = cell(nStacks,1);
end

ThresholdRunningRPM = 3; % 1 rotation= 50 cm

n_responsesRun = NaN(nStacks,3); % assume that there are at least 3 branches, just to initialise variables
n_responsesStat = NaN(nStacks,3);
TimeRunSec = zeros(nStacks,3);
TimeStatSec = zeros(nStacks,3);
FiringRateRun = NaN(3,1);
FiringRateStat = NaN(3,1);
%% measure firing rate in stationary and running periods

for s = 1 : nStacks
    
    % load data
    [ TransientsChar, Segments, Times_Lin, Times, Speed, SpeedTime, FilesLoaded{s,1} ] = LoadResponsesSpeedData(FilesLoaded{s,1});
    
    % binarize responses
    [ResponsesBin] = CreateBinarizedResponses( TransientsChar, size(Times,1), size(Times,3), Segments, size(Times_Lin,1), mean(diff(Times(1,1,:))));
    
    % finds number of responses and time spent for each condition
    for br = 1 : length(Segments)
        [ n_responsesRun(s, Segments(br)), TimeRunSec(s, Segments(br)), n_responsesStat(s, Segments(br)), TimeStatSec(s, Segments(br)) ] = ComputeFiringRateBranch( Times_Lin(Segments(br),:), ResponsesBin(Segments(br),:), SpeedTime, Speed, ThresholdRunningRPM);
    end
end

% calculate firing rates
for br = 1 : size(n_responsesRun, 2)
    FiringRateRun(br) = nansum(n_responsesRun(:, br)) / sum(TimeRunSec(:, br));
    FiringRateStat(br) = nansum(n_responsesStat(:, br)) / sum(TimeStatSec(:, br)) ;
end

% save
if FlagSave
    save('FiringRateBranchRunStat.mat')
end

end


function [ TransientsChar, Segments, Times_Lin, Times, speed, time, PathFile ] = LoadResponsesSpeedData(PathFile)

if isempty(PathFile) == 1
    % the user loads a file that contains TransientsChar
    [filename,pathname] = uigetfile('*.mat');
    PathFile = [pathname filename];
else
    pathname = PathFile(1: find(PathFile == '\', 1, 'last')); % equal to 1 if has to go up by one folder to find speed data, if 2 folders put number to 2
end

% load responses data
load(PathFile,'TransientsChar','Segments','Times','Times_Lin')
% load speed data
PathSpeed = pathname(1: find(pathname == '\', 2,'last') );
load([PathSpeed 'SpeedConcat.mat'],'speed','time')

end

function [ResponsesBin] = CreateBinarizedResponses( TransientsChar, n_trials, n_timepoints, Segments, n_segments, TimeRes)

ResponsesBin = NaN( n_segments, n_trials*n_timepoints );

for seg = 1 : length(Segments)
    
    n_events = length(TransientsChar(1,Segments(seg)).PosMax);
    ResponsesBin(Segments(seg), :) = 0;
    
    for e = 1:n_events
        % if onset and duration are not NaNs
        if isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 0 && isnan( TransientsChar(1,Segments(seg)).Duration(e) ) == 0
            Onset = TransientsChar(1,Segments(seg)).OnsetApprox(e);
            End = TransientsChar(1,Segments(seg)).OnsetApprox(e) + TransientsChar(1,Segments(seg)).Duration(e);
            
            % if only duration is NaN, assume that duration was not found
            % because the event occurred at the end of the recording
        elseif isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 0 && isnan( TransientsChar(1,Segments(seg)).Duration(e) ) == 1
            Onset = TransientsChar(1,Segments(seg)).OnsetApprox(e) - 1; % take 1 point before onset so response is at least 1 point long
            End = n_trials*n_timepoints;
            
            % if onset is NaN, take PosMax and n elements before and after
            % the maximum of the response corresponding to
            % rise time and decay time of gcamp6f
        elseif isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 1
            
            RiseTime = round(50/TimeRes); % 50 ms rise time
            DecayTime = round(150/TimeRes); % 150 ms decay time
            
            if TransientsChar(1,Segments(seg)).PosMax(e) > RiseTime
                Onset = TransientsChar(1,Segments(seg)).PosMax(e) - RiseTime ;
            else
                Onset = TransientsChar(1,Segments(seg)).PosMax(e);
            end
            
            if TransientsChar(1,Segments(seg)).PosMax(e) < n_trials*n_timepoints - DecayTime
                End = TransientsChar(1,Segments(seg)).PosMax(e) + DecayTime ;
            else
                End = n_trials*n_timepoints;
            end
        end
        
        ResponsesBin(Segments(seg), Onset : End ) = 1;
    end
end
end

function [ n_responsesRun, TimeRunSec, n_responsesStat, TimeStatSec ] = ComputeFiringRateBranch(TimesResponses, Responses, TimesSpeed, Speed, ThresholdRunningRPM)

TimeRunSec = 0;
TimeStatSec = 0;
n_responsesRun = NaN;
n_responsesStat = NaN;

TimeRes = mean(diff(TimesResponses));
Responses = [0 Responses 0];
TimesResponses = [0 TimesResponses (TimesResponses(end)+TimeRes)];

% find times of responses
StartR = find(diff(Responses) == 1);
EndR = find(diff(Responses) == -1);

% interpolate speed data to have same temporal scale as responses
SpeedInterp = interp1(TimesSpeed, Speed, TimesResponses);
RunTime = find(SpeedInterp > ThresholdRunningRPM);
StatTime = find(SpeedInterp <= ThresholdRunningRPM & SpeedInterp >= -ThresholdRunningRPM);

% look for responses during running
if isempty(RunTime) == 0 % if animal runs 
    n_responsesRun = 0;
    for e = 1:length(StartR) % look at each response
        if sum(ismember( StartR(e):EndR(e), RunTime)) >  length(StartR(e):EndR(e))*0.9 % if 90% of the response occurrs during running
            n_responsesRun = n_responsesRun + 1; % count responses
        end
    end
    TimeRunSec = (TimeRes*length(RunTime)*1e-3); % how long animal runs in total, in seconds
end

% look for responses when animal is stationary
if isempty(StatTime) == 0
    n_responsesStat = 0;
    for e = 1:length(EndR)
        if sum(ismember( StartR(e):EndR(e), StatTime)) >  length(StartR(e):EndR(e))*0.9 % if 90% of the response occurrs while the animal is stationary
            n_responsesStat = n_responsesStat + 1;
        end
    end
    TimeStatSec = (TimeRes*length(StatTime)*1e-3); % how long animal is stationary in total, in seconds
end
end


