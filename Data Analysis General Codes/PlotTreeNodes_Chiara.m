function  PlotTreeNodes_Chiara( Tree )
%using TREES toolbox, plot trees with nodes and node numbers

HP=plot_tree(Tree,[],[],[],[],'-3l');
set(HP,'marker','.')

%to label nodes with colors dependent on euclidean distance
n_nodes=length(Tree.X);
vector=1:(n_nodes-1);
Str=num2str(vector');
HP2=vtext_tree(Tree,Str,eucl_tree(Tree),[],[],vector);
set(HP2,'fontname','times new roman')

end

