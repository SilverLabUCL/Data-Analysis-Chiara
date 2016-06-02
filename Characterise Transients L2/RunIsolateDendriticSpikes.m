function [ DendriticSpikesFinal, bAPsFinal ] = RunIsolateDendriticSpikes( PathData, FlagSave, FileLoaded )
% separate dendritic spikes from bAPs and measure spatial distribution in
% both cases

if nargin < 1
    PathData = pwd;
end

if nargin < 2
    FlagSave = true;
end

if nargin < 3
    % load data
    cd(PathData)
    MatFiles = dir('*.mat');
    ccc = 0;
    for ffff = 1:length(MatFiles)
        if strcmp(MatFiles(ffff).name(1:4), 'Char') == 1
            ccc = ccc + 1;
            FileLoaded = MatFiles(ffff).name;
        end
    end
    
    if ccc ~= 1 % if more than one mat char file
        [filename,pathname] = uigetfile('*.mat'); %the user needs to load a file with TransientsChar information
        FileLoaded=[pathname filename];
    end
end

OriginalFolder = pwd;

load(FileLoaded,'ResponsesBin','Segments','TransientsChar')

% separate dendritic spikes and bAPs
[ DendriticSpikesFinal, bAPsFinal ] = IsolateDendriticSpikes( ResponsesBin, Segments);

% find branches that are active during each AP
[ BranchesActivebAPs, BAPSVal ] = WherebAPs( ResponsesBin, Segments, TransientsChar,0);

% find branches that are active during a dendritic spike
[ BranchesActiveDSPIKE, DSPIKEAmpl, DSPIKESInt ] = PlotBranchesActive(0, DendriticSpikesFinal, Segments, TransientsChar, 0, [], []);

% plot spatial distribution of both
[~, ResponsesDistPercAll] = SpatialDistributionSpikesL2( ResponsesBin(2:end,:), Segments(2:end), TransientsChar, 1 );
for h = (gcf - 2) : gcf
    figure(h); title('All Responses')
end

if sum(sum(DendriticSpikesFinal)) > 0
[~, ResponsesDistPercdSpike] = SpatialDistributionSpikesL2( DendriticSpikesFinal(2:end,:), Segments(2:end), TransientsChar, 1 );
for h = (gcf - 2) : gcf
    figure(h); title('Dendritic Spikes')
end
else
    ResponsesDistPercdSpike = NaN;
end

if sum(sum(bAPsFinal)) > 0
    [~, ResponsesDistPercbAP] = SpatialDistributionSpikesL2( bAPsFinal(2:end,:), Segments(2:end), TransientsChar, 1 );
    for h = (gcf - 2) : gcf
        figure(h); title('bAPs')
    end
else
    ResponsesDistPercbAP = NaN;
end
% save
if FlagSave
    D = date;
    save('IsolateDendSpike.mat')
    
    % save figures
    Im = gcf;
    saveas(Im-1,'SpatialDistribEventsPercentageBAPS.fig')
    saveas(Im-4,'SpatialDistribEventsPercentageDSPIKE.fig')
end

cd(OriginalFolder)
end

