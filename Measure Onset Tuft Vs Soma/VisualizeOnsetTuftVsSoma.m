
function [SomaDS, TuftDS, TimeConcat] = VisualizeOnsetTuftVsSoma

% this function allows to compare the onset of the calcium transients in the soma and in the tuft. It plots activity for tuft and soma on same fine temporal
% scale, and applies low-pas filtering.

%% parameters

TimePerPoint = 28.5; % AOD fill time in microsecond, 28.5 for rig3, 28 for rig2

% parameters for filtering
Pol = 5; % degree of polynomial used for fitting
Win = 100; % time window, in ms in number of POIs

%% load data

[DataGreenCh, PointsInSegments] = LoadData;

%% interpolate data to have the same temporal scale

[Green, TimeScale] = SameTimeScale(DataGreenCh, TimePerPoint);

%% average pois in same compartment

Soma = squeeze(mean(Green(:,PointsInSegments{1},:),2));

POIsTuft = [];
for seg = 3:5%3:length(PointsInSegments)
    POIsTuft = [POIsTuft; PointsInSegments{seg}];
end
Tuft = squeeze(mean(Green(:,POIsTuft,:),2));

% concatenate trials
Tuft = reshape(Tuft',1,[]);
Soma = reshape(Soma',1,[]);

TimeConcat = zeros(1, length(Tuft));
for t = 1:size(DataGreenCh,1) % for each trial
    TimeConcat( length(TimeScale)*(t-1) + 1 : length(TimeScale)*t) = TimeScale + TimeScale(length(TimeScale))*(t-1);
end

%% calculate deltaf/f and use low pass filter

% calculate deltaF/F
TuftD = CalculateDf(Tuft);
SomaD = CalculateDf(Soma);

% calculate window for filtering: from ms to timepoints
n_POIs = size(DataGreenCh,2);
Win = round(Win/(n_POIs*TimePerPoint*1e-3));
if mod(Win,2) == 0  % Window needs to be an odd number
    Win = Win +1;
end

% low-pass filter
SomaDS = sgolayfilt(SomaD,Pol,Win);
TuftDS = sgolayfilt(TuftD,Pol,Win);

%% plot

% before and after low-pass filtering
%figure; plot(TimeConcat*1e-3,SomaD,'b'); hold on; plot(TimeConcat*1e-3,SomaDS,'r'); title('Soma')
%figure; plot(TimeConcat*1e-3,TuftD,'b'); hold on; plot(TimeConcat*1e-3,TuftDS,'r'); title('Tuft')
% soma and tuft overlayed
figure;
plot(TimeConcat*1e-3,SomaDS,'r');
hold on;
plot(TimeConcat*1e-3,TuftDS,'b');
title('Soma RED, tuft BLUE')

figure;
plot(SomaDS,'r');
hold on;
plot(TuftDS,'b');
title('Soma RED, tuft BLUE')

end

function [DataGreenCh, PointsInSegments] = LoadData

load('pointTraces.mat', 'DataGreenCh','Times')

files = dir('*.mat');
counter = 0;
for f = 1:length(files)
    if strcmp(files(f).name(1:4),'PutP') == 1
        filePoints = files(f).name;
        counter = counter+1;
    end
end

if counter ~= 1
    [filePoints, PathName]=uigetfile('*.mat','Select the file with the data that attributes imaged POIs to dendritic branches');
    load([PathName filePoints],'PointsInSegments')
else
    load(filePoints,'PointsInSegments')
end
end

function Df = CalculateDf(Data)
%remove higher 70% and lower 20% of the values
HighLim=prctile(Data,70);
LowLim=prctile(Data,20);
SortedVal=Data(Data>LowLim);
SortedVal=SortedVal(SortedVal<HighLim);
Baseline=nanmean(SortedVal);
% normalize
Df = (Data - Baseline)./Baseline;
end

function [Green, TimeScale ] = SameTimeScale(DataGreenCh, AODFill)

AODFill = AODFill*1e-3;
n_points = size(DataGreenCh,2);
n_trials = size(DataGreenCh,1);
n_timepoints = size(DataGreenCh,3);
CycleTime = n_points*AODFill;

% find times for each point
Times = zeros(n_points,n_timepoints);
for pp = 1:n_points
    Times(pp,:) = (pp-1)*AODFill : CycleTime : ((pp-1)*AODFill + n_timepoints*CycleTime - CycleTime);
end

% interpolate
TimeScale = Times( round(n_points/2) ,:);
Green = NaN(n_trials, n_points, n_timepoints);
for pp = 1:n_points
    for t = 1:n_trials
        Green(t,pp,:) = interp1(Times(pp,:),squeeze(DataGreenCh(t,pp,:)), TimeScale,'spline');
    end
end

end


