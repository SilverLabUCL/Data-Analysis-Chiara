function [SegmentCoor] = GenerateSegmentCoor (trees, NodesInfo, OffsetRadius, FrameSize)
 %%% SegmentCoor {SegmentID} nodes(X Coor, Y Coor, Z Coor, radius).


n_segments=max(NodesInfo(:,1));

SegmentCoor=cell(1,n_segments);

for Seg=1:n_segments
    
    NodesInSeg=find(NodesInfo(:,1)==Seg);
    
    for node=1:length(NodesInSeg)
        
        % x coor
        SegmentCoor{Seg}(node,1)= trees.X(NodesInSeg(node),1);
        
        % y coor
        SegmentCoor{Seg}(node,2)= trees.Y(NodesInSeg(node),1); %FrameSize - trees.Y(NodesInSeg(node),1);
        
        % z coor, add 1 (vaa3d starts to count from plane 0), round
        SegmentCoor{Seg}(node,3)= round(trees.Z(NodesInSeg(node),1)) + 1;
        
        % radius, and add offset
        SegmentCoor{Seg}(node,4)= trees.D(NodesInSeg(node),1)/2 + OffsetRadius ;
        
    end
    clear NodesInSeg
end



end