function [ DistribBranchP ] = DistribEachBranch( FileName, FlagSoma )
% for each branch, measure how mant bAPs and how many dSpikes, and
% distribution of events

% input: name of file BranchesCoActive, output of code DataToSadraL2

% load data
load(FileName)


if FlagSoma % if soma was imaged, assume that spikes are divided into bAPs and dSpikes
    % put together bAPs and dendritic spikes
    BranchesCoActive = [BranchesCoActiveDSpike; BranchesCoActivebAP];
    ImagedBranches = [ImagedBranchesDSpike; ImagedBranchesbAP];
    FirstBranch = 2; % and discard soma data
else
    FirstBranch = 1;
end

n_branches = max(cell2mat(ImagedBranches')); % number of branches
n_transients = length(BranchesCoActive);
DistribBranch = cell(1,n_branches);
DistribBranchP = NaN(n_branches,10);
BinCenters = 1:10:100;

for br = FirstBranch:n_branches
    
    % find all events where there is branch br
    counter = 0;
    for t = 1:n_transients
        
        if isempty(find(ImagedBranches{t}==br)) == 0 && length(ImagedBranches{t})> 4
            counter = counter + 1;
            DistribBranch{br}(counter) = length(BranchesCoActive{t})/length(ImagedBranches{t})*100;
        end
    end
    
    % normalize by total number of events for each branch
    if length(DistribBranch{br}) > 10
        DistribBranchP(br,:) = hist(DistribBranch{br},BinCenters)/length(DistribBranch{br})*100;
    else
        DistribBranchP(br,:) = NaN;
    end
end

% plot mean distribution
MeanDistrib = nanmean(DistribBranchP(FirstBranch:end,:),1);
Sem = nanstd(DistribBranchP(FirstBranch:end,:),1)./n_branches;

figure;
bar(MeanDistrib)
hold on;
errorbar(1:10, MeanDistrib, Sem, 'k.')

end

