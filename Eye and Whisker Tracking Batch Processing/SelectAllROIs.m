function SelectAllROIs
% select a lot of ROIs all together

FolderNameRead = '\\192.168.15.61\data\3D_RIG_2\Camera data';

addpath(FolderNameRead)

% look for days of experiments
Experiments = LookForFolder(FolderNameRead);

for Exp = 1:length(Experiments)-1
    
    disp(['%%%%%%% Working on experiment ' Experiments(Exp)])
    
    % look for stacks in each experiment
    Stacks = LookForFolder([FolderNameRead '\' Experiments{Exp}]);
    
    for s = 1:length(Stacks)
        
        % look for mat files (videos imported in matlab)
        Path = [FolderNameRead '\' Experiments{Exp} '\' Stacks{s}];
        ReadFiles = dir(Path);
        counter = 0;
        for f = 3:length(ReadFiles)
            if strcmp(ReadFiles(f).name(end-3:end),'.mat') == 1
                counter = counter + 1;
                MatFile{counter,:} = [Path '\' ReadFiles(f).name];
            end
        end
        
        
        for v = 1:counter
            
            disp(['video ' num2str(v) ' in folder ' Stacks{s}])
            
            % draw ROI
            load(MatFile{v},'AverageImage')
            [pp, offset] = SelectROI(AverageImage);
            
            % save ROI info
            ROIFile = [Path '\ROIVideo' num2str(v) '.mat'];
            save(ROIFile, 'pp','offset','-v7.3')
            
            close

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

function [pp, offset] = SelectROI(AverageImage)

nr = size(AverageImage,1);
nc = size(AverageImage, 2);

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

end

