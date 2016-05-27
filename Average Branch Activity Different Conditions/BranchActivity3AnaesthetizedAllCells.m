
FileRunStatData = 'C:\Data Analysis\RunStatL2L5.mat';

% L2 neurons, anaesthetized
filesL2{1} = 'C:\Data Analysis\Mary\24 April 2015\BranchActivityAnaesthet 17-Feb-2016.mat';
filesL2{2} = 'C:\Data Analysis\Robinson\11 July 2015\BranchActivityAnaesthet 17-Feb-2016.mat';
filesL2{3} = 'C:\Data Analysis\Karina\20 January 2016\BranchActivityAnaesthet 18-Feb-2016.mat';
filesL2{4} = 'C:\Data Analysis\Bonnie\03 March 2016\Cell 1 Activity Anaesth\BranchActivityAnaesthet 31-Mar-2016.mat';
filesL2{5} = 'C:\Data Analysis\Bonnie\03 March 2016\Cell 2 Activity Anaesth\BranchActivityAnaesthet 31-Mar-2016.mat';
%filesL2{6} = 'C:\Data Analysis\Bonnie\03 March 2016\Cell 3 Activity Anaesth\BranchActivityAnaesthet 31-Mar-2016.mat';

% L2, stationary
filesL2Stat{1} = 'C:\Data Analysis\Mary\09 April 2015\Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
filesL2Stat{2} = 'C:\Data Analysis\Robinson\26 June 2015\Cell 2 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
filesL2Stat{3} = 'C:\Data Analysis\Karina\09 February 2016\Cell 5 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
filesL2Stat{4} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 1 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
filesL2Stat{5} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 2 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';

% correspondances branches in awake and anaesthetized
IndexStat2{1} = [2:9 12:18];
IndexStat2{2} = 2:18;
IndexStat2{3} = [2 5 6:9 12];
IndexStat2{4} = [2:15 18 19];
IndexStat2{5} = [5 8 9 2 3 4]; 

% L5 neurons, anaesthetized
filesL5{1} = 'C:\Data Analysis\Veronica\14 October 2014\BranchAct Anaesth 27Feb Neuron4\BranchActivityAnaesthet 27-Feb-2015.mat';
filesL5{2} = 'C:\Data Analysis\Gandalf\16 December 2014\mean Branch Activity 21Apr2015\BranchActivityAnaesthet 21-Apr-2015.mat';
filesL5{3} = 'C:\Data Analysis\Theodora\09 June 2015 Region 1 Anaesth\MeanActAnaesthetized 22Aug2015\BranchActivityAnaesthet 22-Aug-2015.mat';
filesL5{4} = 'C:\Data Analysis\Theodora\09 June 2015 Region 1 Anaesth\Activity Cell2\BranchActivityAnaesthet 29-Feb-2016.mat';
filesL5{5} = 'C:\Data Analysis\Tita\11 August 2015\Average Branch Activity Anaesthetized\BranchActivityAnaesthet 08-Oct-2015.mat';

% L5 neurons, stationary awake
filesL5Stat{1} = 'C:\Data Analysis\Veronica\27 November 2014\MeanBranch Act RunStat 27Feb GratingsOnly\BranchActivityRunStat 27-Feb-2015.mat';
filesL5Stat{2} = 'C:\Data Analysis\Gandalf\10 December 2014\Running Vs Stationary\BranchAverageActivity RunningVsStat 20Apr2015\BranchActivityRunStat 20-Apr-2015.mat';
filesL5Stat{3} = 'C:\Data Analysis\Theodora\01 June 2015 Region 1\RunningActVsStat 22Aug2015\BranchActivityRunStat 22-Aug-2015.mat';
filesL5Stat{4} = 'C:\Data Analysis\Theodora\01 June 2015 Region 1\Cell 2 RunningActVsStat\BranchActivityRunStat 01-Oct-2015.mat';
filesL5Stat{5} = 'C:\Data Analysis\Tita\07 August 2015\Running Vs Stat activity\BranchActivityRunStat 01-Oct-2015.mat';

% correspondances branches in awake and anaesthetized
IndexStat5{1} = [1 2 10:12 13 13 13 14 3:9 15];
IndexStat5{2} = [1:4 6:9 13:17];
IndexStat5{3} = 1:13;
IndexStat5{4} = [1:5 5 5];
IndexStat5{5} = 1:15; 

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
    BranchesAn2 = [BranchesAn2 ActivitySegStat(2:end)];
    SomaAn = [SomaAn ActivitySegStat(1)];
    
    % load data for awake stationary
    load(filesL2Stat{f},'ActivitySegStat')
    BranchesStat2 = [BranchesStat2 ActivitySegStat(IndexStat2{f})];
    SomaStat = [SomaStat ActivitySegStat(1)];
end

% L5
for  f = 1:length(filesL5)
    % load data for anaesthetized
    load(filesL5{f},'ActivitySegStat')
    BranchesAn5 = [BranchesAn5 ActivitySegStat];
    
    % load data for awake stationary
    load(filesL5Stat{f},'ActivitySegStat')
    BranchesStat5 = [BranchesStat5 ActivitySegStat(IndexStat5{f})];
end

% compute mean and standard error of the mean
BrAnMean2 = nanmean(BranchesAn2);
BrAnSem2 = nanstd(BranchesAn2)/sqrt(length(BranchesAn2));

BrAnMean5 = nanmean(BranchesAn5);
BrAnSem5 = nanstd(BranchesAn5)/sqrt(length(BranchesAn5));

SomaAnMean = nanmean(SomaAn);
SomaAnSem = nanstd(SomaAn)/sqrt(length(SomaAn));

BrStatMean2 = nanmean(BranchesStat2);
BrStatSem2 = nanstd(BranchesStat2)/sqrt(length(BranchesStat2));

BrStatMean5 = nanmean(BranchesStat5);
BrStatSem5 = nanstd(BranchesStat5)/sqrt(length(BranchesStat5));

SomaStatMean = nanmean(SomaStat);
SomaStatSem = nanstd(SomaStat)/sqrt(length(SomaStat));


% % paired t-test
[h,pL2] = ttest(BranchesAn2, BranchesStat2);
disp(['Paired t-test for L2 branches: ' num2str(h) ', P-value = ' num2str(pL2*100)])

[h,pL5] = ttest(BranchesAn5, BranchesStat5);
disp(['Paired t-test for L5 branches: ' num2str(h) ', P-value = ' num2str(pL5*100)])

[h,pS] = ttest(SomaAn, SomaStat);
disp(['Paired t-test for L2 somas: ' num2str(h) ', P-value = ' num2str(pS*100)])

% plot histograms
figure;
bar([1 2],[BrStatMean2 BrAnMean2 ])
hold on
errorbar([1 2],[BrStatMean2 BrAnMean2 ],[BrStatSem2 BrAnSem2],'.k')
xlim([0 3])
title('Dendrites of L2 neurons')
box off

figure;
bar([1 2],[SomaStatMean SomaAnMean])
hold on
errorbar([1 2],[SomaStatMean SomaAnMean],[SomaStatSem SomaAnSem],'.k')
xlim([0 3])
title('Somas of L2 neurons')
box off

figure;
bar([1 2],[BrStatMean5 BrAnMean5])
hold on
errorbar([1 2],[BrStatMean5 BrAnMean5],[BrStatSem5 BrAnSem5],'.k')
xlim([0 3])
title('Dendrites of L5 neurons')
box off

% plot all datapoints
figure;
for br = 1:length(BranchesAn2)
    plot([1 2],[BranchesStat2(br) BranchesAn2(br)],'-ko')
    hold all
end
xlim([0 3])
box off
title('Dendrites of L2 neurons')

figure;
for br = 1:length(SomaStat)
    plot([1 2],[SomaStat(br) SomaAn(br)],'-ko')
    hold all
end
xlim([0 3])
box off
title('Somas of L2 neurons')

figure;
for br = 1:length(BranchesAn5)
    plot([1 2],[BranchesStat5(br) BranchesAn5(br)],'-ko')
    hold all
end
xlim([0 3])
box off
title('Dendrites of L5 neurons')
