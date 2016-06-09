% run MeasureMinDistanceBranches for all cells..
% runs it for all planes, in folders "folders" specified below

% run it for all cells, stack and day of experiment chosen randomly
folders{1} = 'C:\Data Analysis\Veronica\27 November 2014\141127_17_59_29\Cell 4';
folders{2} = 'C:\Data Analysis\Veronica\27 November 2014\141127_17_59_29\Cell 1';
folders{3} = 'C:\Data Analysis\Veronica\27 November 2014\141127_17_59_29\Cell 2';
folders{4} = 'C:\Data Analysis\Tito\12 August 2015\150812_16_32_44';
folders{5} = 'C:\Data Analysis\Tita\07 August 2015\150807_17_26_21';
folders{6} = 'C:\Data Analysis\Tina\03 February 2015\150203_16_32_25\Cell 1';
folders{7} = 'C:\Data Analysis\Tina\03 February 2015\150203_16_32_25\Cell 2';
folders{8} = 'C:\Data Analysis\Theodora\01 June 2015 Region 1\150601_16_40_58\Cell 1';
folders{9} = 'C:\Data Analysis\Theodora\01 June 2015 Region 1\150601_16_40_58\Cell 2';
folders{10} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\150603_17_44_19\Cell 1';
folders{11} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\150603_17_44_19\Cell 2';
folders{12} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\150603_17_44_19\Cell 3';
folders{13} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\150603_17_44_19\Cell 4';
folders{14} = 'C:\Data Analysis\Robinson\17 June 2015\150617_16_33_32\Cell 1';
folders{15} = 'C:\Data Analysis\Robinson\17 June 2015\150617_16_33_32\Cell 2';
folders{16} = 'C:\Data Analysis\Robinson\26 June 2015\150626_14_44_46\Cell 1';
folders{17} = 'C:\Data Analysis\Robinson\26 June 2015\150626_14_44_46\Cell 2';
folders{18} = 'C:\Data Analysis\Mary\09 April 2015\150409_15_55_33';
folders{19} = 'C:\Data Analysis\Karina\09 February 2016\160209_16_05_17\Cell 5';
folders{20} = 'C:\Data Analysis\Gandalf\10 December 2014\141210_16_20_36';
folders{21} = 'C:\Data Analysis\Clyde\15 March 2016\160315_15_34_34\Cell 1';
folders{22} = 'C:\Data Analysis\Clyde\15 March 2016\160315_15_34_34\Cell 2';
folders{23} = 'C:\Data Analysis\Bonnie\09 February 2016\160209_20_20_00\Cell 1';
folders{24} = 'C:\Data Analysis\Bonnie\09 February 2016\160209_20_20_00\Cell 2';
folders{25} = 'C:\Data Analysis\Bonnie\09 February 2016\160209_20_20_00\Cell 3';
folders{26} = 'C:\Data Analysis\Bonnie\09 February 2016\160209_20_20_00\Cell 4';
folders{27} = 'C:\Data Analysis\Bonnie\09 February 2016\160209_20_20_00\Cell 5';
folders{28} = 'C:\Data Analysis\Bonnie\09 February 2016\160209_20_20_00\Cell 6';
folders{29} = 'C:\Data Analysis\Bonnie\14 March 2016\160314_16_59_02';

FlagPlot = 0;
Radius = 10;

MeanDistAll = [];
MinDistAll = [];
DistancesAll = [];
RatioSpaceAll = [];
StartingFolder = pwd;

for f = 1:length(folders)
    
    cd(folders{f})
    % load data
    files = dir;
    FlagLoadData = 0;
    for ff = 3:length(files)
        if strcmp( files(ff,1).name(1:4), 'DFoF' ) == 1
            load(files(ff,1).name, 'RedChStack', 'SortedTree')
            FlagLoadData = 1;
        end
    end
    
    % compute distance branches
    if FlagLoadData == 1 % if data was loaded
        n_planes = length(RedChStack);
        for pl = 1:n_planes % go through all planes
            try
                [ MinDist, MeanDist, Distances, RatioSpace ] = MeasureMinDistanceBranches(RedChStack, pl, SortedTree, FlagPlot, Radius);
                MeanDistAll = [MeanDistAll MeanDist];
                MinDistAll = [MinDistAll MinDist];
                DistancesAll = [DistancesAll reshape(Distances,1,[])];
                RatioSpaceAll = [RatioSpace RatioSpaceAll];
            end
            close all
        end
    else
        disp(['Could not load data for folder ' folders{f}])
    end
    
    clear files MeanDist MinDist
end

cd(StartingFolder)

% plot
figure;
hist(MeanDistAll,50)
title('Mean distance')

figure; 
hist(MinDistAll,50)
title('Minimum distance')

figure;
hist(DistancesAll,100)
title('Distribution all distances')

figure;
hist(RatioSpaceAll,50)
title('Ratio space occupied by another dendrite')
