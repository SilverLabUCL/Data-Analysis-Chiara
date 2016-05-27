function TrackEyeBatch
% track pupil on batch of experiments

% need to run first codes: ImportVideos and then SelectAllROIs

FolderNameRead = '\\192.168.15.61\data\3D_RIG_2\Camera data'; % runs on server

addpath(FolderNameRead)

% look for days of experiments
Experiments = LookForFolder(FolderNameRead);

for Exp = 1:length(Experiments)-1
    
    disp(['%%%%%%% Working on experiment ' Experiments(Exp)])
    
    % look for stacks in each experiment
    Stacks = LookForFolder([FolderNameRead '\' Experiments{Exp}]);
    
    for s = 1:length(Stacks)
        
        % look for mat files with ROIs selected
        Path = [FolderNameRead '\' Experiments{Exp} '\' Stacks{s}];
        ReadFiles = dir(Path);
        counter = 0;
        for f = 3:length(ReadFiles)
            if strcmp(ReadFiles(f).name(end-3:end),'.mat') == 1 && strcmp(ReadFiles(f).name(1:8),'ROIVideo')
                counter = counter + 1;
                ROIFile{counter,:} = [Path '\' ReadFiles(f).name]; % file with ROI
                VideoN = ReadFiles(f).name(9);
                VideoFile{counter,:} = [Path '\Video' VideoN '.mat']; % file with video
            end
        end
        
        % initalise
        PupilArea = [];
        PupilCentroid = [];
        BlinkingFrames = [];
        EyeTrack = [];
        
        for v = 1:counter
            
            disp(['video ' num2str(v) ' in folder ' Stacks{s}])
            
            load(ROIFile{v,:})
            load(VideoFile{v,:})
            
            % crop video
            VideoCropped = Video( 1:nt,pp(2)+[0:offset(2)], pp(1)+[0:offset(1)]);
            clear Video % just to make space in RAM
            
            % track eye
            [Area, Centroid, eyetrack, blinkingFrames] = TrackEye(VideoCropped);
            
            % concatenate data from videos
            PupilCentroid = [PupilCentroid; Centroid];
            PupilArea = [PupilArea Area];
            EyeTrack = [EyeTrack eyetrack];
            BlinkingFrames = [BlinkingFrames blinkingFrames];
        end
        
        % load time stamps
        FileName = [Path '\EyeCam-' VideoN '.avi'];
        TimeStamps = ImportTimeStamps(FileName);

        % save data
        TrackName = [Path '\EyeTracked.mat'];
        save(TrackName, 'PupilCentroid', 'PupilArea', 'TimeStamps', 'BlinkingFrames', 'EyeTrack', 'VideoCropped')
    end
end

end


function [Folders] = LookForFolder(Path)

ReadFiles = dir(Path);

counter = 0;
for i = 3:length(ReadFiles)
    if (ReadFiles(i).isdir) == 1
        counter = counter + 1;
        Folders{counter} = ReadFiles(i).name;
    end
end

end

function [TimeFrames] = ImportTimeStamps(FileName)

FileNameTime=[FileName(1:end-6) '-relative times.txt'];

formatSpec = '%f %f';
sizeT= [2 Inf];

fid=fopen(FileNameTime,'r');
TimeFrames = fscanf(fid,formatSpec,sizeT);
fclose(fid);

TimeFrames=TimeFrames(2,:);

end
