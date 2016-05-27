function [ POIsSoma ] = POIsInSoma( tree, PointPlane, PlanesSoma )
% finds Points Of Interests (POIs) that were imaged in the soma.

% Soma is where the root (node 1) is.
% User needs to specify in all the planes where the soma was (PlanesSoma). Start to count planes from 1: first plane is plane 1 (and not plane 0)
% Draws a circle around root in all specified planes and finds POIs in the
% circle

XSoma = tree.X(1);
YSoma = tree.Y(1);
Radius = tree.D(1)/2;

counter = 1;
POIsSoma = [];

for Pl = 1:length(PlanesSoma)
    
    n_POIs = size(PointPlane{1,PlanesSoma(Pl)},1 );
    
    for POI = 1:n_POIs
        
        %calculate distance between each node and each POI
        Distance=sqrt( (PointPlane{1,PlanesSoma(Pl)} (POI,2) - XSoma )^2 + ( PointPlane{1,PlanesSoma(Pl)} (POI,3) - YSoma )^2 );
        
        %if distance is minor than radius, consider that point in that segment
        if Distance <= Radius
            POIsSoma(counter)= PointPlane{1,PlanesSoma(Pl)} (POI,1);
            counter=counter+1;
        end
    end
end
end

