function [ SpatialDistribAll, FilesLoaded ] = PlotSpatialDistributionAllCells( nCells, FlagSave, FilesLoaded )
% Plot histogram for several cells of spatial distribution of calcium events, generated
% with code PlotSpatialDistribAllStacks for each cell, and with the code
% CharacteriseTransients4 for each stack

%% initialise stuff
SpatialDistribAll = [];
counter = 1;

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
    
    % save info about spatial distributino
    SpatialDistribAll(counter : counter + length(VarToPlotAll)-1 ) = VarToPlotAll;
    counter = counter + length(VarToPlotAll);
    
    clear VarToPlotAll
end

%% plot

% set number of bins in histogram
n_bins = 10;

figure;
hist(SpatialDistribAll,n_bins)
title(['Spatial Distribution from ' num2str(nCells) ' cells'])
xlabel('% of branches'), ylabel('Number of events')
box off; axis tight

%% save

if FlagSave
    
    saveas(gcf,['SpatialDistribution  from ' num2str( nCells) 'cells ' date])
    save(['SpatialDistribution from ' num2str( nCells) 'cells ' date ' .mat'])
end



end

