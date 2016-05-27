function [ Onsets, Amplitudes ] = PlotOnsetsDendriticTree( TransientsChar, ResponsesBin, SortedTree, NodesInfo)
% for an experiment (aod stack), find responses that occurred simultaneously
% in more than one branch, and sort them in matrix:
% - Onsets: matrix m x n, m: transients, n: branches. If calcium transient
% m occurred in branch n, Onsets(m,n) contains onset time.
% If the calcium transient m did not occur in branch n then Onsets(m,n) is
% NaN.

% Also plots onsets and amplitudes color-coded on dendritic tree using TREES toolbox.

% find responses that occur simultaneously in multiple branches

% sum recordings for each branch
SumResponses=[0 sum(ResponsesBin,1)];
% find beginning and end of each response in the summation vector
SimultResponses = SumResponses > 1 ;
BegInt = find( diff(SimultResponses) == 1) -1;
EndInt = find( diff(SimultResponses) ==  - 1) -1;

% initialise stuff
n_responses = length(BegInt);
n_segments = length(TransientsChar);
Onsets = NaN(n_responses, n_segments);
Amplitudes = NaN(n_responses, n_segments);
NodesOnset = NaN(1,size(NodesInfo,1));
NodesAmplitudes = NaN(1,size(NodesInfo,1));

% sort responses into matrix onsets
for r = 1:n_responses
    for seg = 1:n_segments
        
        n_events = length(TransientsChar(1,seg).PosMax);
        
        for e = 1:n_events
            if TransientsChar(1,seg).PosMax(e) > BegInt(r) && TransientsChar(1,seg).PosMax(e) < EndInt(r)
                
                Onsets(r,seg) = TransientsChar(1,seg).OnsetApprox(e)*1e-3;
                Amplitudes(r,seg) = TransientsChar(1,seg).Amplitude(e);
                
            end
        end
    end
    
    % attribute onset to each node for the plot
    for node = 1:size(NodesInfo,1)
        NodesOnset(node) = Onsets(r,NodesInfo(node,1));
        NodesAmplitudes(node) = Amplitudes(r,NodesInfo(node,1));
    end
    
    % plot onsets color-coded on dendritic tree
    if sum(isnan(NodesOnset)) < length(NodesOnset)-1 % if at least 2 onset values have been measured
        figure;
        plot_tree(SortedTree); hold on;
        plot_tree(SortedTree,NodesOnset');
        title([ 'Onset response ' num2str(r) ])
        caxis([nanmin(NodesOnset) nanmax(NodesOnset)+1e-5])
        colorbar; colormap(autumn) % autumn colormap is good too here
        shine;
    end
    
    % plot amplitudes color-coded on dendritic tree
    if sum(isnan(NodesAmplitudes)) < length(NodesAmplitudes)-1 % if at least 2 amplitude values have been measured
    figure;
    plot_tree(SortedTree); hold on;
    plot_tree(SortedTree,NodesAmplitudes');
    title([ 'Amplitude response ' num2str(r) ])
    caxis([nanmin(NodesAmplitudes) nanmax(NodesAmplitudes)+1e-5])
    colorbar; colormap(flipud(autumn)) % autumn colormap is good too here
    shine;
    end
end


end

