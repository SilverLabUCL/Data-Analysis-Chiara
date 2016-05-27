function [ SpatialDistribAll, FilesLoaded ] = PlotSpatialDistributionAllCells2( nCells, FlagSave, FilesLoaded )
% Plot histogram for several cells of spatial distribution of calcium events, generated
% with code PlotSpatialDistribAllStacks for each cell, and with the code
% CharacteriseTransients4 for each stack

% compare to version 1, it also normalizes the number of events in each
% cell, and plot mean and std dev

%% initialise stuff
BinCenters = [10 20 30 40 50 60 70 80 90 100];
n_bins = length(BinCenters); % set the bins in histogram, depends on number of imaged branches
SpatialDistribAll = [];
counter = 1;
PercentEvents = zeros(nCells, n_bins);

if nargin < 2
    FlagSave = 1;
end

%% load data
for s = 1:nCells
    
    % select mat file with sptial distribution information for each cell
    if nargin < 3
        [FileName, PathName]=uigetfile('*.mat',['Select the file with the data for cell number ' num2str(s)]);
        FilesLoaded{s}=[PathName FileName];
    end
    
    % load data
    load(FilesLoaded{s},'VarToPlotAll')
    %VarToPlotAll = VarToPlotdSpike;
    
    % save info about spatial distributino
    SpatialDistribAll(counter : counter + length(VarToPlotAll)-1 ) = VarToPlotAll;
    counter = counter + length(VarToPlotAll);
    
    % calculate % of events 
    PercentEvents(s,1:n_bins) = hist(VarToPlotAll,BinCenters)/length(VarToPlotAll)*100;
    
    clear VarToPlotAll
end

%% plot

%plot histogram with all events from all cells added up
figure;
hist(SpatialDistribAll,BinCenters)
title(['Spatial Distribution from ' num2str(nCells) ' cells'])
xlabel('% of branches'), ylabel('Number of events')
box off; 

%plot mean distribution across cells
MeanDistrib = median(PercentEvents, 1);  % calculate mean and error
SEM = std(PercentEvents,1)./sqrt(nCells);

figure;
bar(MeanDistrib)
hold on; 
errorbar(MeanDistrib, SEM,'k.')
title(['Spatial Distribution from ' num2str(nCells) ' cells'])
xlabel('% of branches'), ylabel('% of events')
box off; 

%plot bar graph for all cells
[~, order] = sort(PercentEvents(:,1),'descend'); % order matrix so it looks nicer
sortedCells = PercentEvents(order,:);
figure; bar(sortedCells')
xlabel('% of branches'), ylabel('% of events')
box off; 

%% save

if FlagSave
    
    %save figures
    saveas(gcf, ['SpatialDistribution  AllCells from ' num2str( nCells) 'cells ' date])
    saveas(gcf-1, ['SpatialDistribution %Events from ' num2str( nCells) 'cells ' date])
    saveas(gcf-2, ['SpatialDistribution  from ' num2str( nCells) 'cells ' date])
    
    % save data
    save(['SpatialDistribution from ' num2str( nCells) 'cells ' date ' .mat'])
end



end

