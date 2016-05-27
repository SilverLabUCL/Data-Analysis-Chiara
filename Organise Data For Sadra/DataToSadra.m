function [ BranchesCoActive ] = DataToSadra(FileNameSave,  FilesLoaded)
% pull together data for Sadra on branch coactivation

if nargin < 2
    nStacks = input('How many stacks do you want to analyse?');
else
    nStacks = length(FilesLoaded);
end

BranchesCoActiveAll = [];
counter = 1;

for s = 1:nStacks
    
    if nargin < 2
        [FileName,PathName] = uigetfile('*.mat','Select PlotBranchesActive.mat');
        FilesLoaded{s,1} = [PathName FileName];
    else
        PathName = FilesLoaded{s,1}( 1:find(FilesLoaded{s,1} == '\', 1, 'last') );
        FileName = 'PlotBranchesActive.mat';
    end
    
    load([PathName FileName], 'BranchesCoActive', 'Segments')
    BranchesCoActiveAll = [BranchesCoActiveAll; BranchesCoActive];
    
    for Resp = 1:length(BranchesCoActive)
        ImagedBranches{Resp + counter-1,1} = Segments';
    end
    
    counter = counter + length(BranchesCoActive);
    
    if s == 1
        load([PathName FileName], 'SortedTree', 'NodesInfo')
    end
end

BranchesCoActive = BranchesCoActiveAll;
AdMatrix = SortedTree.dA;
save( FileNameSave, 'BranchesCoActive', 'AdMatrix', 'SortedTree',  'NodesInfo', 'ImagedBranches', 'FilesLoaded')

end

