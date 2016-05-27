
% rig3 data, L5 somas and dendrites
files{1} = 'C:\Data Analysis\Rig3\2016-March-01\Cell 2\BranchActivityRunStat 11-May-2016.mat';
files{2} = 'C:\Data Analysis\Rig3\2016-March-02\BranchActivityRunStat 11-May-2016.mat';
files{3} = 'C:\Data Analysis\Rig3\2016-March-11 Bonnie\Cell 1\BranchActivityRunStat 11-May-2016.mat';
files{4} = 'C:\Data Analysis\Rig3\2016-March-11 Bonnie\Cell 2\BranchActivityRunStat 11-May-2016.mat';
files{5} = 'C:\Data Analysis\Rig3\2016-March-11 Clyde\Cell 1\BranchActivityRunStat 11-May-2016.mat';
files{6} = 'C:\Data Analysis\Rig3\2016-March-11 Clyde\Cell 2\BranchActivityRunStat 11-May-2016.mat';
files{7} = 'C:\Data Analysis\Rig3\2016-March-01\Cell 1\BranchActivityRunStat 11-May-2016.mat';



% intialise
BranchesStat = [];
BranchesRun = [];
SomaStat = [];
SomaRun = [];

% load data
for f = 1:length(files)
    
    load(files{f},'ActivitySegStat','ActivitySegRun')
    
    BranchesStat = [BranchesStat ActivitySegStat(3:end)];
    BranchesRun = [BranchesRun ActivitySegRun(3:end)];
    
    SomaStat = [SomaStat ActivitySegStat(1)];
    SomaRun = [SomaRun ActivitySegRun(1)];
    
end

% compute mean and standard error of the mean
BrStatMean = nanmean(BranchesStat);
BrRunMean = nanmean(BranchesRun);
BrStatSem = nanstd(BranchesStat)/sqrt(length(BranchesStat));
BrRunSem = nanstd(BranchesRun)/sqrt(length(BranchesRun));

SomaStatMean = nanmean(SomaStat);
SomaRunMean = nanmean(SomaRun);
SomaStatSem = nanstd(SomaStat)/sqrt(length(SomaStat));
SomaRunSem = nanstd(SomaRun)/sqrt(length(SomaRun));

% paired t-test
[hB, pB]= ttest(BranchesStat, BranchesRun);
disp(['Paired t-test for branches: ' num2str(hB) ' p-value = ' num2str(pB)])

[hS, pS] = ttest(SomaStat, SomaRun);
disp(['Paired t-test for somas: ' num2str(hS) ' p-value = ' num2str(pS)])

% plot
figure;
bar([1 2],[BrStatMean BrRunMean])
hold on
errorbar([1 2],[BrStatMean BrRunMean],[BrStatSem BrRunSem],'.k')
xlim([0 3])
title('Dendrites of L5 neurons')
box off

figure;
bar([1 2],[SomaStatMean SomaRunMean])
hold on
errorbar([1 2],[SomaStatMean SomaRunMean],[SomaStatSem SomaRunSem],'.k')
xlim([0 3])
title('Somas of L5 neurons')
box off
