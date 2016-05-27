function [ SpatialDistribStatAll, SpatialDistribRunAll, SpatialDistribStat , SpatialDistribRun ] = SpatialDistribRunStatL2(nStacks, FlagSave, FilesLoaded)
%Measure spatial distribution of calcium events separately for running and
%stationary periods

% parameters and initialise stuff

if nargin < 3
    FilesLoaded = cell(nStacks,1);
end

ThresholdRunningRPM = 5; % 1 rotation= 16 cm
SpatialDistribRun = cell(nStacks,1);
SpatialDistribStat = cell(nStacks,1);
TotRunTime = 0;
TotStatTime = 0;

for s = 1:nStacks
    
    % load data
    [ ResponsesBin, Times_Lin, Segments, Speed, TimesSpeed, FilesLoaded{s,1} ] = LoadResponsesSpeedData(FilesLoaded{s,1});
    
    % convert speed to same temporal scale as responses
    TimesResp = mean(Times_Lin(Segments,:),1);
    SpeedInt = interp1(TimesSpeed, Speed, TimesResp);
    SpeedInt = [SpeedInt(1) SpeedInt]; % add one element at the beginning because need to add element for responses
    
    % find running periods
    TimesRun = SpeedInt > ThresholdRunningRPM;
    TimesStat = SpeedInt < ThresholdRunningRPM;
    TotRunTime = sum(TimesRun)*diff(TimesResp(1:2))*1e-3 + TotRunTime; %total time mouse runs, in seconds
    TotStatTime = sum(TimesStat)*diff(TimesResp(1:2))*1e-3 + TotStatTime; %total time mouse is stationary, in seconds

    % find spatial distribution of responses during running periods
    [SumResponses, Start, End] = SumResponsesFunction(ResponsesBin(2:end,:)); % computes vector with summation of responses, and indexes of beginning and end of each response 
    [DistribRun, DistribStat] = FindResponsesRun(SumResponses, Start, End, TimesRun); 
    
    % convert to % of branches 
    n_branches = length(Segments)-1;
    DistribRunP = DistribRun./n_branches*100;
    DistribStatP = DistribStat./n_branches*100;
    
    % store the data for this stack
    SpatialDistribRun{s} = DistribRunP;
    SpatialDistribStat{s} = DistribStatP;
    
    clear SpeedInt TimesRun TimesStat 
    
end

% convert from cell to vector
[SpatialDistribRunAll] = ConvertCellToVec( SpatialDistribRun );
[SpatialDistribStatAll] = ConvertCellToVec( SpatialDistribStat);

% plot
figure;
hist(SpatialDistribStatAll,10)
title(['Spatial distribution, stationary. Number of events: ' num2str(length(SpatialDistribStatAll)) '. Total time stationary: ' num2str(TotStatTime) ' s'])

figure;
hist(SpatialDistribRunAll,10)
title(['Spatial distribution, running. Number of events: ' num2str( length(SpatialDistribRunAll) ) '. Total time running: ' num2str(TotRunTime) ' s'])

% save
if FlagSave
    % save date and data
    Date = date;
    save(['SpatialDistribRunStat' date ' .mat' ])
    %save figures
    saveas(gcf, 'SpatialDistrib Running.fig')
    saveas(gcf-1, 'SpatialDistrib Stat.fig')
end

end


function [ ResponsesBin, Times_Lin, Segments, speed, time, FilesLoaded ] = LoadResponsesSpeedData(FilesLoaded)

if isempty(FilesLoaded) == 1
    % the user loads a file that contains TransientsChar
    [filename,pathname]=uigetfile('*.mat');
    FilesLoaded=[pathname filename];
else
    pathname = FilesLoaded(1: find(FilesLoaded == '\', 1, 'last'));
end

% mat files
PathSpeed = pathname(1: find(pathname == '\', 2,'last') );
load(FilesLoaded,'ResponsesBin', 'Times_Lin', 'Segments')
load([PathSpeed 'SpeedConcat.mat'],'speed','time')

end

function [SumResponses, Start, End] = SumResponsesFunction(Responses)

% sum recordings for each branch
SumResponses=[0 sum(Responses,1)];
% find beginning and end of each response in the summation vector
Zeros=(SumResponses>0);
DiffZeros=diff(Zeros);
Start=find( DiffZeros == 1) + 1;
End=find( DiffZeros == -1);

if length(Start) ~= length(End) 
    disp('ERROR IN FINDING BEGINNING AND END OF RESPONSES')
end

end

function [DistribRun, DistribStat] = FindResponsesRun(SumResponses, Start, End, TimesRun)

DistribRun = [];
DistribStat = [];

CounterRun = 1; 
CounterStat = 1;

for r = 1:length(Start) %for each response

    SpeedBin = sum(TimesRun(Start(r) : End(r) ));
    
    if SpeedBin >= ( length(TimesRun(Start(r) : End(r) ))*0.7) % if animal runs most of the time during the response
        
        DistribRun(CounterRun) = max( SumResponses(Start(r) : End(r)) );
        CounterRun = CounterRun + 1;
        
    elseif SpeedBin <= ( length(TimesRun(Start(r) : End(r) ))*0.2) % if animal is stationary most of the time during the response
    
        DistribStat(CounterStat) = max( SumResponses(Start(r) : End(r)) );
        CounterStat = CounterStat + 1;
    
    end
end

end


function [Vector] = ConvertCellToVec (CellArray)

n_cells = length(CellArray);
counter = 1;

for c = 1:n_cells
    
    Vector( counter : counter + length(CellArray{c})-1 )= CellArray{c}; 
    counter = counter + length(CellArray{c});
    
end

end
