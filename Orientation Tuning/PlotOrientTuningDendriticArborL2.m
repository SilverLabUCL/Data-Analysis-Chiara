function [ NodesOSI, NodesPreferredOrient] = PlotOrientTuningDendriticArborL2(TreeFile)
%This function plots dendritic arbour color-coded for orientation
%selectivity index (OSI), direction selectivity index and (for tuned neurons) preferred
%orientation

% L2 version draws a soma at node 1

%load orientation tuning data
load('OrTuning.mat')
load('OSI.mat')

% %load dendritic tree and sort it with TREES toolbox
% start_trees
% load_tree
% %if Z-stack images are loaded into vaa3d in 16-bit format instead of 8-bit,
% %y axis is reverted: in this case, correct y coordinates:
% %trees{1,1}.Y=FrameSize-trees{1,1}.Y;
% %sort tree, relabel nodes and identify branches
% SortedTree=repair_tree(trees{1,1});
% [~, NodesInfo]=dissect_tree(SortedTree);

% load points file with tree info
if nargin < 1
    [FileName, PathName]=uigetfile('*.mat','Select a file with information about the dendritic tree');
    TreeFile=[PathName FileName];
end
load(TreeFile, 'SortedTree', 'NodesInfo')

n_nodes=size(NodesInfo,1);

%attribute preferred orientation and OSI to each node
NodesOSI=NaN(n_nodes,1);
NodesDI=NaN(n_nodes,1);
NodesPreferredOrient=NaN(n_nodes,1);

for n=1:n_nodes
    
    NodesOSI(n)=OSI(NodesInfo(n,1));
    
    if NodesOSI(n) > 0.4
        NodesPreferredOrient(n)=best_ori(NodesInfo(n,1));
        NodesDI(n)=DI(NodesInfo(n,1));
    elseif isnan(NodesOSI(n)) == 1
        NodesDI(n)=NaN;
    else
        NodesDI(n)=0;
    end
    
end

%create map for plot
for OrInd=1:10
    map(OrInd,1:3)=[0.1*OrInd,0,0];
end


%plot orientation selectivity index
figure;
plot_tree(SortedTree,[0 0 0],[],[],[],'-3l');
hold on;
plot_tree(SortedTree,NodesOSI); shine;
hold on;
colormap(map)
colorbar
title('Orientation Selectivity Index')
axis tight; axis off
caxis([0 1])

%plot direction selectivity index
figure;
plot_tree(SortedTree,[0 0 0],[],[],[],'-3l');
hold on;
plot_tree(SortedTree,NodesDI);shine;
colormap(map)
colorbar
title('Direction Selectivity Index')
axis tight; axis off
caxis([0 1])

%plot preferred orientation
OrSequence = [0 45 90 135];
CMap = jet(4);
figure;
plot_tree(SortedTree,[0.5 0.5 0.5]);shine;
hold all;
plot_tree(SortedTree,NodesPreferredOrient);shine;
hold all;
%PloTCircle(SortedTree.X(1),SortedTree.Y(1), max(SortedTree.Z)+1,10,CMap( find(best_ori(1)==OrSequence),1:3))
colormap(CMap)
caxis([0 135])
colorbar
title('Preferred Orientation')
axis off

%save figures in current folder
h=gcf;

saveas(h,'DendriticTreePreferOr.fig')
saveas(h-1,'DendriticTreeDI.fig')
saveas(h-2,'DendriticTreeOSI.fig')

end

