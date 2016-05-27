function [ bAPs, BAPSVal ] = WherebAPs( ResponsesBin, Segments, TransientsChar, FlagPlot, Tree )
% plot branches where there was a bAP

% % output: 
% - bAPs: cell where each element corresponds to a AP and it gives the ID of the active branches
% - BAPSVal: matrix(bAP,2): for each bAP, gives first amplitude then integral

if FlagPlot == 0
    Tree = [];
end

n_segments = length(Segments);

% find beginning and end of each AP
APs = [0 ResponsesBin(1,:)];
Zeros = (APs>0);
DiffZeros = diff(Zeros);
StartAP = find( DiffZeros == 1);
EndAP = find( DiffZeros == -1) ;

n_APs = length(StartAP);
SumResponses = zeros(n_segments,size(ResponsesBin,2)+1);

% store amplitude and integral of eachBAP
BAPSVal(1:length(StartAP),1) = TransientsChar(1,1).Amplitude;
BAPSVal(1:length(StartAP),2) = TransientsChar(1,1).Integral;

% sum AP train with responses of each branch
for s = 1:n_segments
    SumResponses(s,:) = APs + [0 ResponsesBin(Segments(s),:)];
end

bAPs = cell(n_APs,1);

% find APs in each segment
for A = 1:n_APs
    counter = 0;
    for s = 1:n_segments
        
        FindAP = find(SumResponses(s, StartAP(A):EndAP(A)) == 2);
        
        if length(FindAP) > 2
            counter = counter + 1;
            bAPs{A}(counter) = Segments(s);
        end
    end
end

% plot tree with branches active for each AP
if FlagPlot
    
    cMap = [1 1 1; 1 1 0.5; 1 0.4 0]; % colormap
    
    [~, NodesInfo]=dissect_tree(Tree); % get nodes info for the tree
    
    NodesActivity = zeros(1,size(NodesInfo,1));
    ActivityBranch = zeros(1,size(ResponsesBin,1));
    
    for A = 1:n_APs 
        
        ActivityBranch(Segments) = 1;
        ActivityBranch(bAPs{A}) = 2;
        
        for node=1:size(NodesInfo,1)
            NodesActivity(node)=ActivityBranch(NodesInfo(node,1));
        end
        
        figure;
        plot_tree(Tree,NodesActivity');
        shine;
        colormap(cMap)
        title(['bAP ' num2str(A)])
        
    end
end

end

