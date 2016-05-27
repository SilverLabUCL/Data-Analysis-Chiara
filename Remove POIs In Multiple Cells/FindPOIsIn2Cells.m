
function [POIsIn2Cells] = FindPOIsIn2Cells(POI1, POI2)

PP1 = cell2mat(POI1');
PP2 = cell2mat(POI2');

POIsIn2Cells = intersect(PP1,PP2);

end