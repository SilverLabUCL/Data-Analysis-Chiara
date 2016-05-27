%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters

% number of stacks to analyse
nStacks = 4;

% Files to load, leave empty if want to choose files manually. Will have to
% choose Df/f mat file, or DfoFSeparateSpikes, depending on which data you
% want to analyse
%FilesLoaded = [];

% which data to analyse: 0 Df/f, 1 All spikes only detected responses, 2 bAPs, 3 dendritic spikes
FlagSpikeType = [2 3];

% where you want to save the data
Path{1} = 'C:\Data Analysis\Veronica\27 November 2014\Cell 2 Or Tuning bAPs 4 6 s';
Path{2} = 'C:\Data Analysis\Veronica\27 November 2014\Cell 2 Or Tuning dSpikes 4 6 s';

% dendritic tree that you want to use to plot preferred orientation etc
TreeFile = 'C:\Data Analysis\Veronica\27 November 2014\Cell 2 tree nice.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reorganizes branches activity

for sp = 1:length(FlagSpikeType)
    
    mkdir(Path{sp})
    cd(Path{sp})
    [ AllStacksConcat, ~ ] = BranchActivityAllStacks( nStacks, FlagSpikeType(sp), 1, FilesLoaded );
    close all;
    
    % run orientation tuning
    MatFileName = ['ActivityAllStacks ' date '.mat'];
    n_branches = length(AllStacksConcat);
    RunOrTuningBranches(n_branches, Path{sp}, MatFileName, TreeFile);
end


