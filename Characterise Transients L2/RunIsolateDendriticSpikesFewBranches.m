function [ DendriticSpikesFinal, bAPsFinal ] = RunIsolateDendriticSpikesFewBranches( Branches, PathData, FlagSave, FileLoaded )
% separate dendritic spikes from bAPs and measure spatial distribution in
% both cases
% here considers only few branches (for example apical branches)

if nargin < 2
    PathData = pwd;
end

if nargin < 3
    FlagSave = true;
end

if nargin < 4
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

% keep only data for branches selected
RespTemp = zeros(size(ResponsesBin,1),size(ResponsesBin,2));
RespTemp([1 Branches],:) = ResponsesBin([1 Branches],:);
ResponsesBin = RespTemp;

NewSegments = ismember(Branches, Segments);
Segments = Branches(NewSegments)';

% separate dendritic spikes and bAPs
[ DendriticSpikesFinal, bAPsFinal ] = IsolateDendriticSpikes( ResponsesBin, Segments);

% find branches that are active during each AP
[ BranchesActivebAPs, BAPSVal ] = WherebAPs( ResponsesBin, Segments, TransientsChar,0);

% find branches that are active during a dendritic spike
[ BranchesActiveDSPIKE, DSPIKEAmpl, DSPIKESInt ] = PlotBranchesActive(0, DendriticSpikesFinal, Segments, TransientsChar, 0, [], []);

% plot spatial distribution of both
[~, ResponsesDistPercAll] = SpatialDistributionSpikesL2( ResponsesBin, Segments, TransientsChar, 1 );
for h = (gcf - 2) : gcf
    figure(h); title('All Responses')
end

if sum(sum(DendriticSpikesFinal)) > 0
[~, ResponsesDistPercdSpike] = SpatialDistributionSpikesL2( DendriticSpikesFinal, Segments, TransientsChar, 1 );
for h = (gcf - 2) : gcf
    figure(h); title('Dendritic Spikes')
end
else
    ResponsesDistPercdSpike = NaN;
end

if sum(sum(bAPsFinal)) > 0
    [~, ResponsesDistPercbAP] = SpatialDistributionSpikesL2( bAPsFinal, Segments, TransientsChar, 1 );
    for h = (gcf - 2) : gcf
        figure(h); title('bAPs')
    end
else
    ResponsesDistPercbAP = NaN;
end
% save
if FlagSave
    D = date;
    save(['IsolateDendSpike Br ' num2str(Branches) '.mat']) 
    
    Im = gcf;
    saveas(Im-1,'SpatialDistribEventsPercentageFewBranchesBAPS.fig')
    saveas(Im-4,'SpatialDistribEventsPercentageFewBranchesDSPIKE.fig')
end

cd(OriginalFolder)
end

