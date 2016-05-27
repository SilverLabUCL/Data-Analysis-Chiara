function [eyetrack, TimeFrames,BlinkingFrames] = EyeTracking3(FileName, flag_plot, FlagTimeStamp, FlagSave)
%% Tracks the eye in a video taken during an experiment

%inputs:
% - FileName : name of the file (and path if necessary) of the video of the
% eye. Should be an AVI file (works well with AVI2, IYUV Intel codec). If not specified,
% the code takes the first avi file found in the current folder
% - flagplot = true if user wants to plot each frame with eye tracking,
% otherwise false
% - FlagTimeStamp = set to true to load timestamp file
% - FlagSave = set to true to save eye tracking figures and data

% outputs:
% - eyetrack: contains pupil opsition and diameter
% - Video: video imported in matlab
% - TimeFrames: time of each frame, in ms
% - BlinkingFrames: frames where the animals blinks

% automatically saves pupil position data and figure

% compared to EyeTracking: inserted blink detector and import also time
% data, changed parameters to detect pupil

%% default inputs

if nargin < 4
    FlagSave = 1;
end

if nargin < 3
    FlagTimeStamp=0;
end

if nargin < 2
    flag_plot=0;
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

AverageImage=mean(Video(1:30,:,:),1); % draw ROI on average of first 30 frames, i.e. 1s of recording

figure;
imagesc( squeeze(AverageImage) );
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

%% crop the video to the ROI

if ~FlagDoNotCrop
    VideoCropped = Video( 1:nt,pp(2)+[0:offset(2)], pp(1)+[0:offset(1)]);
end

clear Video

%% track eye

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
    eyetrackTemp= trackEyeParameters2(S,flag_plot);
    
    %store data, couldn't find a decent way to do it
    eyetrack(t).Area=eyetrackTemp.Area;
    eyetrack(t).Centroid=eyetrackTemp.Centroid;
    eyetrack(t).MajorAxisLength=eyetrackTemp.MajorAxisLength;
    eyetrack(t).MinorAxisLength=eyetrackTemp.MinorAxisLength;
    eyetrack(t).Orientation=eyetrackTemp.Orientation;
    
end

disp(['number of blinks detected: ' num2str(counter_blinking) ]);

%% plot pupil positions and area

counterMissingData=0;

PupilCentroidCoor=NaN(nt,2);
PupilArea=NaN(1,nt);

figure;
for t=1:nt
    if isempty( eyetrack(t).Area) == 0
        
        plot(eyetrack(t).Centroid(1),eyetrack(t).Centroid(2),'b.', 'markersize',10)
        hold all;
        
        %save xy coordinates and area of pupil in matrices, easier to work with
        PupilCentroidCoor(t,:)=eyetrack(t).Centroid;
        PupilArea(t)=eyetrack(t).Area;
        
    else
        counterMissingData=counterMissingData+1;
        disp(['Pupil not found on frame number ' num2str(t)])
    end
    
end

title('Pupil positions during the video')
set(gca, 'YDir', 'reverse');
axis([ 0 size(S,2) 0  size(S,1)]);

TwoDHist( PupilCentroidCoor, [30,30])
set(gca, 'YDir', 'reverse');
title('Pupil positions during the video')
axis([ 0 size(S,2) 0  size(S,1)]);

figure;
T = 0: 1/30 : length(PupilArea)/30;
plot(T(1: end-1),PupilArea)
axis tight; box off
title('Area of the pupil')
xlabel('Time, seconds')
ylabel('Area, pixels')

h=gcf;
MissingData=counterMissingData - counter_blinking;
disp(['Warning! Data missing for ' num2str(MissingData) ' frames out of ' num2str(nt) ' frames'])

%% save
if FlagSave
    
    location=pwd; Date=date;
    
    save('EyeTracking.mat','eyetrack','FileName','location','Date','TimeFrames','BlinkingFrames','VideoCropped','MissingData','PupilCentroidCoor','PupilArea')
    
    saveas(h,'PupilArea.fig')
    saveas(h-1,'PupilPositions2.fig')
    saveas(h-2,'PupilPositions.fig')
    
    if flag_plot
        saveas(h-3,'PupilDetection.fig')
        saveas(h-4,'EyeTracking_ROI.fig')
    else
        saveas(h-3,'EyeTracking_ROI.fig')
    end
end

end


