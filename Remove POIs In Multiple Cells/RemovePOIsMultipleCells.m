function RemovePOIsMultipleCells( Path )
% remove the imaged POIs that are in multiple cells

if nargin < 1
    Path = pwd;
end

% look for all folders (1 folder = 1 stack)
ReadFiles = dir(Path);

for i = 3:length(ReadFiles)
    
    % find folders with data for multiple cells
    [ PathsData, n_cells ] = FindData( [ Path '\' ReadFiles(i).name] );
    
    % load points data for each cell
    for c = 1:n_cells
        [ POI{c}, FileName{c} ]= FindPointsData(PathsData(c,:));
    end
    
    % find points that are in multiple cells
    POIsIn2Cells = [];
    for c = 1:n_cells
        for cc = c+1 : n_cells
            [pp] = FindPOIsIn2Cells(POI{c}, POI{cc});
            POIsIn2Cells = [POIsIn2Cells; pp];
        end
    end
    
    if isempty(POIsIn2Cells) == 0
        for c = 1:n_cells
            
            % discard points that are in multiple points
            load(FileName{c},'PointsInSegments','n_segments','POIsIn2Segm','SortedTree','NodesInfo')
            for seg = 1:n_segments
                
                Indexes = logical(abs((ismember(PointsInSegments{seg},POIsIn2Cells))-1));
                PointsInSegments{seg} = PointsInSegments{seg}(Indexes);
                clear Indexes
            end
            
            % rerun df/f  
            cd(PathsData(c,:))
            Date = date;
            save('PutPointsInDendritesRemovedPOIsMultipleCells.mat','PointsInSegments','POIsIn2Cells','POIsIn2Segm','SortedTree','NodesInfo')
            DeltaFoFPOIsDendrites5RemovePOIs;
            close all
            clear PointsInSegments POIsIn2Segm
            disp(['Removed points for stack ' ReadFiles(i).name ' for cell ' num2str(c)])
            cd(Path)
        end
    end
end



end

