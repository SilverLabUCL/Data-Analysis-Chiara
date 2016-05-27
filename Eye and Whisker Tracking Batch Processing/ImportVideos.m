function ImportVideos

FolderNameRead = '\\192.168.15.61\data\3D_RIG_2\Camera data';

addpath(FolderNameRead)

% look for days of experiments
Experiments = LookForFolder(FolderNameRead);

for Exp = 1:length(Experiments)-1
    
    disp(['%%%%%%% Working on experiment ' Experiments(Exp)])
    
    % look for stacks in each experiment
    Stacks = LookForFolder([FolderNameRead '\' Experiments{Exp}]);
    
    for s = 1:length(Stacks)
        
        % look for eye cam videos
        Path = [FolderNameRead '\' Experiments{Exp} '\' Stacks{s}];
        ReadFiles = dir(Path);
        counter = 0;
        for f = 3:length(ReadFiles)
            if strcmp(ReadFiles(f).name(1:3),'Eye') == 1 && strcmp(ReadFiles(f).name(end-3:end),'.avi') == 1
                counter = counter + 1;
                VideoFile{counter,:} = [Path '\' ReadFiles(f).name];
            end
        end
        
        for v = 1:counter
            
            disp(['importing videos for folder ' Stacks{s} ' video ' num2str(v)])
            
            % import videos
            Video = ImportVideo(VideoFile{v});
            % save video and the average of the first 30 frames to draw
            % a ROI later
            AverageImage = squeeze(mean(Video(1:30,:,:),1));
            MatFile = [Path '\Video' num2str(v) '.mat'];
            save(MatFile, 'Video','AverageImage','-v7.3')
            clear Video
        end
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

function [Video] = ImportVideo(FileName)

Obj = VideoReader(FileName);

numberOfFrames = Obj.NumberOfFrames;
H = Obj.Height;
W = Obj.Width;
Video = zeros(numberOfFrames,H,W);

for f = 1:numberOfFrames
    thisFrame = read(Obj, f);
    Video(f,:,:) = rgb2gray(thisFrame);
end

end
