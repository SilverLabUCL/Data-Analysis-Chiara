function [ BranchesSimilar ] = FindSimilarBranches3( tree, threshold, SecondNode,FlagPlot )
%Find branches with similar topology

%% get topology information about the tree
PL=PL_tree(tree); %path length PL
LO=LO_tree(tree); %level order LO

[BranchesInfo, NodesInfo]=dissect_tree(tree);  %finds branches and nodes in each branch

if nargin < 3 %find second node in each branch (first node is branching point)
    PathToRoot=ipar_tree(tree);
    SecondNode=zeros(1,size(BranchesInfo,1));
    
    for br=1:size(BranchesInfo,1)
        BranchingPoint=find(PathToRoot(BranchesInfo(br,2),:)==BranchesInfo(br,1));
        SecondNode(br)=PathToRoot(BranchesInfo(br,2),BranchingPoint-1);
    end
end

if nargin <4
    FlagPlot=true;
end

BranchesSimilar=[];

%% find branches with same PL

%get PL and LO for each branch: for the second node in the branch
PLBranches=PL(SecondNode);
LOBranches=LO(SecondNode);

%find branches with same PL
BinRanges=min(PLBranches): max(PLBranches);
[BinCount, Indexes]=histc(PLBranches,BinRanges);

BinsDouble=find(BinCount>1); %number of branches with same PL
BranchesSamePL=cell(1,length(BinsDouble));

for bG=1:length(BinsDouble)
BranchesSamePL{bG}=find(Indexes==BinsDouble(bG));
end

clear BinCount BinsDouble BinRanges Indexes

%% for branches with same PL, find branches with similar LO
counter=1;
for bG=1:length(BranchesSamePL)
    
    %get LO for branches with same PL
    LO_BranchesSamePL=LOBranches(BranchesSamePL{bG});

    array = LO_BranchesSamePL;
    [sortedArray, Ind] = sort(array);
    nPerGroup = diff(find([1 (diff(sortedArray') > threshold) 1]));
    SortedBr=BranchesSamePL{bG}(Ind);
    groupArray = mat2cell(SortedBr',1,nPerGroup);
    
    for i=1:length(groupArray)
        if length(groupArray{i})>1
            BranchesSimilar{counter}=groupArray{i};
            counter=counter+1;
        end
        
    end

    clear LO_BranchesSamePL array sortedArray Ind SortedBr nPerGroup groupArray
    
end

%% plot branches that are detected as similar

if FlagPlot
    
    NodesSimilar=[];
    
    for Gb=1:(counter-1)
        for br=1: length(BranchesSimilar{Gb})
            NodesSimilar=[NodesSimilar ; find(NodesInfo==BranchesSimilar{Gb}(br))]; 
        end
    end
    
     NodesColor=ones(1,size(NodesInfo,1));
     NodesColor(NodesSimilar)=2;
     
     figure; plot_tree(tree,NodesColor'); caxis([1 2]); colormap(cool);shine
     title('Branches with similar topology')
end


end
