% path of cells with data
% during gratings presentation
folders{1} = 'C:\Data Analysis\Veronica\27 November 2014\BranchesCoActive Veronica.mat';
folders{2} = 'C:\Data Analysis\Gandalf\10 December 2014\BranchesCoActive Gandalf.mat';
folders{3} = 'C:\Data Analysis\Theodora\01 June 2015 Region 1\BranchesCoActive Theodora Region1 Cell1.mat';
folders{4} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\Cell 1\BranchesCoActive Theodora Region2 Cell1.mat';
folders{5} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\Cell 2\BranchesCoActive Theodora Region2 Cell2.mat';
folders{6} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\Cell 3\BranchesCoActive Theodora Region2 Cell3.mat';
folders{7} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\Cell 4\BranchesCoActive Theodora Region2 Cell4.mat';
folders{8} = 'C:\Data Analysis\Tita\07 August 2015\BranchesCoActive Tita.mat';

AllData = [];

for cell = 1:length(folders)

     [ DistribBranchP ] = DistribEachBranch( folders{cell}, 0 );
    
    AllData = [AllData; DistribBranchP];

end

MeanDistrib = nanmean(AllData,1);
Sem = nanstd(AllData,1)./size(AllData,1);

figure;
bar(MeanDistrib)
hold on;
errorbar(1:10, MeanDistrib, Sem, 'k.')

