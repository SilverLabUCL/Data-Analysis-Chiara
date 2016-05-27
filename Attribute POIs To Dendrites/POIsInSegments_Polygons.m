function [ PointsInSegments ] = POIsInSegments_Polygons(PointPlane,SegmentCoor)
%Given:
%-the coordinates of the imaged POIs in the cell array PointPlane{1,plane}(POI
%index, x,y) 
%-the coordinates of the nodes traced with Vaa3d in the
%cell array SegmentCoor{1,segment}(x,y,z,radius of each node)
% this function draws quadrilaterals between two nodes with the side of their radii and checks if any POI falls into
% a quadrilater.
%- output: PointsInDendrites{1,segment}(POI index): POIs in each segment

n_segments= size(SegmentCoor,2);
PointsInSegments=cell(1,n_segments);

for seg=1:n_segments
    
    counter=1; %counter of POIs per segment
    n_nodes=size(SegmentCoor{1,seg},1);
    
    for node=1: n_nodes-1
        
        if SegmentCoor{1,seg}(node,3)==SegmentCoor{1,seg}(node+1,3) %if two consecutive nodes are in the same plane
            
            ZPlane=SegmentCoor{1,seg}(node,3);
            n_POIs= size(PointPlane{1,ZPlane},1 ); %take only POIs in the same plane as the nodes
            
            for POI=1:n_POIs

                XPoi= PointPlane{1,ZPlane} (POI,2);
                YPoi= PointPlane{1,ZPlane} (POI,3);
                IndexPoi= PointPlane{1,ZPlane} (POI,1);
                
                XNode1= SegmentCoor{1,seg}(node,1);
                YNode1= SegmentCoor{1,seg}(node,2);
                RadiusNode1= SegmentCoor{1,seg}(node,4);
                
                XNode2= SegmentCoor{1,seg}(node +1,1);
                YNode2= SegmentCoor{1,seg}(node + 1,2);
                RadiusNode2= SegmentCoor{1,seg}(node + 1,4);
                
                %find vertexes of polygon between two nodes 
                SlopeLineBetweenNodes = (YNode2 - YNode1) / (XNode2 - XNode1);
                if SlopeLineBetweenNodes==0 %if line is horizontal
                    SlopeLineBetweenNodes=1e-3; %move second node up by 1/1000 of a pixel
                end
                SlopeLinePerpendicular = - 1 / SlopeLineBetweenNodes;
                
                %vertexes on side of first node
                XvNod1Up = XNode1 + sqrt ( RadiusNode1^2/(1 + SlopeLinePerpendicular^2) );
                YvNod1Up = -SlopeLinePerpendicular*XNode1 + SlopeLinePerpendicular*XvNod1Up + YNode1 ;
                
                XvNod1Down = XNode1 - sqrt ( RadiusNode1^2/(1 + SlopeLinePerpendicular^2) );
                YvNod1Down = -SlopeLinePerpendicular*XNode1 + SlopeLinePerpendicular*XvNod1Down + YNode1 ;
                
                %vertexes on side of second node
                XvNod2Up = XNode2 + sqrt ( RadiusNode2^2/(1 + SlopeLinePerpendicular^2) );
                YvNod2Up = -SlopeLinePerpendicular*XNode2 + SlopeLinePerpendicular*XvNod2Up + YNode2 ;
                
                XvNod2Down = XNode2 - sqrt ( RadiusNode2^2/(1 + SlopeLinePerpendicular^2) );
                YvNod2Down = -SlopeLinePerpendicular*XNode2 + SlopeLinePerpendicular*XvNod2Down + YNode2 ;
                
                %find if POI is in polygon
                In=inpolygon(XPoi,YPoi,[XvNod1Up XvNod2Up XvNod2Down XvNod1Down],[YvNod1Up YvNod2Up YvNod2Down YvNod1Down]); %careful to order Xv and Yv are inserted
                
                if In ==1
                    PointsInSegments{1,seg}(counter, 1)= IndexPoi;
                    counter=counter+1;
                end
                
                
            end
        end
        
    end
end





end