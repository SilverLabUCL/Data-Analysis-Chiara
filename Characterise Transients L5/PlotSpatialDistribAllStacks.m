function [ VarToPlotAll, FilesLoaded] = PlotSpatialDistribAllStacks( nStacks, FlagSave, FilesLoaded)
% Plot histogram for several stacks of spatial distribution of calcium events, generated
% with code CharacteriseTransients4

%% initialise stuff
VarToPlotAll = [];
counter = 1;

if nargin < 2
    FlagSave = 1;
end

%% load data
for s = 1:nStacks
    
    % select mat file with Characterised transients information
    if nargin < 3
        [FileName, PathName]=uigetfile('*.mat',['Select the file with the data for stack number ' num2str(s)]);
        FilesLoaded{s}=[PathName FileName];
    end
    
    % load data
    load(FilesLoaded{s},'ResponsesDistPerc','TransientsChar','Segments')
    if length(Segments) > 4
        % save info about spatial distributino
        VarToPlotAll(counter : counter + length(ResponsesDistPerc)-1 ) = ResponsesDistPerc;
        counter = counter + length(ResponsesDistPerc);
    end
    clear ResponsesDistPerc TransientsChar
end

%% plot

% set number of bins in histogram
n_bins = 10;

figure;
hist(VarToPlotAll,n_bins)
title('Spatial Distribution')
xlabel('% of branches'), ylabel('Number of events')
box off; axis tight

%% save

if FlagSave
    
    saveas(gcf,['SpatialDistribution  from ' num2str(nStacks) 'stacks ' date])
    save(['Spatial distribution ' date ' .mat'])
end


end

