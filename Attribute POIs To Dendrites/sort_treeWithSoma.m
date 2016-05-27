function [ SortedTree ] = sort_treeWithSoma( tree, threshold )
% sorts a dendritic tree with a soma in a way such that branch IDs are assigned based on branching
% patterns (topology) and angles between branches

% it generates matrix MatrixToSortNeuron that is then used by
% sort_treeChiaraMatrixInput that sorts the tree

% MatrixToSortNeuron(node, property): for each node, gives:
% - 1st column: angle of first order branch with a vertical line
% - 2nd column: topological path length, from function PL_tree in TREES toolbox
% - 3rd column: level order values, from LO_tree in TREES toolbox
% - 4th column: angle between 2 branches if they have very similar
% topological properties

% NB soma has to be described as one node equal to the root (node 1)

%% set the threshold to consider two branches similar topologically. Might need adjusting depending on stack/experiment

if nargin < 2
    threshold = 1e6; % good value could be 100/250. Higher value -> more similar branches detected
end

%% beginning stuff

% get general information about the tree
n_nodes = length(tree.X); % number of nodes
PathToRoot=ipar_tree(tree); % matrix with path to root for each node

MatrixToSortNeuron = NaN(n_nodes, 4);

%% first column of MatrixToSortNeuron: angle of first order branch with a vertical line

% assign angle of first order branches
[ AnglePrimaryBranches, node_PrimaryBranches ] = AnglesPrimaryBranches(tree);

% update MatrixToSortNeuron
for br = 2:length(node_PrimaryBranches) % starts from 2 because first node is the root
    [nodesDownStream, ~] = find(PathToRoot == node_PrimaryBranches(br) ); % nodes downstream each primary branch
    MatrixToSortNeuron(nodesDownStream, 1) = AnglePrimaryBranches(br);
    clear nodesDownStream
end
MatrixToSortNeuron(1,1) = 0; % angle = 0 assigned to the root

%% second and third column of MatrixToSortNeuron: topological path length and level order values

MatrixToSortNeuron(:,2) = PL_tree(tree);
MatrixToSortNeuron(:,3) = LO_tree(tree);

%% find branches with similar topology (and derived from the same first order branch)

for br = 2:length(node_PrimaryBranches) % for each subtree at the time
    
    % find similar branches in a subtree, and calculate angle between them
    [ SubNodes, SubTree ] = sub_tree(tree, node_PrimaryBranches(br) ); % create a subtree for each primary branch
    SubNodes = find(SubNodes); % nodes in subtree
    [ SubMatrixToSortNeuron, ~, BranchesSimilar ] = SortTree_AdjustSimilarBranches( SubTree, threshold ); % measure angle between branches with similar topology
    MatrixToSortNeuron(SubNodes ,4) = SubMatrixToSortNeuron(:,3); % add angle information to MatrixToSortNeuron
    
    % for similar branches, write same LO so they are sorted according to angle
    [ ~, SubNodesInfo ] = dissect_tree(SubTree);
    for group = 1:length(BranchesSimilar)
        NodesSimilar = [];
        for branch = 1:size(BranchesSimilar{group},2)
            NodesSimilar = [NodesSimilar;  SubNodes( find(SubNodesInfo(:,1) == BranchesSimilar{1,group}(branch)) )];
        end
        
        MatrixToSortNeuron(NodesSimilar, 3) = MatrixToSortNeuron(NodesSimilar(1), 3);
    end
end

%% sort tree

SortedTree = sort_treeChiaraMatrixInput (tree, MatrixToSortNeuron, '-LO');

end


function [ AnglePrimaryBranches, node_PrimaryBranches ] = AnglesPrimaryBranches(tree)
% determine angle between each "primary branch" ( = first order branches)
% and a vertical line starting from the soma ( = root of the tree)

% get characteristics of tree
ParentNodes = idpar_tree(tree); % parent nodes of each node

% find first node of each primary branch
node_PrimaryBranches = find(ParentNodes == 1);

AnglePrimaryBranches = NaN(1, length(node_PrimaryBranches));

% points that will be used to determine angle
RefX1 = tree.X(1); % reference vector is a vertical line from root
RefY1 = tree.Y(1);
RefX2 = tree.X(1);
RefY2 = tree.Y(1) + 10;
BrX1 =  tree.X(1); % second vector, first point is root, second point is first node in the primary branch
BrY1 =  tree.Y(1);

% calculate angle
for br = 2:length(node_PrimaryBranches) % starts from 2 because first node is the root
    [ ~, AnglePrimaryBranches(br)] = MeasureAngleLines( RefX1, RefY1, RefX2, RefY2, BrX1, BrY1, tree.X(node_PrimaryBranches(br)),tree.Y(node_PrimaryBranches(br)));
end
end
