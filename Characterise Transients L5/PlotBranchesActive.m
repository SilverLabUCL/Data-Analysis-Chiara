function [ BranchesCoActive, BranchesCoActiveAmpl,  BranchesCoActiveInt] = PlotBranchesActive(FlagSave, ResponsesBin, Segments, TransientsChar, FlagPlot, SortedTree, NodesInfo)
% plot branches active at each response

if nargin < 1
    FlagSave = 1;
end

% load data
if nargin < 2
    [FilenameResp,PathnameResp] = uigetfile('*.mat','Select a folder with the binarized responses: TransientsChar.mat');
    [FilenameTree,PathnameTree] = uigetfile('*.mat', 'Select a folder with the dendritic tree data');
    load([PathnameResp FilenameResp], 'ResponsesBin','Segments')
    load([PathnameTree FilenameTree], 'SortedTree','NodesInfo')
end

% look for responses
[ Peaks, Locations ] = FindResponsesMultipleBranchesActive( ResponsesBin );

% look for branches co-active in each response
BranchesCoActive = cell(length(Peaks),1);
BranchesCoActiveAmpl = cell(length(Peaks),1);
BranchesCoActiveInt = cell(length(Peaks),1);

for resp = 1:length(Peaks)
    
    counter = 0;
    BranchesCoActive{resp} = [];
    
    for br = 1:size(ResponsesBin,1)
        if ResponsesBin(br,Locations(resp)) == 1
            counter = counter + 1;
            BranchesCoActive{resp} (counter) = br;
            % find amplitude and integral of response
            [~, pos] = min( abs(TransientsChar(1,br).PosMax - Locations(resp)));
            BranchesCoActiveAmpl{resp} (counter) = TransientsChar(1,br).Amplitude(pos);
            BranchesCoActiveInt{resp} (counter) = TransientsChar(1,br).Integral(pos);
        end
    end
end

% plot
if FlagPlot
    for resp = 1:length(Peaks)
        
        [ColorNodes] = ColorBranches(NodesInfo, BranchesCoActive{resp}, Segments );
        
        figure; plot_tree(SortedTree,ColorNodes');
        colormap(cool); caxis([0 1])
        colorbar; shine
        title([ 'Response at ' num2str(Locations(resp)) ' timepoints' ])
    end
end

% save
if FlagSave
    Date = date;
    save('PlotBranchesActive.mat')
    for resp = 1:length(Peaks)
        saveas(gcf - length(Peaks) + resp,['PlotBranchesActive Response at ' num2str(Locations(resp)) ' timepoints'])
    end
end
end


function [ Peaks, Locations ] = FindResponsesMultipleBranchesActive( ResponsesBin )

SumResponses = [0 sum(ResponsesBin,1)];

% find beginning and end of each response in the summation vector
Zeros = (SumResponses>0);
StartR = find( diff(Zeros) == 1);
EndR = find( diff(Zeros) == -1);

% find number of branches co active in each response
peaks = zeros(1,length(StartR));
locations = zeros(1,length(StartR));
for i=1:length(StartR)
    [peaks(i), locations(i)]= max(SumResponses(StartR(i):EndR(i)));
    locations(i) = locations(i) + StartR(i) - 2;
end

% % remove responses with only one branch active
% NonOnes = find(peaks ~= 1) ;
% Peaks = peaks(NonOnes);
% Locations = locations(NonOnes);
Peaks = peaks;
Locations = locations;

end

function [ColorNodes] = ColorBranches(NodesInfo, BranchesCoActive, Segments)

NodesActive = [];
NodesRecorded = [];

for br = 1:length(BranchesCoActive)
    NodesActive = [ NodesActive; find( NodesInfo(:,1) == BranchesCoActive(br))];
end

for br = 1:length(Segments)
    NodesRecorded = [ NodesRecorded; find( NodesInfo(:,1) == Segments(br))];
end

ColorNodes = NaN(1,length(NodesInfo));
ColorNodes(NodesRecorded) = 0;
ColorNodes(NodesActive) = 1;

end

