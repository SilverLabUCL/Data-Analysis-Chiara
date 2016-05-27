function [ PointsInSegments ] = POIsInSegments_Circles(PointPlane,SegmentCoor)
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

for seg=1:n_segments
    
    counter=1; %counter of POIs per segment
    n_nodes=size(SegmentCoor{1,seg},1);
    
    for node=1:n_nodes
        
        ZPlane=SegmentCoor{1,seg}(node,3);
        
        n_POIs= size(PointPlane{1,ZPlane},1 ); %take only POIs in the same plane as node
        
        for POI=1:n_POIs
            
            %calculate distance between each node and each POI
            Distance=sqrt( (PointPlane{1,ZPlane} (POI,2) - SegmentCoor{1,seg}(node,1) )^2 + ( PointPlane{1,ZPlane} (POI,3) - SegmentCoor{1,seg}(node,2) )^2 );
            
            %if distance is minor than radius, consider that point in that segment
            if Distance <= SegmentCoor{1,seg}(node,4)
               PointsInSegments{1,seg}(counter,1)= PointPlane{1,ZPlane} (POI,1);
               counter=counter+1;
            end
            
            
        end
    end
    
    
end





end