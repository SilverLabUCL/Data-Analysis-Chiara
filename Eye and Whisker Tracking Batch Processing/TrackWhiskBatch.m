function TrackWhiskBatch
% track pupil on batch of experiments

% need to run first codes: ImportVideos and then SelectAllROIs

FolderNameRead = '\\192.168.15.61\data\3D_RIG_2\Camera data'; % runs on server

addpath(FolderNameRead)

% look for days of experiments
Experiments = LookForFolder(FolderNameRead);

for Exp = 1:length(Experiments) - 2
    
    disp(['%%%%%%% Working on experiment ' Experiments(Exp)])
    
    % look for stacks in each experiment
    Stacks = LookForFolder([FolderNameRead '\' Experiments{Exp}]);
    
    for s = 1:length(Stacks)
        
        % look for mat files with ROIs selected
        Path = [FolderNameRead '\' Experiments{Exp} '\' Stacks{s}];
        ReadFiles = dir(Path);
        counter = 0;
        for f = 3:length(ReadFiles)
            if strcmp(ReadFiles(f).name(end-3:end),'.mat') == 1 && strcmp(ReadFiles(f).name(1:9),'ROIWhisks')
                counter = counter + 1;
                ROIFile{counter,:} = [Path '\' ReadFiles(f).name]; % file with ROI
                VideoN = ReadFiles(f).name(10);
                VideoFile{counter,:} = [Path '\Video' VideoN '.mat']; % file with video
            end
        end
        
        % initalise
        LineFit = [];
        
        for v = 1:counter
            
            disp(['video ' num2str(v) ' in folder ' Stacks{s}])
            
            try
                load(ROIFile{v,:})
                load(VideoFile{v,:})
                nt = size(Video,1);
                
                % crop video
                VideoCropped = Video( 1:nt,pp(2)+[0:offset(2)], pp(1)+[0:offset(1)]);
                clear Video % just to make space in RAM
                
                % track whisker
                VideoThr = zeros(nt, size(VideoCropped,2), size(VideoCropped,3));
                LineFitting = NaN(2,nt);
                
                for frame = 1:nt
                    %normalize
                    S = squeeze(VideoCropped(frame,:,:));
                    S1 = S/mean(S(:));
                    %smooth
                    myfilter = fspecial('gaussian',[3 3], 1);
                    S2 = imfilter(S1, myfilter, 'replicate');
                    %threshold
                    VideoThr(frame, :, :) = S2 < 0.7;
                    % fit whisker with a line
                    [y, x] = find(squeeze(VideoThr(frame,:,:) == 1));
                    y = -y;
                    [LineFitting(1:2,frame)] = polyfit(x,y,1);
                end

                % concatenate data from videos
                LineFit = [LineFit LineFitting];
                
            catch ME
                disp('ERROR')
                ME
            end
        end
        
        if counter > 0
            % load time stamps
            FileName = [Path '\EyeCam-' VideoN '.avi'];
            TimeStamps = ImportTimeStamps(FileName);
            
            % save data
            TrackName = [Path '\WhiskerTracked.mat'];
            save(TrackName, 'LineFit', 'TimeStamps', 'VideoCropped')
        end
    end
end

end


function [Folders] = LookForFolder(Path)

ReadFiles = dir(Path);

counter = 0;
Folders = [];
for i = 3:length(ReadFiles)
    if (ReadFiles(i).isdir) == 1
        counter = counter + 1;
        Folders{counter} = ReadFiles(i).name;
    end
end

end

function [TimeFrames] = ImportTimeStamps(FileName)

FileNameTime = [FileName(1:end-6) '-relative times.txt'];
FileNameTime2 = [FileName(1:end-9) '-relative times.txt']; % old files sometimes are saved with slightly different name

formatSpec = '%f %f';
sizeT= [2 Inf];

if exist(FileNameTime,'file') == 2
    fid = fopen(FileNameTime,'r');
    TimeFrames = fscanf(fid,formatSpec,sizeT);
    fclose(fid);
elseif exist(FileNameTime2,'file') == 2
    fid = fopen(FileNameTime2,'r');
    TimeFrames = fscanf(fid,formatSpec,sizeT);
    fclose(fid);
end

TimeFrames = TimeFrames(2,:);

end
