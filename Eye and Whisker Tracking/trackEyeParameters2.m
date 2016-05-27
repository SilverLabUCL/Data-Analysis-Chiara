function [stats] = trackEyeParameters2(S,flag_plot)
%Recognizes the pupil in a image, function called by EyeTracking to track
%eye movements during an experiment


S(S>140) = 80; % remove very bright stuff, like reflections of light

S = S/mean(S(:)); %normalize to the average light level AP Feb 12
% ROI S = I(:,:)

%S = (S - min(S(:)))./(max(S(:))-min(S(:)));
% S(S>0.35) = 0.35;
% S = (S - min(S(:)))./(max(S(:))-min(S(:)));

% smoothing
myfilter = fspecial('gaussian',[3 3], 1);

S1 = imfilter(S, myfilter, 'replicate');
for rep=1:20
    S1=imfilter(S1, myfilter, 'replicate');
end

% contrast enhance
%S3 = imadjust(S2,[.15,1],[],.5);
%S3 = imadjust(S2);

% thresholding for pupil
S2 = S1<0.8;   %%%%%0.3 NEWpar
%R4  = S3>0.9;

%removing borders
% S4(1:3,:) = 0;
% S4(end-2:end,:) = 0;
% S4(:,1:3) = 0;
% S4(:,end-2:end) = 0;


% removing small objects
se = strel('disk',1);   %%%%%3
S3 = imerode(S2, se);

S4 = bwareaopen(S3,500);  %%%%
%R5 = bwareaopen(R4,10);  %%%%%
S5 = imclose(S4, se);
%R5=R4;
stats = regionprops(S5, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Area', 'Orientation'); %pupil parameters
% stats.reflection = regionprops(R5, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Area', 'Orientation'); %reflectance from the LED
% stats.reflectance = sum(S(S5)); %light reflected by the pupil


if flag_plot
    
    figure(2);
    subplot(1,5,1)
    imagesc(S); axis off
    colormap(gray)
    operation = 'Normalization';
    title(operation);
    
    subplot(1,5,2)
    imagesc(S1); axis off
    operation = 'Smoothing';
    title(operation);
    
    subplot(1,5,3)
    imagesc(S2); axis off
    operation = 'Threshold';
    title(operation);
    
    subplot(1,5,4)
    imagesc(S5); axis off
    operation = 'Fill and remove';
    title(operation);
    
    subplot(1,5,5)
    imagesc(S5); axis off
    operation = 'Centroid';
    title(operation);
    for i=1:size(stats,1)
        hold on
        plot(stats(i).Centroid(1),stats(i).Centroid(2),'or')
    end
  
end

end