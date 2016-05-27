function [ BranchesSimilar, Angles] = AdjustSimilarBranches3( tree,threshold,FlagPlot )
%find branches that are detected as similar in sort_tree, and calculate the
%angle between them
%(option -lo)

%call the function FindSimilarBranches3

%uses TREES toolbox from Hermann Cuntz and Michael Hausser lab 

%% set default inputs and parameters

% global trees

if nargin <3
    FlagPlot=true;
end

% if nargin ==0 
%     if exist('trees','var')==1
%         tree=trees{1,end};
%     else
%         disp('Error!! No tree to analyse!')
%     end
% end

%% get information about the tree

[BranchesInfo, ~]=dissect_tree(tree);  %finds branches and nodes in each branch
ParentNodes=idpar_tree(tree); %parent nodes of each node
PathToRoot=ipar_tree(tree); %matrix with path to root for each node
n_branches=size(BranchesInfo,1);

%find second and third node in each branch (first node is branching point)
SecondNode=ones(1,n_branches);
ThirdNode=ones(1,n_branches);
for br=2:n_branches
    BranchingPoint=find(PathToRoot(BranchesInfo(br,2),:)==BranchesInfo(br,1));
    SecondNode(br)=PathToRoot(BranchesInfo(br,2),BranchingPoint-1);
    if BranchingPoint>2
        ThirdNode(br)=PathToRoot(BranchesInfo(br,2),BranchingPoint-2);
    else
        ThirdNode(br)=SecondNode(br);
    end
end

%% find branches with similar topology

[ BranchesSimilar ] = FindSimilarBranches3( tree, threshold, SecondNode,FlagPlot );
n_GroupsSimilarBranches=length(BranchesSimilar);

%% calculate angle of each branch compared to a reference (father branch)
Angles=cell(1,n_GroupsSimilarBranches);

for g=1:n_GroupsSimilarBranches
    
    Angle=zeros(1,length(BranchesSimilar{g}));
    BranchingPoint=BranchesInfo(BranchesSimilar{g},1);
   
        Ref=ParentNodes(BranchingPoint(1)); %how do I pick up the reference for star-shaped trees? need to have always same root, like the basis of apical dendrites.
        Refx1=tree.X(BranchingPoint(1));
        Refy1=tree.Y(BranchingPoint(1));
        Refx2=tree.X(Ref);
        Refy2=tree.Y(Ref);
        
        for br=1:length(BranchesSimilar{g})
            Brx1=Refx1;
            Bry1=Refy1;
            Brx2=tree.X(ThirdNode(BranchesSimilar{g}(br))); 
            Bry2=tree.Y(ThirdNode(BranchesSimilar{g}(br)));
            
            [ ~,Angle(br) ] = MeasureAngleLines( Refx1, Refy1, Refx2, Refy2, Brx1, Bry1, Brx2,Bry2);
        end
    Angles{g}=Angle;
end


end

