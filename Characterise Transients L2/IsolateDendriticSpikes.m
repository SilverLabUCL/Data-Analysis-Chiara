function [ DendriticSpikesFinal, bAPsFinal ] = IsolateDendriticSpikes( ResponsesBin, Segments)
% remove bAPs from dendritic responses

n_segments = length(Segments);
DendriticSpikes = zeros(size(ResponsesBin,1), size(ResponsesBin,2)+1);
bAPs = zeros(size(ResponsesBin,1), size(ResponsesBin,2)+1);

APs = [0 ResponsesBin(1,:)]; %action potentials in soma

for s = 1:n_segments
    
    % sum dendritic responses with APs
    SumResponses = [0 ResponsesBin(Segments(s),:)] + APs ;
    
    bAPs(Segments(s),:) = SumResponses > 1;
    
    % make it cleaner, i.e. with perfect overlapping of responses
    Zeros = (SumResponses>0);
    DiffZeros = diff(Zeros);
    StartR = find( DiffZeros == 1);
    EndR = find( DiffZeros == -1);
    
    SumResponsesCleaner = zeros(1,length(SumResponses));
    for i = 1:length(StartR)
        SumResponsesCleaner(StartR(i)+1 : EndR(i))= max(SumResponses(StartR(i):EndR(i)));
    end
    
    % take only events that happened only in the dendrite
    DendriticSpikes(Segments(s), SumResponsesCleaner == 1) = 1;
    DendriticSpikes(Segments(s),:) = (DendriticSpikes(Segments(s),:) - APs) > 0;
    
end

% get rid of zeros added at the beginning
bAPsFinal = bAPs(:,2:end);
DendriticSpikesFinal = DendriticSpikes(:,2:end);


end

