function [ MinDist, MeanDist, Distance, RatioSpace ] = MeasureMinDistanceBranches( Stack, Plane, Tree, FlagPlot, Radius )
% measures the average minimum distance between dendritic branches in an
% image
% first chooses some random points in the dendrites of imaged neuron, then
% finds closest branch for each point

% size of the field of view in microns
FOV = 220;

% info for tree
[~, BranchesInfo] = dissect_tree(Tree);

% filter and apply threshold to image
ImageFilt = FilterImage(Stack{Plane}, 5, FlagPlot);

% find x and y coordinates of fluorescent points in the image
[YTemp, XFluo] = find(ImageFilt); % find ones
YFluo = size(ImageFilt,1) - YTemp; % reverse y axis
FluoCoor = [XFluo YFluo];

% select random points (POIs) in the dendritic tree
NodesPlane = find(round(Tree.Z) == Plane);
n_POIs = round(length(NodesPlane)*0.6); % select a bit more than half of points in branch
POIs = NodesPlane( round(1+ (length(NodesPlane)-1)*rand(n_POIs,1)) );
% remove branching points
BranchingPoints = find( B_tree(Tree) == 1);
Empty = find( ismember(POIs, BranchingPoints) == 1);
POIs(Empty) = [];
n_POIs = size(POIs, 1);

% for each POI, find fluorescent points that are in the same branch
FluoInBranch = zeros(n_POIs, length(FluoCoor)); % for each POI, there is a vector saying if a fluorescent point is in the same branch

for p = 1:n_POIs
    Branch = BranchesInfo(POIs(p), 1);
    FluoInBranch(p, :) = PointsInBranch(Tree, Branch, BranchesInfo, FluoCoor, Plane, FlagPlot);
end

% compute distance between points and dendrites
Distance = NaN(n_POIs, size(FluoCoor,1));
MinDist = NaN(1,n_POIs);
MeanDist = NaN(1,n_POIs);
N_Points = NaN(1,n_POIs);
Conversion = FOV/size(ImageFilt,1); % convert from pixels to microns
for p = 1:n_POIs   
    Distance(p,:) = MeasureDistance(POIs(p), Tree, FluoCoor, FluoInBranch(p,:));
    % convert from pixels to microns
    Distance(p, :) = Distance(p, :)*Conversion;
    % find minimum and average distance
    MinDist(p) = nanmin(Distance(p,:));
    MeanDist(p) = nanmean(Distance(p,:));
    N_Points(p) = length(find(Distance(p,:)<=Radius));
end

% average distance across points
AvDist = nanmean(MinDist);
StdDist = nanstd(MinDist);

% how much space around each point is occupied by another dendrite
AllSpace = (Radius/Conversion)^2*pi; % area of circle with radius Radius, in pixels
RatioSpace = N_Points./AllSpace;

disp(['Average minimum distance is ' num2str(AvDist) ' um and standard deviation is ' num2str(StdDist)])

end

