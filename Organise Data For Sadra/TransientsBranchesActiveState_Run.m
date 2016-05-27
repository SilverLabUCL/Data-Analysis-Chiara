
function [ CaTransients ] = TransientsBranchesActiveState_Run( FilesLoaded, MouseID, RegionID, CellID, VisStim )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

CaTransients = [];

for stack = 1:length(FilesLoaded)
    [ CaTransientsOneStack ] = TransientsBranchesActiveState( FilesLoaded{stack,1} );
    CaTransients = [CaTransients CaTransientsOneStack];
end

PathFolder = FilesLoaded{1,1}(1: find(FilesLoaded{1,1} == '\', 1,'last') );
load([PathFolder 'PlotBranchesActive.mat'],'SortedTree','NodesInfo')

for resp = 1:length(CaTransients)
    CaTransients(resp).MouseID = MouseID;
    CaTransients(resp).RegionID = RegionID;
    CaTransients(resp).CellID = CellID;
    CaTransients(resp).VisStim = VisStim;
    CaTransients(resp).AdMatrix = SortedTree.dA;
    CaTransients(resp).NodesInfo = NodesInfo;
end

end

