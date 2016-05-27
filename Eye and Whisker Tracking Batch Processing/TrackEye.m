function [ PupilArea, PupilCentroid, eyetrack, BlinkingFrames ] = TrackEye( VideoCropped )
% tracks pupil in video

nt = size(VideoCropped,1);

%detect frames where animals blinks or grooms
counter_blinking=0;
AverageImageCropped=mean(VideoCropped,1);

for t=1:nt
    Correlation(t)=corr(reshape(VideoCropped(t,:,:),[],1),reshape(AverageImageCropped,[],1)); %compute correlation of each imge with average image to detect blinks
end

threshold=mean(Correlation)-2*std(Correlation);

for t = 1:nt
    %remove frames where animal blinks
    if Correlation(t)<threshold
        VideoCropped(t,:,:)=NaN;
        counter_blinking=counter_blinking+1;
        BlinkingFrames(counter_blinking)=t;
    end
    
    %detect pupil
    S = squeeze( VideoCropped(t,:,:) );
    eyetrack= trackEyeParameters2(S,0);
    
    %store data
    PupilArea(t)=eyetrack.Area;
    PupilCentroid(t)=eyetrack.Centroid;
end

disp(['number of blinks detected: ' num2str(counter_blinking) ]);


end

