
FileRunStatData = 'C:\Data Analysis\RunStatL2L5.mat';

% L2 neurons, anaesthetized
filesL2{1} = 'C:\Data Analysis\Mary\24 April 2015\BranchActivityAnaesthet 17-Feb-2016.mat'; % Mary
filesL2{2} = 'C:\Data Analysis\Robinson\11 July 2015\BranchActivityAnaesthet 17-Feb-2016.mat'; % Robinson cell 2
filesL2{3} = 'C:\Data Analysis\Karina\20 January 2016\BranchActivityAnaesthet 18-Feb-2016.mat'; % Karina cell 5
filesL2{4} = 'C:\Data Analysis\Bonnie\03 March 2016\Cell 1 Activity Anaesth\BranchActivityAnaesthet 31-Mar-2016.mat'; % Bonnie cell 1
filesL2{5} = 'C:\Data Analysis\Bonnie\03 March 2016\Cell 2 Activity Anaesth\BranchActivityAnaesthet 31-Mar-2016.mat'; % Bonnie cell 2
filesL2{6} = 'C:\Data Analysis\Bonnie\03 March 2016\Cell 3 Activity Anaesth\BranchActivityAnaesthet 31-Mar-2016.mat'; % Bonnie cell 3

% L2, stationary
filesL2Stat{1} = 'C:\Data Analysis\Mary\09 April 2015\Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
filesL2Stat{2} = 'C:\Data Analysis\Robinson\26 June 2015\Cell 2 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
filesL2Stat{3} = 'C:\Data Analysis\Karina\09 February 2016\Cell 5 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
filesL2Stat{4} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 1 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
filesL2Stat{5} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 2 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
filesL2Stat{6} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 3 Gratings\BranchActivityRunStat 18-Feb-2016.mat';

% correspondances branches in awake and anaesthetized
IndexStat2{1} = 2:8;
IndexAn2{1} = 2:8;

IndexStat2{2} = 2:4;
IndexAn2{2} = 2:4;

IndexStat2{3} = 9;
IndexAn2{3} = 7;

IndexStat2{4} = 2:4;
IndexAn2{4} = 2:4;

IndexStat2{5} = [2 3 4]; 
IndexAn2{5} = [5 6 7];

IndexStat2{6} = [12 13 14]; 
IndexAn2{6} = [11 12 13];

% intialise
BranchesAn2 = [];
BranchesStat2 = [];
BranchesAn5 = [];
BranchesStat5 = [];
SomaAn = [];
SomaStat = [];

% load data
% L2
for f = 1:length(filesL2)  
    
    % load data for anaesthetized
    load(filesL2{f},'ActivitySegStat')
    BranchesAn2 = [BranchesAn2 ActivitySegStat(IndexAn2{f})];
    SomaAn = [SomaAn ActivitySegStat(1)];
    
    % load data for awake stationary
    load(filesL2Stat{f},'ActivitySegStat')
    BranchesStat2 = [BranchesStat2 ActivitySegStat(IndexStat2{f})];
    SomaStat = [SomaStat ActivitySegStat(1)];
end


% compute mean and standard error of the mean
BrAnMean2 = nanmean(BranchesAn2);
BrAnSem2 = nanstd(BranchesAn2)/sqrt(length(BranchesAn2));

BrStatMean2 = nanmean(BranchesStat2);
BrStatSem2 = nanstd(BranchesStat2)/sqrt(length(BranchesStat2));


% % paired t-test
[h,pL2] = ttest(BranchesAn2, BranchesStat2);
disp(['Paired t-test: ' num2str(h) ', P-value = ' num2str(pL2*100)])


% plot histograms
figure;
bar([1 2],[BrStatMean2 BrAnMean2 ])
hold on
errorbar([1 2],[BrStatMean2 BrAnMean2 ],[BrStatSem2 BrAnSem2],'.k')
xlim([0 3])
title('Apical dendrites of L2 neurons')
box off


% plot all datapoints
figure;
for br = 1:length(BranchesAn2)
    plot([1 2],[BranchesStat2(br) BranchesAn2(br)],'-ko')
    hold all
end
xlim([0 3])
box off
title('Apical dendrites of L2 neurons')

