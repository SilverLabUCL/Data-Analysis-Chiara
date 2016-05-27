function [ Area, Centroid ] = TrackEyeManually( Input, FlagSave )

n_frames = 600;

if nargin < 2
    FlagSave = 1;
end

% if no input is given, look for avi file in current folder
if nargin < 1
    ReadFiles=dir;
    for file=1:length(ReadFiles)
        if isempty(regexp(ReadFiles(file,1).name,'avi', 'once'))==0
            FileName= ReadFiles(file,1).name;
        end
    end
    FlagCrop = 1;
else
    if isnumeric(Input) == 1 % if input is numeric, it assumed it's the video already cropped
        FlagCrop = 0;
        VideoCropped = Input;
    else                     % if input is not numeric, it assumes that input is the name of the video file to load and to crop
        FlagCrop = 1;
        FileName = Input;
    end
end

if FlagCrop == 1
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
    
else
    nt = size(VideoCropped, 1);
end
%% track eye

Centroid = NaN(n_frames,2);
Area = NaN(1,n_frames);

for t = 1 : n_frames
    
    S = squeeze( VideoCropped(t,:,:) );
    
    figure('units','normalized','outerposition',[0 0 1 1])
    imagesc(S);
    colormap bone
    axis image
    title(['Select pupil  frame ' num2str(t) ' out of ' num2str(n_frames)]);
    
    BWObj = imfreehand; % draw ROI around eye or BW = roipoly;
    
    if isempty(BWObj) == 1
        Area(t) = NaN;
        Centroid(t,:) = NaN;
    else
        BW = createMask(BWObj);
        stats = regionprops(BW, 'Centroid','Area');
        
        if sum(sum(BW)) > 0
            Area(t) = stats.Area;
            Centroid(t,:) = stats.Centroid;
        else
            Area(t) = NaN;
            Centroid(t,:) = NaN;
        end
    end
    
    close
end

if FlagSave
    Date = date;
    save('TrackEyeManually.mat')
end


end

