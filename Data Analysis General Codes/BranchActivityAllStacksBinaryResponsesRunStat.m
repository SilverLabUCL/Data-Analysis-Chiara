function [ StacksConcatStat, StacksConcatRun, StacksConcatBackw, FilesLoaded] = BranchActivityAllStacksBinaryResponsesRunStat( nStacks, FlagSave, FilesLoaded )
% plots detected responses of tuft across all stacks, and separates running
% and stationary periods
% same as code TuftActivityAllStacksBinaryResponses2, but separating running, stationary, and backwards

%% beginning stuff

if nargin < 3
    FilesLoaded = cell(nStacks,1);
end

% parameters
ThresholdRunningRPM = 5; % 1 rotation= 50 cm
StartVisStim = 2; % time when visual stimulus comes on, in seconds
EndVisStim = 4; % time when visual stimulus disappears, in seconds
disp([ 'ATTENTION!! Visual stimulus start is set at ' num2str(StartVisStim) ' s, and end is set at ' num2str(EndVisStim) ' s' ])

% initialisation
DataStat = cell(1,nStacks);
DataRun = cell(1,nStacks);
DataBackw = cell(1,nStacks);
TimeStat = cell(1,nStacks);
TimeRun = cell(1,nStacks);
TimeBackw = cell(1,nStacks);
SegmentsAll = cell(1,nStacks);

%% binarize responses and separate trials into running, stationary, and walking backwards

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
    
    % remove segments full of NaNs
    for seg = 1 : length(Segments)
        if sum(isnan(DeltaFoverF_Sm_Lin(Segments(seg)))) > 0.75*length(DeltaFoverF_Sm_Lin(Segments(seg)))
            ResponsesBinT(Segments(seg),:,:) = NaN;
            TimesSegment(Segments(seg),:,:) = NaN;
        end
    end
    
    % separate data in run, stat and bcw
    DataStat{s} = ResponsesBinT(:,TrialsStat,:);
    TimeStat{s} = TimesSegment(:,TrialsStat,:);
    
    DataRun{s} = ResponsesBinT(:,TrialsRun,:);
    TimeRun{s} = TimesSegment(:,TrialsRun,:);
    
    DataBackw{s} = ResponsesBinT(:,TrialsBackw,:);
    TimeBackw{s} = TimesSegment(:,TrialsBackw,:);
    
    SegmentsAll{s} = Segments;
end


%% plot all trials together and save the data branch by branch

n_segments = size(DeltaFoverF_Sm_Lin,1);
StacksConcatStat = cell(1,n_segments);
StacksConcatRun = cell(1,n_segments);
StacksConcatBackw = cell(1,n_segments);
TimesConcatStat = cell(1,n_segments);
TimesConcatRun = cell(1,n_segments);
TimesConcatBackw = cell(1,n_segments);

for seg = 1 : n_segments
    
    % interpolate and concatenate data for each branch
    [ StacksConcatStat{seg}, TimesConcatStat{seg}] = ConcatenateStacks( seg, DataStat, TimeStat, SegmentsAll, Times);
    [ StacksConcatRun{seg}, TimesConcatRun{seg}] = ConcatenateStacks( seg, DataRun, TimeRun, SegmentsAll, Times);
    [ StacksConcatBackw{seg}, TimesConcatBackw{seg}] = ConcatenateStacks( seg, DataBackw, TimeBackw, SegmentsAll, Times);
    
    % plot and save
    PlotAllTrials(StacksConcatStat{seg}, TimesConcatStat{seg}, ['Branch ' num2str(seg) ' Stationary'], FlagSave)
    PlotAllTrials(StacksConcatRun{seg}, TimesConcatRun{seg}, ['Branch ' num2str(seg) ' Running'], FlagSave)
    PlotAllTrials(StacksConcatBackw{seg}, TimesConcatBackw{seg}, ['Branch ' num2str(seg) ' Walking Backwards'], FlagSave)
end

if FlagSave
    save([' BranchActivityAllStacks Binarized RunStat' date '.mat'])
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

function [ StacksConcat, NewTimes] = ConcatenateStacks( BranchID, DataOriginal, TimeOriginal, SegmentsAll, Times)

CounterStacks = 0;
nStacks = length(DataOriginal);

% keep only stacks that have recordings for the requested branch
for s = 1 : nStacks
    if   ismember(BranchID,SegmentsAll{s}) && sum(isnan(reshape(DataOriginal{s}(BranchID,:,:),1,[]))) < 0.7*length(reshape(DataOriginal{s}(BranchID,:,:),1,[]))
        
        CounterStacks = CounterStacks +1;
        % below I use reshape to eliminate the 3rd dimension. If use
        % squeeze, when there is only 1 trial it messes up
        Data{CounterStacks} = reshape (DataOriginal{s}(BranchID,:,:), size(DataOriginal{s}(BranchID,:,:),2), size(DataOriginal{s}(BranchID,:,:),3));
        Time{CounterStacks} = reshape (TimeOriginal{s}(BranchID,:,:), size(TimeOriginal{s}(BranchID,:,:),2), size(TimeOriginal{s}(BranchID,:,:),3));
        TimePoints(CounterStacks) = size(DataOriginal{s},3);
        
    end
end

% interpolate and concatenate data
StacksConcat = [];
NewTimes = [];

if CounterStacks > 0
    
    NumberTimePoints= min(TimePoints);
    TimeRes = Times(1,1,end)/NumberTimePoints;
    NewTimes = 0 : TimeRes : Times(1,1,end);
    
    for s = 1 : CounterStacks
        
        % interpolate so all stacks have the same temporal scale and concatenate trials
        [ DataInt ] = InterpolateAllTrials(Time{s}, Data{s}, NewTimes);
        
        %concatenate all the stacks
        StacksConcat = [ StacksConcat; DataInt];
        
    end
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

function PlotAllTrials(StacksConcat, TimesConcat, Title, FlagSave)

TimeRes = mean(diff(TimesConcat));

% plot activity in all trials
if isempty(StacksConcat) == 0
    
    % plot all trials
    figure;
    imagesc(StacksConcat); colormap(flipud(gray))
    title(Title)
    xlabel(['Time, timepoints, 1 timepoint = ' num2str(TimeRes) ' ms'])
    ylabel('Trial Number')
    
    % plot mean activity
    MeanAll = nanmean(StacksConcat,1);
    
    figure;
    plot(TimesConcat,MeanAll);
    title(Title)
    xlabel('Time, seconds')
    ylabel('Mean Number of branches active')
    
    if FlagSave
        saveas(gcf-1, [Title 'ActivityAllStacks Binarized.fig'] )
        saveas(gcf, [Title 'MeanActivityInTrial Binarized.fig'] )
    end
end
end
