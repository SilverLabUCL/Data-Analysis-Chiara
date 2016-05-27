function  PlotTreeBranches_Chiara( Tree )
%using TREES toolbox, plot trees with branch numbers

[~, NodesInfo]=dissect_tree(Tree);

figure; 
HP = plot_tree(Tree,NodesInfo(:,1),[],[],[],'-3l'); 
shine; axis off
set(HP,'marker','.')

String = num2str(NodesInfo(:,1));
HP2 = vtext_tree(Tree,String,[0 0 0]);
set(HP2,'fontname','times new roman')

end

