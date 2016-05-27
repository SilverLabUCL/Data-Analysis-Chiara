function [ SpatialDistribBranch ] = NumberGlobalVsLocalPerBranch( FilesLoaded, n_segments, SortedTree, NodesInfo)
% gets the spatial distribution of calcium events for each branch. For
% example: branch 1 had n events that occurred in all tree, m events that
% occurred only in 2 branches, etc

nStacks = length(FilesLoaded);
Global = NaN(1, n_segments);
Local = NaN(1, n_segments);
Half = NaN(1, n_segments);

for br = 1:n_segments
    
    counter = 1;
    
    for s = 1:nStacks
        load(FilesLoaded{s},'TransientsChar')
        if length(TransientsChar) >= br
            data = TransientsChar(1,br).Distribution;
            SpatialDistribBranch(br, counter : counter+length(data)-1) = data;
            counter = counter + length(data);
        end
    end
    
    %figure; hist(SpatialDistribBranch(br,:)); title(['Branch ' num2str(br) ])
    
    Global(br) = length(find(SpatialDistribBranch(br,:) > 85));
    Local(br) = length(find(SpatialDistribBranch(br,:) < 15));
    Half(br) = length(find(SpatialDistribBranch(br,:) > 40 & SpatialDistribBranch(br,:) < 80));

end


for node = 1:size(NodesInfo,1)
    NodesGlobalvsLocal(node) = Global(NodesInfo(node,1))./Local(NodesInfo(node,1));
    NodesHalfVsRest(node) = Half(NodesInfo(node,1)) ./ ( Global(NodesInfo(node,1)) + Local(NodesInfo(node,1)));
end

figure;
plot_tree(SortedTree,NodesGlobalvsLocal'); shine;
colorbar; title('Global/local')
colormap(cool); caxis([0 1])

% figure;
% plot_tree(SortedTree,NodesHalfVsRest'); shine;
% colorbar; title('half/rest')
% colormap(flipud(cool))

end

