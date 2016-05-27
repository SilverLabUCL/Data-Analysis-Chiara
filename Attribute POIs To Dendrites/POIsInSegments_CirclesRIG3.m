function [ PointsInSegments ] = POIsInSegments_CirclesRIG3(PointPlane,SegmentCoor)
%Given:
%-the coordinates of the imaged POIs in the cell array PointPlane{1,plane}(POI
%index, x,y) 
%-the coordinates of the nodes traced with Vaa3d in the
%cell array SegmentCoor{1,segment}(x,y,z,radius of each node)
% this function calculates in any POIs is at a distance < radius from a
% node. It draws circles around each node and checks if any POI falls into
% a circle.
%- output: PointsInDendrites{1,segment}(POI index): POIs in each segment

n_segments= size(SegmentCoor,2);
PointsInSegments=cell(1,n_segments);

n_POIs = size(PointPlane,1);

for seg=1:n_segments
    
    counter=1; %counter of POIs per segment
    n_nodes=size(SegmentCoor{1,seg},1);
    
    for node=1:n_nodes
        for POI=1:n_POIs
            
            POIIndex = find(PointPlane(:,1) == POI);
            
            %calculate distance between each node and each POI
            Distance=sqrt( (PointPlane(POIIndex,2) - SegmentCoor{1,seg}(node,1) )^2 + ( PointPlane(POIIndex,3) - SegmentCoor{1,seg}(node,2) )^2 );
            
            %if distance is minor than radius, consider that point in that segment
            if Distance <= SegmentCoor{1,seg}(node,4)
               PointsInSegments{1,seg}(counter,1)= POI;
               counter=counter+1;
            end
        end
    end
    
    
end





end