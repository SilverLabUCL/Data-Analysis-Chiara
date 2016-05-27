function [ SpatialDistribAllCellsStat, SpatialDistribAllCellsRun, FilesLoaded ] = PlotSpatialDistributionAllCellsRunStat( nCells, FlagSave, FilesLoaded )
% Plot histogram for several cells of spatial distribution of calcium events, generated
% with code PlotSpatialDistribAllStacks for each cell, and with the code
% CharacteriseTransients4 for each stack

%% initialise stuff
SpatialDistribAllCellsStat = [];
SpatialDistribAllCellsRun = [];
counter = 1;
counter2 = 1;

if nargin < 2
    FlagSave = 1;
end

%% load data
for s = 1:nCells
    
    % select mat file with spatial distribution information for each cell
    if nargin < 3
        [FileName, PathName]=uigetfile('*.mat',['Select the file with the data for cell number ' num2str(s)]);
        FilesLoaded{s}=[PathName FileName];
    end
    
    % load data
    load(FilesLoaded{s},'SpatialDistribStatAll', 'SpatialDistribRunAll')
    
    % save info about spatial distributino
    SpatialDistribAllCellsStat(counter : counter + length(SpatialDistribStatAll)-1 ) = SpatialDistribStatAll;
    counter = counter + length(SpatialDistribStatAll);
    
    SpatialDistribAllCellsRun(counter2 : counter2 + length(SpatialDistribRunAll)-1 ) = SpatialDistribRunAll;
    counter2 = counter2 + length(SpatialDistribRunAll);
    
    clear SpatialDistribStatAll SpatialDistribRunAll
end

%% plot

% set number of bins in histogram
n_bins = 10;

figure;
hist(SpatialDistribAllCellsStat,n_bins)
title(['Spatial Distribution Stationary. Number of cells: ' num2str(nCells)])
xlabel('% of branches'), ylabel('Number of events')
box off; axis tight

figure;
hist(SpatialDistribAllCellsRun,n_bins)
title(['Spatial Distribution Running. Number of cells: ' num2str(nCells)])
xlabel('% of branches'), ylabel('Number of events')
box off; axis tight


%% save

if FlagSave
    
    saveas(gcf,['SpatialDistribution Run  from ' num2str( nCells) 'cells ' date])
    saveas(gcf-1,['SpatialDistribution Stat  from ' num2str( nCells) 'cells ' date])
    save(['SpatialDistribution RunStat  from ' num2str( nCells) 'cells ' date ' .mat'])
end



end

