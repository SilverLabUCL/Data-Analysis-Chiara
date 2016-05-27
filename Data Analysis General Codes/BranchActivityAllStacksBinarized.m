function [ AllStacksConcat, TimeAllStacks ] = BranchActivityAllStacksBinarized( nStacks, FlagSave, FilesLoaded )
%This code loads the data with the activity of a branch in each stack, binarizes the responses using the event detection algorithms in the CharacterizeTransients code, and concatenates all stacks and
%plot activity in each trial.
%Useful to have an idea of dendritic activity and if dendrite responds to visual stimulation, like figure in roscoff conference poster done with population data

% from code as BranchActivityAllStacks, but here "binary" responses, so
% doesn't consider amplitudes of events but only if branches are on or off

%% beginning stuff

if nargin < 3
    FilesLoaded = cell(nStacks,1);
end

if nargin < 2
    FlagSave = true;
end

% initialise stuff
Data = cell(nStacks,1);
Time = cell(nStacks,1);
SegmentsAll = cell(nStacks,1);

%% load data
for st =1 : nStacks
    
    if nargin < 3
        [filename,pathname] = uigetfile('*.mat'); %the user needs to load a file that contains a contains a structure TransientChar with info about detected events
        FilesLoaded{st} = [pathname filename];
    end
    load(FilesLoaded{st},'TransientsChar','DeltaFoverF_Sm_Lin','Times_Lin', 'TimeRes','Times','FileLoaded','Segments','TimeRes')
    load(FileLoaded,'TimesSegment')
    
    n_trials = size(Times,1);
    n_timepoints = size(Times,3);
    n_segments = size(TimesSegment,1);
    
    % Create binarized responses using info of onset and duration of each
    % TransientsChar
    [ResponsesBin] = CreateBinarizedResponses( TransientsChar, Times_Lin, TimeRes, n_trials, n_timepoints, Segments);
    
    % ResponsesBin has all trials concatenated, divide trials again
    [ResponsesBinT] = DivideConcatenatedTrials(n_trials, n_timepoints, ResponsesBin);
    
    % remove segments full of NaNs
    for seg = 1 : length(Segments)
        if sum(isnan(DeltaFoverF_Sm_Lin(Segments(seg)))) > 0.75*length(DeltaFoverF_Sm_Lin(Segments(seg)))
            ResponsesBinT(Segments(seg),:,:) = NaN;
            TimesSegment(Segments(seg),:,:) = NaN;
        end
    end
    
    Data{st} = ResponsesBinT;
    Time{st} = TimesSegment;
    SegmentsAll{st} = Segments;
end

%% concatenate stacks and plot branch by branch

AllStacksConcat = cell(size(TimesSegment,1),1);

for Seg = 1 : size(TimesSegment,1)
    [ AllStacksConcat{Seg}, TimeAllStacks ] = CalculateForOneBranch( Seg, Data, Time, SegmentsAll, FlagSave, FilesLoaded );
end



end

function [ResponsesBin] = CreateBinarizedResponses( TransientsChar, Times_Lin, TimeRes, n_trials, n_timepoints, Segments)

ResponsesBin = NaN( length(Segments), n_trials*n_timepoints );

for seg = 1 : length(Segments)
    
    n_events = length(TransientsChar(1,Segments(seg)).PosMax);
    ResponsesBin(Segments(seg), :) = 0;
    
    for e = 1:n_events
        % if onset and duration are not NaN
        if isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 0 && isnan( TransientsChar(1,Segments(seg)).Duration(e) ) == 0
            Onset = find(Times_Lin(Segments(seg), :) == TransientsChar(1,Segments(seg)).OnsetApprox(e)*1e3);
            End = Onset + round(TransientsChar(1,Segments(seg)).Duration(e)*1e3/TimeRes);
            % if only duration is NaN, assume that duration was not found
            % because the event occurred at the end of the recording
        elseif isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 0 && isnan( TransientsChar(1,Segments(seg)).Duration(e) ) == 1
            Onset = find(Times_Lin(Segments(seg), :) == TransientsChar(1,Segments(seg)).OnsetApprox(e)*1e3);
            End = n_trials*n_timepoints;
            % if onset is NaN, take PosMax and a few elements before and after (not very precise...)
        elseif isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 1
            Onset = TransientsChar(1,Segments(seg)).PosMax(e) ;
            End = TransientsChar(1,Segments(seg)).PosMax(e) ;
        end
        
        try
            ResponsesBin(Segments(seg), Onset : End ) = 1;
        catch
            disp(['ERROR Skipped Response ' num2str(e) ' of branch ' num2str(Segments(seg))])
        end
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



function [ AllStacksConcat, TimeAllStacks ] = CalculateForOneBranch( BranchID, DataOriginal, TimeOriginal, SegmentsAll, FlagSave, FilesLoaded )


CounterStacks = 1;
nStacks = length(DataOriginal);

%% keep only stacks that have recordings for the requested branch

for st =1 : nStacks
    
    if   ismember(BranchID,SegmentsAll{st}) && sum(isnan(reshape(DataOriginal{st}(BranchID,:,:),1,[]))) < 0.7*length( reshape(DataOriginal{st}(BranchID,:,:),1,[]) )
        
        Data{CounterStacks} = squeeze(DataOriginal{st}(BranchID,:,:));
        Time{CounterStacks} = squeeze(TimeOriginal{st}(BranchID,:,:));
        TimePoints(CounterStacks) = size(DataOriginal{st},3);
        
        CounterStacks = CounterStacks +1;
    end
end

CounterStacks = CounterStacks -1;

if CounterStacks > 0 %if there is at least one stack with data for the selected branch
    
    %% interpolate data so all stacks have the same temporal scale
    
    [NumberTimePoints , SmallerStack]= min(TimePoints);
    NumberTrials = size(DataOriginal{1},2);
    DataInt = zeros( CounterStacks, NumberTrials, NumberTimePoints);
    AllStacksConcat = [];
    
    for st = 1 : CounterStacks
        for tr = 1 : NumberTrials
            
            %interpolate
            DataInt(st, tr, 1:NumberTimePoints) = interp1( Time{st}(tr,:), Data{st}(tr,:), Time{SmallerStack}(tr,:));
            
        end
        
        %concatenate all the stacks
        AllStacksConcat = [ AllStacksConcat; squeeze(DataInt(st,:,:))];
    end
    
    AllStacksConcat = ceil(AllStacksConcat);
    TimeAllStacks = Time{SmallerStack}(1,:);
    TimeRes = Time{SmallerStack}(1,end)/NumberTimePoints;
    
    %% plot
    
    % plot activity in all trials
    figure;
    imagesc(AllStacksConcat); colormap(flipud(gray))
    title(['Branch ' num2str(BranchID) ' Time resolution is ' num2str(TimeRes) ' ms' ])
    xlabel('Time, timepoints')
    ylabel('Trial Number')
    
    % plot activity across all trials
    SumAll = nansum(AllStacksConcat,1);
    
    figure;
    plot(TimeAllStacks,SumAll);
    title(['Branch ' num2str(BranchID) 'Total number of events across all trials'])
    xlabel('Time, seconds')
    ylabel('Number of events')
    %% save
    
    if FlagSave == 1
        
        save(['Branch ' num2str(BranchID) ' ActivityAllStacks ' date '.mat'])
        saveas(gcf-1, ['Branch ' num2str(BranchID) ' ActivityAllStacks.fig'] )
        saveas(gcf, ['Branch ' num2str(BranchID) ' ActivityInTrial.fig'] )
        
    end
    
    
    
    
    
else %if there is no stack with data for the selected branch
    
    AllStacksConcat = NaN;
    TimeAllStacks = NaN;
    
    if FlagSave == 1
        save(['Branch ' num2str(BranchID) ' ActivityAllStacks ' date '.mat'])
    end
end

end



