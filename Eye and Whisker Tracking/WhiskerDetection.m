function [ LineFitting, TimeFrames ] = WhiskerDetection( FileName, FlagTimeStamp, FlagPlot )
% tracks a whisker fitting it with a line, returns the parameters of the
% line at every frame

% NOTE!! code wrote for videos acquired with slow (30 Hz) camera, so if the code
% doesn't see a whisker it assumes that the whisking is too fast to be
% detected, so it returns Whisking = 1

if nargin < 3
    FlagPlot = 1;
end

if nargin < 2
    FlagTimeStamp = 1;
end

if nargin < 1 % look for avi file in current folder
    ReadFiles=dir;
    for file=1:length(ReadFiles)
        if isempty(regexp(ReadFiles(file,1).name,'avi', 'once'))==0
            FileName= ReadFiles(file,1).name;
        end
    end
end

%% load video file
mov=aviread(FileName);

nr=size(mov(1,1).cdata,1);
nc=size(mov(1,1).cdata,2);
nt=length(mov); %number of frames

Video=zeros(nt,nr,nc);

for frame=1:nt
    [temp, ~ ]=frame2im(mov(1,frame));
    Video(frame,:,:) = temp(:,:,1);
    %[Video(frame,:,:), ~ ]=frame2im(mov(1,frame));
end

clear mov

%% load time stamps

if FlagTimeStamp
    
    FileNameTime=[FileName(1:end-6) '-relative times.txt'];
    
    formatSpec = '%f %f';
    sizeT= [2 Inf];
    
    fid=fopen(FileNameTime,'r');
    TimeFrames = fscanf(fid,formatSpec,sizeT);
    fclose(fid);
    
    TimeFrames=TimeFrames(2,:);
    
    % check that Video and TimeStamps have the same length, otherwise gives a
    % warning message
    if length(TimeFrames) ~= size(Video,1)
        disp('Warning!!!!!  The video and the timestamps do not have the same number of elements!! Possibly missing frames or problems in synchronization')
    end
    
else
    
    TimeFrames=[];
    
end

%% define a ROI

[VideoCropped] = DefineROI(Video);

clear Video

%% normalize, smooth and threshold video

VideoThr = zeros(nt, size(VideoCropped,2), size(VideoCropped,3));
for frame = 1:nt
    %normalize
    S = squeeze(VideoCropped(frame,:,:));
    S1 = S/mean(S(:));
    %smooth
    myfilter = fspecial('gaussian',[3 3], 1);
    S2 = imfilter(S1, myfilter, 'replicate');
    %threshold
    VideoThr(frame, :, :) = S2 < 0.7;
end

%% define ROI again
[VideoThrCropped] = DefineROI(VideoThr);

%% fit whisker with a line
LineFitting = NaN(2,nt);

for frame = 1:nt
    
        % fit whisker with a line
        [y, x] = find(squeeze(VideoThrCropped(frame,:,:) == 1));
        y = -y;
        [LineFitting(1:2,frame)] = polyfit(x,y,1);
        
        if FlagPlot
            figure(3);
            subplot(1,3,1)
            imagesc(squeeze(VideoCropped(frame,:,:))); 
            colormap(bone)
            title('Image cropped')
            
            subplot(1,3,2)
            imagesc(squeeze(VideoThrCropped(frame,:,:)))
            colormap(gray)
            title('Threshold')
            
            subplot(1,3,3)
            imagesc(squeeze(VideoThrCropped(frame,:,:)))
            colormap(gray)
            hold on;
            yFit = x.*LineFitting(1,frame) + LineFitting(2,frame);
            plot(x,-yFit,'ro')
            title('Fit')
        end  
end


end

function [VideoCropped] = DefineROI(Video)

nt = size(Video,1);
nr = size(Video,2);
nc = size(Video,3);

figure;
imagesc( squeeze(Video(1,:,:)) );
colormap bone
axis image
title('Select a ROI');
hold on

FlagDoNotCrop = true;

FlagDoNotCrop = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = round(point1(1,1:2));              % extract x and y
point2 = round(point2(1,1:2));
pp = min(point1,point2);             % calculate locations
if pp(1)<1
    pp(1) = 1;
elseif pp(1)>nc
    pp(1) = nc;
end
if pp(2)<1
    pp(2)= 1;
elseif pp(2)>nr
    pp(2)= nr;
end
offset = abs(point1-point2);         % and dimensions
pp_plusoffset = pp + offset;
if pp_plusoffset(1)>nc,
    offset(1) = nc-pp(1);
end
if pp_plusoffset(2)>nr
    offset(2)= nr-pp(2);
end
x = pp(1) + [0 offset(1) offset(1) 0 0];
y = pp(2) + [0 0 offset(2) offset(2) 0];

plot(x,y,'r','linewidth',5)          % draw box around selected region

if FlagDoNotCrop, close(gcf); end

if ~FlagDoNotCrop
    VideoCropped = Video( 1:nt,pp(2)+[0:offset(2)], pp(1)+[0:offset(1)]);
else
    VideoCropped = Video;
end


end