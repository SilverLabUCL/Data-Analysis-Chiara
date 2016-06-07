function [ MinDist ] = MeasureMinDistanceBranches( Stack, Plane , Tree )
% measures the average minimum distance between dendritic branches in an
% image
% first chooses 10 random points in the dendrites of imaged neuron, then
% finds closest branch for each point

% info for tree
[~, BranchesInfo] = dissect_tree(Tree);

% filter and apply threshold to image
ImageFilt = FilterImage(Stack{Plane});

% find x and y coordinates of fluorescent points in the image
[YTemp, XFluo] = find(ImageFilt); % find ones
YFluo = size(ImageFilt,1) - YTemp; % reverse y axis
FluoCoor = [XFluo YFluo];

% select 10 random points (POIs) in the dendritic tree
NodesPlane = find(round(Tree.Z) == Plane);
POIs = NodesPlane( round(1+ length(NodesPlane)*rand(10,1)) );

% for each POI, find fluorescent points that are in the same branch
FluoInBranch = zeros(length(POIs), length(FluoCoor)); % for each POI, there is a vector saying if a fluorescent point is in the same branch

for p = 1:length(POIs)
    Branch = BranchesInfo(POIs(p));
    FluoInBranch(p, :) = PointsInBranch(Tree, Branch, BranchesInfo, FluoCoor, Plane);
end

% compute distance between points and dendrites


% find minimum distance for each point




end

