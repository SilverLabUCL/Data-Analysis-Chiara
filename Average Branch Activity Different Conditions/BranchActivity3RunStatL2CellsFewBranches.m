% 
% % L2 neurons, gratings, and apical dendrites:
% 
% % Bonnie cell 1
% filesL2{1} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 1 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
% Br{1} = 2:4;
% % Bonnie cell 2
% filesL2{2} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 2 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
% Br{2} = 2:4;
% % Bonnie cell 5
% filesL2{3} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 5 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
% Br{3} = 6:10;
% % Bonnie cell 7
% filesL2{4} = 'C:\Data Analysis\Bonnie\14 March 2016\BranchActivityRunStat 29-Apr-2016.mat';
% Br{4} = 9:15;
% 
% % Tina cell 1
% filesL2{5} = 'C:\Data Analysis\Tina\03 February 2015\Run Stat Cell 1\BranchActivityRunStat 17-Feb-2016.mat';
% Br{5} = 20;
% % Tina cell 2
% filesL2{6} = 'C:\Data Analysis\Tina\03 February 2015\Run Stat Cell 2\BranchActivityRunStat 17-Feb-2016.mat';
% Br{6} = 4:12;
% 
% % Mary
% filesL2{7} = 'C:\Data Analysis\Mary\09 April 2015\Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
% Br{7} = 2:8;
% 
% % Veronica cell 2
% filesL2{8} = 'C:\Data Analysis\Veronica\27 November 2014\Cell 2 Run Stat Gratings\BranchActivityRunStat 17-Feb-2016.mat';
% Br{8} = 3:5;
% 
% % Robinson cell 2
% filesL2{9} = 'C:\Data Analysis\Robinson\26 June 2015\Cell 2 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
% Br{9} = 2:4;
% 
% % Karina cell 5
% filesL2{10} = 'C:\Data Analysis\Karina\09 February 2016\Cell 5 Run Stat\BranchActivityRunStat 17-Feb-2016.mat';
% Br{10} = 9:11;
% 
% % Clyde cell 1
% filesL2{11} = 'C:\Data Analysis\Clyde\15 March 2016\Cell 1\BranchActivityRunStat 28-Apr-2016.mat';
% Br{11} = 2:8;


% L2 neurons, dark, and apical dendrites:

% Bonnie cell 1
filesL2{1} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 1 Dark\BranchActivityRunStat 27-Apr-2016.mat';
Br{1} = 2:4;
% Bonnie cell 2
filesL2{2} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 2 Dark\BranchActivityRunStat 27-Apr-2016.mat';
Br{2} = 2:4;
% Bonnie cell 5
filesL2{3} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 5 Dark\BranchActivityRunStat 27-Apr-2016.mat';
Br{3} = 6:10;

% Mary
filesL2{4} = 'C:\Data Analysis\Mary\15 April 2015\Run Stat Dark\BranchActivityRunStat 27-Apr-2016.mat';
Br{4} = 2:8;

% Robinson cell 2
filesL2{5} = 'C:\Data Analysis\Robinson\24 June 2015\Cell 2 RunStat Dark\BranchActivityRunStat 27-Apr-2016.mat';
Br{5} = 2:4;

% Karina cell 5
filesL2{6} = 'C:\Data Analysis\Karina\15 January 2016\Cell 5\BranchActivityRunStat 27-Apr-2016.mat';
Br{6} = 6:8;




% intialise
BranchesStat = [];
BranchesRun = [];

% load data
for f = 1:length(filesL2)

    load(filesL2{f},'ActivitySegStat','ActivitySegRun')
    
    BranchesStat = [BranchesStat ActivitySegStat(2:end)];
    BranchesRun = [BranchesRun ActivitySegRun(2:end)];
    
end

% compute mean and standard error of the mean
BrStatMean2 = nanmean(BranchesStat);
BrRunMean2 = nanmean(BranchesRun);
BrStatSem2 = nanstd(BranchesStat)/sqrt(length(BranchesStat));
BrRunSem2 = nanstd(BranchesRun)/sqrt(length(BranchesRun));

% paired t-test
[h, p] = ttest(BranchesStat, BranchesRun);
disp(['Paired t-test: ' num2str(h) ' , p value: ' num2str(p)])


% plot
figure;
bar([1 2],[BrStatMean2 BrRunMean2])
hold on
errorbar([1 2],[BrStatMean2 BrRunMean2],[BrStatSem2 BrRunSem2],'.k')
xlim([0 3])
title('Apical dendrites of L2 neurons')
box off

