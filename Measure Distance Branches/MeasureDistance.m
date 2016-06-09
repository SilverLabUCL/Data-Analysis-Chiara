function [ Distance ] = MeasureDistance( POI, Tree, FluoCoor, FluoInBranch )
% Measure distance from a POI in tree to all points with coordinates
% specified in FluoCoor. 2D
% but discards points in FluoInBranch, because they are fluorescent points
% in the same dendritic branch as POI

XPOI = Tree.X(POI);
YPOI = Tree.Y(POI);
Distance = NaN(1, size(FluoCoor,1));

for f = 1: size(FluoCoor,1)
    if FluoInBranch(f) == 0
        Distance(f) = sqrt( (XPOI - FluoCoor(f,1))^2 + (YPOI - FluoCoor(f,2))^2);
    end
end


end
