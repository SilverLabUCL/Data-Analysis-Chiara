function [ StacksConcatStat, StacksConcatRun, StacksConcatBackw, NewTimes ] = TuftActivityAllStacksBinaryResponsesRunStat( nStacks, FlagSave, FilesLoaded )
% plots detected responses of tuft across all stacks, and separates running
% and stationary periods

% same as code TuftActivityAllStacksBinaryResponses2, but separating running, stationary, and backwards

%% beginning stuff
if nargin < 3
    FilesLoaded = cell(nStacks,1);
end

ThresholdRunningRPM = 5; % 1 rotation= 16 cm
StartVisStim = 2; % time when visual stimulus comes on, in seconds
EndVisStim = 6; % time when visual stimulus disappears, in seconds

% safety message: reminds that visual stimuli parameters need to be set
% right
disp([ 'ATTENTION!! Visual stimulus start is set at ' num2str(StartVisStim) ' s, and end is set at ' num2str(EndVisStim) ' s' ])

%% load data, binarize responses and separate trials into running, stationary, and walking backwards

for s = 1:nStacks
    
    % load data
    [  TransientsChar, DeltaFoverF_Sm_Lin, TimesSegment, Segments, Times, Speed, FilesLoaded{s,1} ] = LoadResponsesSpeedData(FilesLoaded{s,1});
    n_trials = size(Times,1);
    n_timepoints = size(Times,3);
    
    % classify trials in "Run", "Stat" = stationary or "Backw" = when
    % animal goes backwards
    [TrialsRun, TrialsStat, TrialsBackw] = ClassifyTrialsRunStat( Speed, ThresholdRunningRPM, StartVisStim, EndVisStim );
    
    % Create binarized responses using info of onset and duration of each
    % TransientsChar
    [ResponsesBin] = CreateBinarizedResponses( TransientsChar, n_trials, n_timepoints, Segments);
    
    % ResponsesBin and Speed have all trials concatenated, divide trials again
    [ResponsesBinT] = DivideConcatenatedTrials(n_trials, n_timepoints, ResponsesBin);
    TimePoints(s) = size(ResponsesBinT,3);
    
    % remove segments full of NaNs
    for seg = 1 : length(Segments)
        if sum(isnan(DeltaFoverF_Sm_Lin(Segments(seg)))) > 0.75*length(DeltaFoverF_Sm_Lin(Segments(seg)))
            ResponsesBinT(Segments(seg),:,:) = NaN;
            TimesSegment(Segments(seg),:,:) = NaN;
        end
    end
    
    % sum all segments and separate data in run, stat and bcw
    DataStat{s} = reshape (nansum(ResponsesBinT(:,TrialsStat,:),1), length(TrialsStat),  TimePoints(s));
    TimeStat{s} = reshape (nanmean(TimesSegment(:,TrialsStat,:),1), length(TrialsStat),  TimePoints(s));
    
    DataRun{s} = reshape (nansum(ResponsesBinT(:,TrialsRun,:),1), length(TrialsRun),  TimePoints(s));
    TimeRun{s} = reshape (nanmean(TimesSegment(:,TrialsRun,:),1), length(TrialsRun),  TimePoints(s));
    
    DataBackw{s} = reshape (nansum(ResponsesBinT(:,TrialsBackw,:),1), length(TrialsBackw),  TimePoints(s));
    TimeBackw{s} = reshape (nanmean(TimesSegment(:,TrialsBackw,:),1), length(TrialsBackw),  TimePoints(s));
end

%% interpolate data so all stacks have the same temporal scale and concatenate trials

NumberTimePoints= min(TimePoints);
TimeRes = Times(1,1,end)/NumberTimePoints;
NewTimes = 0 : TimeRes : Times(1,1,end);
StacksConcatStat = [];
StacksConcatRun = [];
StacksConcatBackw = [];

for s = 1 : nStacks
    
    % interpolate
    [ DataIntStat ] = InterpolateAllTrials(TimeStat{s}, DataStat{s}, NewTimes);
    [ DataIntRun ] = InterpolateAllTrials(TimeRun{s}, DataRun{s}, NewTimes);
    [ DataIntBackw ] = InterpolateAllTrials(TimeBackw{s}, DataBackw{s}, NewTimes);
    
    %concatenate all the stacks
    StacksConcatStat = [ StacksConcatStat; DataIntStat];
    StacksConcatRun = [ StacksConcatRun; DataIntRun];
    StacksConcatBackw = [ StacksConcatBackw; DataIntBackw];
    
end

%% plot and save

% plot activity in all trials
if isempty(StacksConcatStat) == 0
    
    % plot all trials
    figure;
    imagesc(StacksConcatStat); colorbar
    title('Stationary')
    xlabel(['Time, timepoints, 1 timepoint = ' num2str(TimeRes) ' ms'])
    ylabel('Trial Number')
    % plot mean activity
    MeanAll = nanmean(StacksConcatStat,1);
    figure;
    plot(NewTimes,MeanAll);
    title('Mean Activity across all trials, Stationary')
    xlabel('Time, seconds')
    ylabel('Mean Number of branches active')
    
    if FlagSave
        saveas(gcf-1, 'TuftActivityAllStacks Binarized Stationary.fig' )
        saveas(gcf, 'TuftMeanActivityInTrial Binarized Stationary.fig' )
    end
end

if isempty(StacksConcatRun) == 0
    
    % plot all trials
    figure;
    imagesc(StacksConcatRun); colorbar
    title('Running')
    xlabel(['Time, timepoints, 1 timepoint = ' num2str(TimeRes) ' ms'])
    ylabel('Trial Number')
    % plot mean activity
    MeanAll = nanmean(StacksConcatRun,1);
    figure;
    plot(NewTimes,MeanAll);
    title('Mean Activity across all trials, Running')
    xlabel('Time, seconds')
    ylabel('Mean Number of branches active')
    
    if FlagSave
        saveas(gcf-1, 'TuftActivityAllStacks Binarized Running.fig' )
        saveas(gcf, 'TuftMeanActivityInTrial Binarized Running.fig' )
    end
end

if isempty(StacksConcatBackw) == 0
    
    % plot all trials
    figure;
    imagesc(StacksConcatBackw); colorbar
    title('Walking backwards')
    xlabel(['Time, timepoints, 1 timepoint = ' num2str(TimeRes) ' ms'])
    ylabel('Trial Number')
    % plot mean activity
    MeanAll = nanmean(StacksConcatBackw,1);
    figure;
    plot(NewTimes,MeanAll);
    title('Mean Activity across all trials, Walking backwards')
    xlabel('Time, seconds')
    ylabel('Mean Number of branches active')
    
    if FlagSave
        saveas(gcf-1, 'TuftActivityAllStacks Binarized Walking Backwards.fig' )
        saveas(gcf, 'TuftMeanActivityInTrial Binarized Walking Backwards.fig' )
    end
end

if FlagSave
    save([' TuftActivityAllStacks Binarized RunStat' date '.mat'])
end

end

function [ TransientsChar, DeltaFoverF_Sm_Lin, TimesSegment, Segments, Times, Speed, FilesLoaded ] = LoadResponsesSpeedData(FilesLoaded)

if isempty(FilesLoaded) == 1
    % the user loads a file that contains TransientsChar
    [filename,pathname]=uigetfile('*.mat');
    FilesLoaded=[pathname filename];
else
    pathname = FilesLoaded(1: find(FilesLoaded == '\', 1, 'last')); % equal to 1 if has to go up by one folder to find speed data, if 2 folders put number to 2
end

% load responses data
load(FilesLoaded,'TransientsChar','DeltaFoverF_Sm_Lin','FileLoaded','Segments','Times')
load(FileLoaded,'TimesSegment')
% load speed data
PathSpeed = pathname(1: find(pathname == '\', 2,'last') );
load([PathSpeed 'SpeedData.mat'],'Speed')
end

function [TrialsRun, TrialsStat, TrialsBackw] = ClassifyTrialsRunStat( Speed, ThresholdRunningRPM, StartVisStim, EndVisStim )
% classify trials as "running" if (80% of) animal speed > than
% theshold for 0.5 s before appearence of vis stim until end of
% presentation

% initialise variables and counters
TrialsRun = [];
TrialsStat = [];
TrialsBackw = [];
counterRun = 0;
counterStat= 0;
counterBack = 0;
AllTrials = Speed{1,end}; % trials where speed data was successfully saved

for t = 1 : length(AllTrials)
    
    time = Speed{1,t}(:,1);
    speed = Speed{1,t}(:,2);
    
    % find indexes corresponding to when visual stimulus appears and
    % disappeares
    [ ~ , StartIndex ] = min(abs(time - (StartVisStim - 0.5)*1e3 )); %consider 0.5 s before appearence of visual stim
    [ ~ , EndIndex ] = min(abs(time - EndVisStim*1e3 ));
    
    % find times when animal runs, sits and goes backwards
    RunTimes = speed(StartIndex:EndIndex) > ThresholdRunningRPM;
    BackTimes = speed(StartIndex:EndIndex) < -3; % take into account resolution of encoder of ~ 3 rpm
    StatTimes =  abs(  (BackTimes + RunTimes) - 1 );
    
    if sum(RunTimes)/length(RunTimes) >= 0.65 % if animal runs for more than 65% of the time classify trial as running
        
        counterRun = counterRun + 1;
        TrialsRun(counterRun) = AllTrials(t);
        
    elseif sum(StatTimes)/length(StatTimes) >= 0.9 % classify trial as stationary
        
        counterStat = counterStat + 1;
        TrialsStat(counterStat) = AllTrials(t);
        
    elseif sum(BackTimes)/length(BackTimes) >= 0.8 % classify trial as backwards
        
        counterBack = counterBack + 1;
        TrialsBackw(counterBack) = AllTrials(t);
        
    end
end
end

function [ResponsesBin] = CreateBinarizedResponses( TransientsChar, n_trials, n_timepoints, Segments)

ResponsesBin = NaN( length(Segments), n_trials*n_timepoints );

for seg = 1 : length(Segments)
    
    n_events = length(TransientsChar(1,Segments(seg)).PosMax);
    ResponsesBin(Segments(seg), :) = 0;
    
    for e = 1:n_events
        % if onset and duration are not NaN
        if isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 0 && isnan( TransientsChar(1,Segments(seg)).Duration(e) ) == 0
            Onset = TransientsChar(1,Segments(seg)).OnsetApprox(e);
            End = TransientsChar(1,Segments(seg)).OnsetApprox(e) + TransientsChar(1,Segments(seg)).Duration(e);
            % if only duration is NaN, assume that duration was not found
            % because the event occurred at the end of the recording
        elseif isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 0 && isnan( TransientsChar(1,Segments(seg)).Duration(e) ) == 1
            Onset = TransientsChar(1,Segments(seg)).OnsetApprox(e);
            End = n_trials*n_timepoints;
            % if onset is NaN, take PosMax and a few elements before and after (not very precise...)
        elseif isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 1
            Onset = TransientsChar(1,Segments(seg)).PosMax(e) ;
            End = TransientsChar(1,Segments(seg)).PosMax(e) ;
        end
        
        ResponsesBin(Segments(seg), Onset : End ) = 1;
    end
end
end

function [DataInTrials] = DivideConcatenatedTrials(n_trials, n_timepoints, data)

n_segments = size(data,1);

DataReshaped = NaN(n_segments, n_timepoints, n_trials);
DataInTrials = NaN(n_segments, n_trials, n_timepoints);

for seg = 1 : n_segments
    DataReshaped(seg,:,:) = reshape( data(seg,:), n_timepoints, n_trials);
    DataInTrials (seg,:,:)= (squeeze(DataReshaped(seg,:,:)))';
end

end

function  [ DataInt ] = InterpolateAllTrials(Time, Data, NewTimes)

n_trials = size(Data,1);
DataInt = [];

if isempty(Data) == 0
    
    for tr = 1 : n_trials
        DataInt(tr, :) = interp1( Time(tr,:), Data(tr,:), NewTimes);
    end
    
else
    DataInt = [];
end
end





