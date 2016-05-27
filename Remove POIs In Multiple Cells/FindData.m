function [ Paths, n_cells ] = FindData( Folder )
% find folders with data for a cell

if isdir(Folder) == 1 && strcmp(Folder(end-1:end),'..') == 0
    
    ReadSubFolders = dir(Folder);
    n_cells = 0;
    
    for i = 3:length(ReadSubFolders)
        FolderName = [Folder '\' ReadSubFolders(i).name];
        % find subfolders named "Cell"
        if isdir(FolderName) == 1 && strcmp(ReadSubFolders(i).name(1),'.') == 0 && strcmp(ReadSubFolders(i).name(1:4),'Cell') == 1
            n_cells = n_cells + 1;
            Paths(n_cells,:) = FolderName;
        end
        
    end
    
    if n_cells == 0 % if no correct subfolders are found
        Paths = [];
    end
    
else
    Paths = [];
    n_cells = 0;
end


end

