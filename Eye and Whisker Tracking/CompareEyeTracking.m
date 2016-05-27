function CompareEyeTracking( Area, Centroid, PupilArea, PupilCentroidCoor )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

frame_rate = 30; % in herz
n_frames = length(Area);
time = 0: 1/frame_rate : (n_frames/frame_rate -1);

figure; 
plot(time,Area);
hold all; 
plot(time, PupilArea(1:n_frames),'r')
title('Area')

figure; 
plot(time,Centroid(:,1)); 
hold all; 
plot(time, PupilCentroidCoor(1:n_frames,1),'r')
title('Centroid coor 1')

figure; 
plot(time,Centroid(:,2)); 
hold all; 
plot(time, PupilCentroidCoor(1:n_frames,2),'r')
title('Centroid coor 2')

end

