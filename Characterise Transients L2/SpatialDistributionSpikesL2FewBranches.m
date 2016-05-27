function [DistributionAllEvents] = SpatialDistributionSpikesL2FewBranches(Branches, FilesLoaded, FlagSave)

OriginalFolder = pwd;
DistributionAllEvents = [];

for ff = 1:length(FilesLoaded)
    
    % find folder with data
    Slash = find(FilesLoaded{ff} == '\',1,'last');
    Folder = FilesLoaded{ff}(1:Slash);
    cd(Folder)
    
    % load data
    load('CharacteriseTransients.mat', 'ResponsesBin','TransientsChar','Segments')
    
    % find distribution of spikes
    BranchesImaged = Branches(ismember(Branches,Segments));
    if length(BranchesImaged) > 4
        [~, ResponsesDistPerc] = SpatialDistributionSpikesL2(  ResponsesBin(Branches,:), BranchesImaged, TransientsChar, false );
    else
        ResponsesDistPerc = [];
    end
    
    DistributionAllEvents = [DistributionAllEvents ResponsesDistPerc];
    
end

cd(OriginalFolder)

if isempty(DistributionAllEvents) == 0
    figure;
    hist(DistributionAllEvents,10)
    xlim([0 110])
    xlabel('% of branches co-active'), ylabel('Number of events')
    title(['Spatial distribution considering only tuft branches: ' num2str(Branches)])
    
    if FlagSave
        saveas(gcf,['SpatialDistribution AllEvents FewBranches ' date])
        Date = date;
        save('SpatialDistrib FewBranches.mat')
    end
    
else
    disp('Not enough branches imaged to compute spatial spread of transients')
end

end