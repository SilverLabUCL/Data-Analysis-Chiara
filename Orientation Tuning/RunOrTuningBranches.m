function RunOrTuningBranches(n_branches, Path, MatFileName, TreeFile)
% run orientation tuning for each branch after having run code
% BranchActivityAllStacks that reorganizes the data.

% Path and MatFileName are description of where the data from code BranchActivityAllStacks is

OrientationCurves = NaN(n_branches, 8);
Sem = NaN(n_branches, 8);
for i= 1 : n_branches
    
    FileName = [ Path '\Branch ' num2str(i) ' ' MatFileName];
    FileName2 = [ Path '\Branch ' num2str(i) ' ActivityAllStacks.fig'];
    FileName3 = [ Path '\Branch ' num2str(i) ' MeanActivityInTrial.fig'];
    load(FileName, 'AllStacksConcat','TimeAllStacks')
    
    
    % create a folder for each branch
    FolderName = [ 'Branch' num2str(i)];
    mkdir(FolderName)
    if exist(FileName,'file') == 2
        movefile(FileName,FolderName)
    end
    if exist(FileName2,'file') == 2
        movefile(FileName2,FolderName)
    end
    if exist(FileName3,'file') == 2
        movefile(FileName3,FolderName)
    end
    cd(FolderName)
    
    % compute orientation tuning for each branch
    AllStacksConcat_Lin = reshape(AllStacksConcat,1,[]);
    if sum(isnan(AllStacksConcat_Lin)) < length(AllStacksConcat_Lin)*0.9
        [ OrientationCurves(i, :), Sem(i,:), ~ ] = OrTuning( AllStacksConcat, TimeAllStacks, 1, 1);
    end
    cd ..
    
    close all
    
end

% save curves of each branch
save('OrTuning.mat','OrientationCurves','Sem')

% compute OSI and plot tree with preferred orientation
OSIhistograms( OrientationCurves );
close all;
PlotOrientTuningDendriticArborL2(TreeFile);

end

