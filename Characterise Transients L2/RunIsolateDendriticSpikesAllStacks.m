Path = pwd;
CellN = [];
CellN = num2str(CellN);

% read files in day of experiment
ReadFolders = dir(Path);

for f = 1: length(ReadFolders)
    if ReadFolders(f).isdir % if file is a folder
        
        PathFolder = [Path '\' ReadFolders(f,1).name];
        
        if isempty(CellN) == 0
            % look for a folder of right cell
            ReadFolderStack = dir(PathFolder);
            for ff = 3:length(ReadFolderStack)
                if ReadFolderStack(ff).isdir == 1 && strcmp(ReadFolderStack(ff).name,['Cell ' CellN]) == 1
                    
                    % look for folder with char transients
                    ReadFolderStackCell = dir([PathFolder '\' ReadFolderStack(ff).name]);
                    for fff = 1:length(ReadFolderStackCell)
                        if length(ReadFolderStackCell(fff).name) > 4
                        if ReadFolderStackCell(fff).isdir == 1 && strcmp(ReadFolderStackCell(fff).name(1:4),'Char') == 1
                            cd([ PathFolder '\' ReadFolderStack(ff).name '\' ReadFolderStackCell(fff).name ])

                            %RunIsolateDendriticSpikesFewBranches(9:15);

                            RunIsolateDendriticSpikes;
                            close all
                            %DfoFSeparateSpikes;
                            close all
                        end
                        end
                    end
                end
            end
        else
            % look for folder with char transients
            ReadFolderStackCell = dir(PathFolder);
            for fff = 3:length(ReadFolderStackCell)
                
                if ReadFolderStackCell(fff).isdir == 1 && length(ReadFolderStackCell(fff).name)> 4 && strcmp(ReadFolderStackCell(fff).name(1:4),'Char') == 1
                    cd([ PathFolder '\' ReadFolderStackCell(fff).name ])
                    
                    %RunIsolateDendriticSpikesFewBranches(9:15);
                    RunIsolateDendriticSpikes;
                    close all
                    %DfoFSeparateSpikes;
                end
            end
            
        end
    end
end

cd(Path)

