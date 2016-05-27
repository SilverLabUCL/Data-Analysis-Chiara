function [ VarToPlotAll, FilesLoaded] = PlotSpatialDistribAllStacksDiffSpikes( nStacks, FlagSave, FilesLoaded)
% Plot histogram for several stacks of spatial distribution of calcium events, generated
% with code CharacteriseTransients4

% compared to PlotSpatialDistribAllStacks, plots separately distribution of
% all spikes, of only bAPs and then only dendritic spikes. First need to
% separate bAPS from dendritic spikes with code RunIsolateDendriticSpikes

%% initialise stuff
VarToPlotAll = [];
counter = 1;
counter2 = 1;
counter3 = 1;

if nargin < 2
    FlagSave = 1;
end

%% load data
for s = 1:nStacks
    
    % select mat file with transients information
    if nargin < 3
        [FileName, PathName]=uigetfile('*.mat',['Select the file with the data for stack number ' num2str(s)]);
        FilesLoaded{s}=[PathName FileName];
    end
    
    % load data
    load(FilesLoaded{s},'ResponsesDistPercAll','ResponsesDistPercdSpike','ResponsesDistPercbAP','TransientsChar','Segments')
    if length(Segments) > 5 % limit at 5 branches, but assume always image soma
        % save info about spatial distribution
        VarToPlotAll(counter : counter + length(ResponsesDistPercAll)-1 ) = ResponsesDistPercAll;
        VarToPlotdSpike(counter2 : counter2 + length(ResponsesDistPercdSpike)-1 ) = ResponsesDistPercdSpike;
        VarToPlotbAP(counter3 : counter3 + length( ResponsesDistPercbAP)-1 ) = ResponsesDistPercbAP;
        counter = counter + length(ResponsesDistPercAll);
        counter2 = counter2 + length(ResponsesDistPercdSpike);
        counter3 = counter3 + length(ResponsesDistPercbAP);
    end
    clear ResponsesDistPercAll ResponsesDistPercdSpike ResponsesDistPercbAP TransientsChar
end

%% plot

% set number of bins in histogram
n_bins = 10;

%YMax = max([VarToPlotAll VarToPlotdSpike VarToPlotbAP]);

figure;
hist(VarToPlotAll,n_bins)
title('Spatial Distribution all spikes')
axis tight; box off; 
xlim([-10 110])
%ylim([0 YMax])
xlabel('% of branches'), ylabel('Number of events')

figure;
hist(VarToPlotdSpike,n_bins)
title('Spatial Distribution dendritic spikes')
axis tight; box off; 
xlim([-10 110])
%ylim([0 YMax])
xlabel('% of branches'), ylabel('Number of events')

figure;
hist(VarToPlotbAP,n_bins)
title('Spatial Distribution bAPs')
axis tight; box off; 
xlim([-10 110])
%ylim([0 YMax])
xlabel('% of branches'), ylabel('Number of events')

%% save

if FlagSave
    
    saveas(gcf,['SpatialDistribution bAPs from ' num2str(nStacks) 'stacks ' date])
    saveas(gcf-1,['SpatialDistribution dSpikes from ' num2str(nStacks) 'stacks ' date])
    saveas(gcf-2,['SpatialDistribution All from ' num2str(nStacks) 'stacks ' date])
    save(['Spatial distribution ' date ' .mat'])
end


end

