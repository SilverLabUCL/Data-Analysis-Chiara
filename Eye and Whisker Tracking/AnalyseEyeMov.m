

load('EyeTracked.mat', 'PupilCentroid')

DiameterEye = 3.37; % in mm
PixelToMm = 0.013; % conversion factor from pixels to mm

n_frames = size(PupilCentroid,1);
EyeMov = NaN(1,n_frames); % in mm, eye movement
Dist = NaN(1,n_frames); % distance from starting position of pupil
EyeMovAng = NaN(1,n_frames); % in degrees
DistAng = NaN(1,n_frames);

for t = 2:n_frames
    
    if isnan(PupilCentroid(t,1)) == 0
        EyeMov(t) = PixelToMm*sqrt( (PupilCentroid(t,1)-PupilCentroid(t-1,1))^2 + (PupilCentroid(t,2)-PupilCentroid(t-1,2))^2 );
        Dist(t) = PixelToMm*sqrt( (PupilCentroid(t,1)-PupilCentroid(1,1))^2 + (PupilCentroid(t,2)-PupilCentroid(1,2))^2 );
    else
        EyeMov(t) = NaN;
        Dist(t) = NaN;
    end
    
    % convert to angles
    EyeMovAng(t) = atan( EyeMov(t)/DiameterEye )*180/pi;
    DistAng(t) = atan( Dist(t)/DiameterEye )*180/pi;
    
end


