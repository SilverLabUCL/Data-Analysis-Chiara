function DataToSadraL2(FileNameSave,  FilesLoaded)
% pull together data for Sadra on branch coactivation, needs output of code
% IsolateDendSpike because considers bAPs and dendritic spikes separately,

% the original code DataToSadra is for L5 neurons, or at least it doesn't
% separate bAPs and dendritic spikes, but considers all detected calcium
% events
%

if nargin < 2
    nStacks = input('How many stacks do you want to analyse?');
else
    nStacks = length(FilesLoaded);
end

BranchesCoActivebAP = []; % data for bAPs
BranchesCoActiveDSpike = []; % data for dendritic spikes
counterBAP = 1;
counterDSP = 1;

for s = 1:nStacks
    
    if nargin < 2
        [FileName,PathName] = uigetfile('*.mat','Select IsolateDendSpike.mat');
        FilesLoaded{s} = [PathName FileName];
    else
        PathName = FilesLoaded{s}( 1:find(FilesLoaded{s} == '\', 1, 'last') );
        FileName = 'IsolateDendSpike.mat';
    end
    
    load([PathName FileName], 'BranchesActiveDSPIKE',  'BranchesActivebAPs', 'Segments')
    BranchesCoActivebAP = [BranchesCoActivebAP; BranchesActivebAPs];
    BranchesCoActiveDSpike = [BranchesCoActiveDSpike; BranchesActiveDSPIKE];
    
    for Resp = 1:length(BranchesActivebAPs)
        ImagedBranchesbAP{Resp + counterBAP-1,1} = Segments';
    end
    counterBAP = counterBAP + length(BranchesActivebAPs);
    
    for Resp = 1:length(BranchesActiveDSPIKE)
        ImagedBranchesDSpike{Resp + counterDSP-1,1} = Segments';
    end
    counterDSP = counterDSP + length(BranchesActiveDSPIKE);
    
    if s == 1
        FileNameTree = 'DfoFSeparateSpikes.mat';
        load([PathName FileNameTree], 'SortedTree', 'NodesInfo')
    end
end

AdMatrix = SortedTree.dA;
save( FileNameSave, 'BranchesCoActivebAP', 'BranchesCoActiveDSpike', 'AdMatrix', 'SortedTree',  'NodesInfo', 'ImagedBranchesbAP', 'ImagedBranchesDSpike', 'FilesLoaded')

end

