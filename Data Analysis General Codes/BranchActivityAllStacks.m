function [ AllStacksConcat, TimeAllStacks ] = BranchActivityAllStacks( nStacks, FlagSpikeType, FlagSave, FilesLoaded )
%This code loads the data with the activity of a branch in each stack, concatenates all stacks and
%plot activity in each trial.
%Useful to have an idea of dendritic activity and if dendrite responds to visual stimulation, like figure in roscoff conference poster done with population data

% same code as TuftActivityAllStacks, but instead of averaging activity of
% all branches, here it works on the activity of only one branch

%% beginning stuff

if nargin < 4
    FilesLoaded = cell(nStacks,1);
end

if nargin < 3
    FlagSave = true;
end

if nargin < 2
    FlagSpikeType = 0; % if equal zero, analyses df/f data
end

% initialise stuff
Data = cell(nStacks,1);
Time = cell(nStacks,1);

if isempty(FilesLoaded) == 1
    FlagLoad = 1;
else
    FlagLoad = 0;
end

%% load data
for st =1 : nStacks
    
    if FlagLoad
        [filename,pathname] = uigetfile('*.mat'); %the user needs to load a file that contains a matrix DeltaFoverF_Sm(cell,trial,time)
        FilesLoaded{st} = [pathname filename];
    end
    
    if FlagSpikeType == 0 % analyses Df/f data
        load(FilesLoaded{st},'DeltaFoverF_Sm','TimesSegment')
        Data{st} = DeltaFoverF_Sm;
    elseif FlagSpikeType == 1 % analyses Df/f data but only detected responses from code DfoFSeparateSpikes
        load(FilesLoaded{st},'DfoFAll','TimesSegment')
        Data{st} = DfoFAll;
    elseif FlagSpikeType == 2 % analyses bAPs only from code DfoFSeparateSpikes
        load(FilesLoaded{st},'DfoFBAPS','TimesSegment')
        Data{st} = DfoFBAPS;
    elseif FlagSpikeType == 3 % analyses dendritic spikes only, from code DfoFSeparateSpikes
        load(FilesLoaded{st},'DfoFDSpikes','TimesSegment')
        Data{st} = DfoFDSpikes;
    end
    
    Time{st} = TimesSegment;
    
end

%% does all the work branch by branch

AllStacksConcat = cell(size(Data{st},1),1);

for Br = 1 : size(Data{st},1)
    [ AllStacksConcat{Br}, TimeAllStacks ] = CalculateForOneBranch( Br, Data, Time, FlagSave );
end

save('FilesLoaded.mat','FilesLoaded')

end

function [ AllStacksConcat, TimeAllStacks ] = CalculateForOneBranch( BranchID, DataOriginal, TimeOriginal, FlagSave )


CounterStacks = 1;
nStacks = length(DataOriginal);

%% keep only stacks that have recordings for the requested branch

for st =1 : nStacks
    
    if  sum(isnan(reshape(DataOriginal{st}(BranchID,:,:),1,[]))) < 0.75*length(reshape(DataOriginal{st}(BranchID,:,:),1,[]))
        
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
    
    TimeAllStacks = Time{SmallerStack}(1,:);
    TimeRes = Time{SmallerStack}(1,end)/NumberTimePoints;
    
    %% plot
    
    % plot activity in all trials
    figure;
    imagesc(AllStacksConcat); colorbar
    title(['Branch ' num2str(BranchID) ' Time resolution is ' num2str(TimeRes) ' ms' ])
    xlabel('Time, timepoints')
    ylabel('Df/f')
    
    % plot mean of activity across all trials
    MeanAll = nanmean(AllStacksConcat,1);
    
    figure;
    plot(TimeAllStacks,MeanAll);
    title(['Branch ' num2str(BranchID) 'Mean Activity across all trials'])
    xlabel('Time, seconds')
    ylabel('Df/f')
    %% save
    
    if FlagSave == 1
        
        save(['Branch ' num2str(BranchID) ' ActivityAllStacks ' date '.mat'])
        saveas(gcf-1, ['Branch ' num2str(BranchID) ' ActivityAllStacks.fig'] )
        saveas(gcf, ['Branch ' num2str(BranchID) ' MeanActivityInTrial.fig'] )
        
    end
    
    
    
    
    
else %if there is no stack with data for the selected branch
    
    AllStacksConcat = NaN;
    TimeAllStacks = NaN;
    
    if FlagSave == 1
        save(['Branch ' num2str(BranchID) ' ActivityAllStacks ' date '.mat'])
    end
end

end



