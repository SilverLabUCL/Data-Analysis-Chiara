% for all L2 cells, calculate how many times branches are active together
% with a somatic calcium transients

% path of cells with data
% during gratings presentation
folders{1} = 'C:\Data Analysis\Bonnie\09 February 2016\Bonnie Cell 1 BranchesCoActive.mat';
folders{2} = 'C:\Data Analysis\Bonnie\09 February 2016\Bonnie Cell 3 BranchesCoActive.mat';
folders{3} = 'C:\Data Analysis\Bonnie\09 February 2016\Bonnie Cell 5 BranchesCoActive.mat';
folders{4} = 'C:\Data Analysis\Tina\03 February 2015\Tina Cell 1 BranchesCoActive.mat';
folders{5} = 'C:\Data Analysis\Tina\03 February 2015\Tina Cell 2 BranchesCoActive.mat';
folders{6} = 'C:\Data Analysis\Mary\09 April 2015\Mary BranchesCoActive.mat';
folders{7} = 'C:\Data Analysis\Veronica\27 November 2014\Veronica Cell 2 BranchesCoActive.mat';
folders{8} = 'C:\Data Analysis\Robinson\26 June 2015\Robinson Cell 2 BranchesCoActive.mat';
folders{9} = 'C:\Data Analysis\Karina\09 February 2016\Karina Cell 5 BranchesCoActive.mat';
folders{10} = 'C:\Data Analysis\Clyde\15 March 2016\Clyde Cell 1 BranchesCoactive';
folders{11} = 'C:\Data Analysis\Clyde\15 March 2016\Clyde Cell 2 BranchesCoactive';
folders{12} = 'C:\Data Analysis\Bonnie\14 March 2016\Bonnie Cell 7 BranchesCoactive.mat';

AllData = [];
AllData2 = [];

for cell = 1:length(folders)
    
    load(folders{cell})
    [ PercTimesActive1,   PercTimesActive2] = PercAPsEachBranchDivideTwo( BranchesCoActivebAP, ImagedBranchesbAP );
    
    AllData = [AllData PercTimesActive1(2:end)];
    AllData2 = [AllData2 PercTimesActive2(2:end)];

end

figure;
hist(AllData)


