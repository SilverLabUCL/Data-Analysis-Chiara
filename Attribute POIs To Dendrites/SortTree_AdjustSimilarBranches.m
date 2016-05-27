function [ MatrixToSortNeuron,threshold, BranchesSimilar ] = SortTree_AdjustSimilarBranches( tree, threshold )
%helps sorting dendritic trees in unique way

%when sort_tree from TREES toolbox is used, dendritic branches with same
%topological properties are not distinguished properly, so this function
%can be called inside the sort_treeChiara function and, for each branch with the same topology, it adds information
%about the angle of the branch with its father branch

%set the threshold to consider two branches similar topologically:
if nargin < 2
    threshold=1e6; % good value could be 100/250 for tracing with Vaa3d, 1000/2000 for tracing with neuTube. Higher value -> more similar branches detected
end

%measure topology of the tree
PL = PL_tree (tree); %path length for each node
LO = LO_tree (tree); % level order for each node
[~, NodesInfo]=dissect_tree(tree);

%call function that calculates angles for branches with similar topology
[ BranchesSimilar, AnglesSimilarBranches ] = AdjustSimilarBranches3( tree,threshold,true);

%build vector with angles
n_nodes=size(tree.X,1);
Angles=ones(n_nodes,1);
LOCorrected=LO;

for bg=1:length(BranchesSimilar)
    for br=1:size(BranchesSimilar{bg},2)
        
        Nodes=find(NodesInfo(:,1)==BranchesSimilar{bg}(br));
        Angles(Nodes)=AnglesSimilarBranches{bg}(br);
        
        %write same LO for all similar branches so they will be sorted by
        %angle and not by LO
        if br==1
            LONode1=LO(Nodes(1));
        end
        LOCorrected(Nodes)=LONode1;
        
        clear Nodes
    end
end


%form matrix to sort
MatrixToSortNeuron=[PL LOCorrected Angles];


end

