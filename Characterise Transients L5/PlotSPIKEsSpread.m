function PlotSPIKEsSpread( nStacks, FlagSave, ScalingFactorInfo, FilesLoaded, TreeLoaded )
% Plots distance from the soma and number of bAPs, and also number of
% branches coactive versus amplitude BAPs

% input SCALING FACTOR: scale z to make it proportional to x and y,
% otherwise z is in number of planes.
% Write in a vector:

% 1. frame size (usually 511 pixels)
% 2. size of the field of view (usually on rig2 220um)
% 3. Z step in microns

% To scale z correctly, the conversion factor is calculated as the Z-step of the Z Stack in pixels, and the
% conversion from microns to pixel can be obtained by knowing the size of
% the field of view in xy and the number of pixels in xy.
% need to scale tree when calculating euclidean distance between branches

if nargin < 2
    FlagSave = 1;
end

if nargin < 3
    FlagConversion = 0;
    ConversionFactor = 1; % do not convert pixels to microns
else
    FlagConversion = 1;
    ConversionFactor = ScalingFactorInfo(2)/ScalingFactorInfo(1); % conversion from pixel to microns
end

% initialise stuff
n_segments = NaN(nStacks,1);
BranchesActiveAll = [];
Ampl = [];
Integr = [];
N_BranchesActive = NaN(nStacks,1);
counter = 0;


%% load data

% load file with tree info
if nargin < 5
    [FileName, PathName] = uigetfile('*.mat',['Select the file with the data for the dendritic tree']);
    TreeLoaded = [PathName FileName];
end
load(TreeLoaded, 'SortedTree', 'NodesInfo')

for s = 1:nStacks
    
    % select mat file with IsolateDendriticSpikes
    if nargin < 4
        [FileName, PathName]=uigetfile('*.mat',['Select the file with the data for stack number ' num2str(s)]);
        FilesLoaded{s}=[PathName FileName];
    end
    
    % load data
    load(FilesLoaded{s},'BranchesCoActive','BranchesCoActiveAmpl','BranchesCoActiveInt','Segments')
    % save and concatenate info for each stack
    BranchesActiveAll = [BranchesActiveAll; BranchesCoActive];
    Ampl = [Ampl; BranchesCoActiveAmpl];
    Integr = [Integr; BranchesCoActiveInt];
    
    
    for sp = 1:length(BranchesCoActive)
        counter = counter + 1;
        N_BranchesActive(counter) = length(BranchesCoActive{sp});
        n_segments(counter) = length(Segments);
        SegmentsImaged{counter} = Segments;
    end
    
end

%% plot position of branch vs how often the branch is active during a dendritic spike

n_all_segments = max(NodesInfo(:,1));
% measure distrance of nodes
SortedTree.Z = SortedTree.Z*ScalingFactorInfo(3); % scale Z
SortedTree.X = SortedTree.X*ConversionFactor; % convert from pixels into microns
SortedTree.Y = SortedTree.Y*ConversionFactor; % convert from pixels into microns
OrderNodes = BO_tree(SortedTree); % order of branch
EuclNodes = eucl_tree(SortedTree); % euclidean distance from soma

% attribute distance to branches and % of times a branch is active
OrderBranch = NaN(n_all_segments, 1);
EuclBranch = NaN(n_all_segments, 1);
BranchActivePerc = NaN(n_all_segments, 1);
BranchesActiveAllMat = cell2mat(BranchesActiveAll');
SegmentsImagedMat = cell2mat(SegmentsImaged');
for br = 1:n_all_segments
    OrderBranch(br) = OrderNodes(find(NodesInfo(:,1) == br, 1, 'first'));
    EuclBranch(br) = mean(EuclNodes(find(NodesInfo(:,1) == br)));
    
    if ismember(br,SegmentsImagedMat) == 1
    BranchActivePerc(br) =  length(find(BranchesActiveAllMat == br))/length(find(SegmentsImagedMat == br))*100;
    end
end

% plot

figure;
scatter(OrderBranch,BranchActivePerc)
xlabel('Order of branch'), ylabel('% of dendritic spikes')

figure;
scatter(EuclBranch,BranchActivePerc)
if FlagConversion
    xlabel('Euclidean distance of branch, microns'), ylabel('% of dendritic spikes')
else
    xlabel('Euclidean distance of branch, pixels'), ylabel('% of dendritic spikes')
end

%% plot percentage of imaged branches active vs signal at the soma

% percentage of branches active
PercBranchesActive = N_BranchesActive./n_segments*100;

% calculate mean ampliotude and integral of each event
MeanAmpl = NaN(length(Ampl),1);
MeanIntegr = NaN(length(Ampl),1);

for sp = 1:length(Ampl)
    MeanAmpl(sp) = nanmean(Ampl{sp});
    MeanIntegr(sp) = nanmean(Integr{sp});
end

figure;
scatter(MeanAmpl, PercBranchesActive)
ylabel('Percentage of imaged branches active')
xlabel('Mean Amplitude (Df/f) of the spike')
ylim([0 105])

figure;
scatter(MeanIntegr, PercBranchesActive)
ylabel('Percentage of imaged branches active')
xlabel('Mean Integral of the spike')
ylim([0 105])

if FlagSave
    D = date;
    save('PlotDSPIKESpread.mat')
    
    saveas(gcf, 'SPIKESpread Vs IntegralDSPIKE.fig')
    saveas(gcf-1, 'SPIKESpread Vs AmplitudeDSPIKE.fig')
    saveas(gcf-2, 'SPIKESpread DistanceBranches.fig')
    saveas(gcf-3, 'SPIKESpread OrderBranches.fig')
end

end

