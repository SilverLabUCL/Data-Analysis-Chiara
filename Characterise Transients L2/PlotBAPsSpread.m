function PlotBAPsSpread( nStacks, FlagSave, ScalingFactorInfo, FilesLoaded, TreeLoaded )
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
SegmentsImaged = cell(1,nStacks);
BranchesActiveAll = [];
BAPSValAll = NaN(nStacks,2);
N_BranchesActive = NaN(nStacks,1);
counter1 = 1;
counter2 = 0;

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
    load(FilesLoaded{s},'BranchesActivebAPs','BAPSVal','Segments')
    % save and concatenate info for each stack
    if length(Segments) > 5
        BranchesActiveAll = [BranchesActiveAll; BranchesActivebAPs];
        BAPSValAll(counter1 : counter1 + size(BAPSVal,1)-1, 1:2 ) = BAPSVal;
        counter1 = counter1 + size(BAPSVal,1);
        
        for bap = 1:length(BranchesActivebAPs)
            counter2 = counter2 + 1;
            N_BranchesActive(counter2) = length(BranchesActivebAPs{bap})-1; % remove soma
            n_segments(counter2) = length(Segments)-1; % remove soma
            SegmentsImaged{counter2} = Segments;
        end
    end
end

%% plot position of branch vs how often the branch is active during a bAP

n_all_segments = max(NodesInfo(:,1));
% measure distrance of nodes
SortedTree.Z = SortedTree.Z*ScalingFactorInfo(3); % scale Z to z step
SortedTree.X = SortedTree.X*ConversionFactor; % convert from pixels into microns
SortedTree.Y = SortedTree.Y*ConversionFactor; % convert from pixels into microns
OrderNodes = BO_tree(SortedTree); % order of branch
EuclNodes = eucl_tree(SortedTree); % euclidean distance from soma in microns

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
xlabel('Order of branch'), ylabel('% of bAPs')

figure;
scatter(EuclBranch,BranchActivePerc)
if FlagConversion
    xlabel('Euclidean distance of branch, microns'), ylabel('% of bAPs')
else
    xlabel('Euclidean distance of branch, pixels'), ylabel('% of bAPs')
end

%% plot percentage of imaged branches active vs signal at the soma

PercBranchesActive = N_BranchesActive./n_segments*100;

figure;
scatter(BAPSValAll(:,1), PercBranchesActive)
ylabel('Percentage of imaged branches active')
xlabel('Amplitude (Df/f) of the bAP at the soma')
ylim([0 105])

figure;
scatter((BAPSValAll(:,2)), PercBranchesActive)
ylabel('Percentage of imaged branches active')
xlabel('Integral of the bAP at the soma')
ylim([0 105])

if FlagSave
    D = date;
    save('PlotBAPsSpread.mat')
    
    saveas(gcf, 'bAPSpread Vs IntegralBAP.fig')
    saveas(gcf-1, 'bAPSpread Vs AmplitudeBAP.fig')
    saveas(gcf-2, 'bAPSpread DistanceBranches.fig')
    saveas(gcf-3, 'bAPSpread OrderBranches.fig')
end

end

