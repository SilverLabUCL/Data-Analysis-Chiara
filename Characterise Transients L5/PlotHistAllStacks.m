function [ VarToPlotAll, FilesLoaded] = PlotHistAllStacks( nStacks, VarToPlot, FilesLoaded )
% Plot histogram for several stacks of a parameter "VarToPlot", generated
% with code CharacteriseTransients4

% careful if you want to plot spatial distribution of calcium events,
% because with this code events that occur in n branches will be counted n
% times. Better to use code PlotSpatialDistribAllStacks

%% initialise stuff
TransientsCharAll = cell(1,nStacks);

VarToPlotAll = [];
counter = 1;

%% load data
for s = 1:nStacks
    
    % select mat file with Characterised transients information
    if nargin < 3
        [FileName, PathName]=uigetfile('*.mat',['Select the file with the data for stack number ' num2str(s)]);
        FilesLoaded{s}=[PathName FileName];
    end
    
    % load data
    load(FilesLoaded{s},'TransientsChar')
    TransientsCharAll{s} = TransientsChar;
    
    % extract VarToPlot
    for seg = 1 : length(TransientsChar)
        
        expression = [ 'TransientsChar(1,' num2str(seg) ').' VarToPlot];
        if isempty(eval(expression)) == 0
            VarToPlotAll(counter : counter + length(eval(expression))-1 ) = eval(expression);
            counter = counter + length(eval(expression));
        end
    end
    
end

%% plot

% set number of bins in histogram
if strcmp(VarToPlot,'Amplitude') == 1 % if plotting amplitude, set the size of each bin to 2 Df/f
    n_bins = round(max(VarToPlotAll)/2);
else
    n_bins = round(length(VarToPlotAll)/3); % otherwise set it to a default
end

figure;
hist(VarToPlotAll,n_bins)
title(['Distribution of ' VarToPlot 's'])
xlabel(VarToPlot), ylabel('Number of events')
box off; axis tight

end

