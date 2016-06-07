function [Answer] = PointsInBranch(Tree, Branch, BranchesInfo, Points, Plane)

% find whether Points are in the branch Branch of the dendritic tree Tree. Do it only for plane Plane
% output vector is Answer, that has same length as Points, and contains
% logicals

% find nodes that are in Branch and in right plane
NodesBranch = find(BranchesInfo == Branch);
Nodes = NodesBranch( find( round(Tree.Z(NodesBranch)) == Plane ));

if length(Nodes) > 1 % if there are at least two nodes
    
    % interpolate nodes to find skeleton of branch
    Segment(:, 1) = min(Tree.X(Nodes)): max(Tree.X(Nodes));
    Segment(:, 2) = interp1(Tree.X(Nodes), Tree.Y(Nodes), Segment(:, 1));
    Segment(:, 3) = interp1(Tree.X(Nodes), Tree.D(Nodes), Segment(:, 1));
    
    % measure distance from points to skeleton of branch
    Answer = zeros(1, length(Points));
    
    for p = 1:length(Points)
        
        for sk = 1:size(Segment,1)
            
            Distance = sqrt( (Segment(sk, 1) - Points(p, 1))^2 + (Segment(sk, 2) - Points(p, 2))^2 );
            
            if Distance <= (Segment(sk,3)/2+3)
                Answer(p) = 1;
                break
            end
            
        end
    end
    
    % plot
    PoiInBranch = find(Answer == 1);
    figure;
    plot(Points(:,1), Points(:,2),'.') % plot all points with fluorescence
    hold on; plot(Points(PoiInBranch,1), Points(PoiInBranch,2),'mo') % plot points in branch
    hold on; plot(Segment(:,1), Segment(:,2),'r-') % plot branch
    
else
    Answer = NaN;
end

end