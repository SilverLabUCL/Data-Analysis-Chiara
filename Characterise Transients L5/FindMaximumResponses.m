function [ Amplitudes, PosMax, AmplitudesDetec, PosMaxDetec, ResponsesBin ] = FindMaximumResponses( Detec, Thr, data, Shift, FlagPlot)
%Find maximum and amplitudes of responses are detected with detection criterion from Bekkers and Clements
%algorithm (published 1991)

% create binary vector Responses
DetectionCriterion=[0 Detec]; %add a zero to compute diff between each element
ResponsesBin=DetectionCriterion>Thr;

% measure amplitude of responses and position of the maximum
ResponsesIndexes=find(diff(ResponsesBin)~=0);

for r=1:2:length(ResponsesIndexes)
    
    %find maximum in original data
    if ResponsesIndexes(r+1)+ Shift <= length(data) % need to add shift because in detection criterion responses are shifted proportinally to rise time
        [Amplitudes((r-1)/2+1), PosMax((r-1)/2+1)]=max(data(ResponsesIndexes(r):ResponsesIndexes(r+1)+Shift));
    else
        [Amplitudes((r-1)/2+1), PosMax((r-1)/2+1)]=max(data(ResponsesIndexes(r):end));
    end
    PosMax((r-1)/2+1)=PosMax((r-1)/2+1) + ResponsesIndexes(r) -1;
    
    %find maximum in detect criterion
    [AmplitudesDetec((r-1)/2+1), PosMaxDetec((r-1)/2+1)]=max(DetectionCriterion(ResponsesIndexes(r):ResponsesIndexes(r+1)));
    PosMaxDetec((r-1)/2+1)=PosMaxDetec((r-1)/2+1) + ResponsesIndexes(r) -2;
    
end

ResponsesBin(1)=[]; %remove first element added at the beginning

% plot

if FlagPlot
    
    figure;
    plot(1:numel(data),data, PosMax, Amplitudes, 'r.','MarkerSize',20)
    title('Maximum')
    
end

end

