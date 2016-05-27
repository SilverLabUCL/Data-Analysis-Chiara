function [TransientsChar, ResponsesDistPerc, ResponsesDist] = SpatialDistributionSpikes3( Responses, Segments, TransientsChar, FlagPlot )
% measure spatial distribution (in % of imaged branches) for each dendritic event.

% - Responses: binary version of data, with ones if there is a response
% - TransientsChar: structure with an element per each segment and a field
% PosMax with the index of the element where the max of each response is

% returns TransientChar with additional field Distribution
% and ResponsesDist: list of events in the dendritic tree with its spatial
% distribution

%% default inputs 

if nargin <3
    FlagPlot=1;
end

%% for each response, find in how many branches it occurred simultaneously

% sum recordings for each branch
SumResponses=[0 sum(Responses,1)];
% find beginning and end of each response in the summation vector
Zeros=(SumResponses>0);
DiffZeros=diff(Zeros);
StartR=find( DiffZeros == 1);
EndR=find( DiffZeros == -1);

ResponsesDist=zeros(1,length(StartR));
SumResponsesCleaner=zeros(1,length(SumResponses));
for i=1:length(StartR)
    SumResponsesCleaner(StartR(i)+1 : EndR(i))= max(SumResponses(StartR(i):EndR(i)));
    ResponsesDist(i)=max(SumResponses(StartR(i):EndR(i)));
end

%% convert spatial distribution of responses from number of branches into % of branches 

n_branches=length(Segments);

Distrib=SumResponsesCleaner./n_branches*100;
Distrib(1)=[]; %correct for zero added before in SumResponses

ResponsesDistPerc=ResponsesDist./n_branches*100;

%% attribute each response to its spatial distribution

for seg=1:length(TransientsChar)
    for e=1:length(TransientsChar(1,seg).PosMaxInDetec)
        TransientsChar(1,seg).Distribution(e) = Distrib(  TransientsChar(1,seg).PosMaxInDetec(e) );
    end
end

%% plot
if FlagPlot
    
    figure;
    plot(SumResponses);
    xlabel('Time, timepoints'), ylabel('Number of branches active')
    
    figure; 
    hist(ResponsesDistPerc) %hist(ResponsesDist,n_branches)
    xlabel('% of branches co-active'), ylabel('Number of events')
    xlim([0 110])
    
    figure; 
    hist(ResponsesDist) %hist(ResponsesDist,n_branches)
    xlabel('Number of branches co-active'), ylabel('Number of events')
    xlim([0 n_branches+1])
end

end

