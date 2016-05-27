function [POI, FileName] = FindPointsData(Path)
% find in Path the more recent mat file with information of which imaged
% POIs are in which segment

if isdir(Path) == 1 && isempty(Path) == 0 % check that Path is a folder
    
    ReadFiles = dir(Path);
    counter = 0;
    
    for f = 3:length(ReadFiles)
        % look for mat files that start with "PutP"
        if strcmp(ReadFiles(f).name(1:4),'PutP') == 1 && strcmp(ReadFiles(f).name(end-3:end),'.mat') == 1
            counter = counter + 1;
            PointsFile(counter) = f;
        end
    end
    
    if counter == 1 % if only one file is found
        % load points data
        FileName = [ Path '\' ReadFiles(PointsFile).name ];
        load(FileName, 'PointsInSegments')
        POI = PointsInSegments;
        
    
    elseif counter > 1 % if there are several mat files, take the most recent file
        
        dates = [];
        for f = 1:counter
            dates = [dates ; ReadFiles(PointsFile(f)).datenum];
        end
        [~, pos] = max(dates);
        %load points data
        FileName = [ Path '\' ReadFiles(PointsFile(pos)).name ];
        load(FileName, 'PointsInSegments')
        POI = PointsInSegments;
        
    else % if no good files are found
        POI = [];
        FileName = [];
        disp('No Points file in this folder')
    end
else
    POI = [];
    FileName = [];
end


end

