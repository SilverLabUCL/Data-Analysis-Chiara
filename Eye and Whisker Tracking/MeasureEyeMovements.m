function [ EyeMovAng ] = MeasureEyeMovements( PupilCentroid, FlagPlot )
% given coordinates of the centre of the pupil, calculates eye movements
% (in degrees) from the mean position

RadiusEye = 1.6; % in mm, form Remtulla et al 1984
PixelToMm = 0.013; % conversion factor from pixels to mm

n_frames = size(PupilCentroid,1);
EyeMov = NaN(1,n_frames); % in mm, eye movement
EyeMovAng = NaN(1,n_frames); % in degrees

RefX = nanmean(PupilCentroid(:,1));
RefY = nanmean(PupilCentroid(:,2));

for t = 1:n_frames
    
    if isnan(PupilCentroid(t,1)) == 0
        EyeMov(t) = PixelToMm*sqrt( (PupilCentroid(t,1)-RefX)^2 + (PupilCentroid(t,2)-RefY)^2 );
    else
        EyeMov(t) = NaN;
    end
    
    % convert to angles
    EyeMovAng(t) = asin( EyeMov(t)/RadiusEye )*180/pi;
    
end

if FlagPlot
    figure; 
    plot(EyeMovAng)
end

end

