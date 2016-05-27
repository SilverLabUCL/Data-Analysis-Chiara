% put together data of spike distribution for different cells

% compared to version 1, it normalizes by number of events, and calculate
% mean and st dev of spatial distribution across cells

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters

% path of cells with data
% during gratings presentation
% folders{1} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 1 Gratings';
% folders{2} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 3 Gratings';
% folders{3} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 5 Gratings';
% folders{4} = 'C:\Data Analysis\Tina\03 February 2015\Spike Distrib Gratings Cell 1';
% folders{5} = 'C:\Data Analysis\Tina\03 February 2015\Spikes Distrib VisStim 7 Stacks Cell 2';
% folders{6} = 'C:\Data Analysis\Mary\09 April 2015\Gratings Spikes Distribution';
% folders{7} = 'C:\Data Analysis\Veronica\27 November 2014\Cell 2 Spike Dsistribution Gratings';
% folders{8} = 'C:\Data Analysis\Robinson\26 June 2015\Cell 2 Spike distribution';
% folders{9} = 'C:\Data Analysis\Karina\09 February 2016\Cell 5 Spike distribution';
% folders{10} = 'C:\Data Analysis\Clyde\15 March 2016\Cell 1';
% folders{11} = 'C:\Data Analysis\Clyde\15 March 2016\Cell 2';
% folders{12} = 'C:\Data Analysis\Bonnie\14 March 2016';

% % grating presentation, but only apical dendrites
% folders{1} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 1 Gratings\Spike Distribution Apical Dendrite';
% folders{2} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 5 Gratings\Spike Distribution Apical dendrite';
% folders{3} = 'C:\Data Analysis\Tina\03 February 2015\Spike Distrib Gratings Cell 1\Spike Distribution Apical dendrites';
% folders{4} = 'C:\Data Analysis\Tina\03 February 2015\Spikes Distrib VisStim 7 Stacks Cell 2\Apical dendrites';
% folders{5} = 'C:\Data Analysis\Mary\09 April 2015\Gratings Spikes Distribution\Apical';
% folders{6} = 'C:\Data Analysis\Veronica\27 November 2014\Cell 2 Spike Dsistribution Gratings\Apical dendrites';
% folders{7} = 'C:\Data Analysis\Robinson\26 June 2015\Cell 2 Spike distribution\Apical';
% folders{8} = 'C:\Data Analysis\Karina\09 February 2016\Cell 5 Spike distribution\Apical';
% folders{9} = 'C:\Data Analysis\Clyde\15 March 2016\Cell 1\SPike Distribution Apical dendrites';
% folders{10} = 'C:\Data Analysis\Bonnie\14 March 2016\Apical dendrites only';

% % when animal is in the dark
% folders{1} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 1 Dark';
% folders{2} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 3 Dark';
% folders{3} = 'C:\Data Analysis\Bonnie\09 February 2016\Cell 5 Dark';
% folders{4} = 'C:\Data Analysis\Tina\03 February 2015\Spike Distrib Dark Cell 1';
% folders{5} = 'C:\Data Analysis\Tina\03 February 2015\Spikes Distrib Dark 2 stacks Cell 2';
% folders{6} = 'C:\Data Analysis\Mary\09 April 2015\Dark Spikes Distribution';
% folders{7} = 'C:\Data Analysis\Veronica\20 November 2014\Cell 2 Spike Distribution Dark';

% %rig 3 data
folders{1} = 'C:\Data Analysis\Rig3\2016-March-01\Cell 1';
folders{2} = 'C:\Data Analysis\Rig3\2016-March-01\Cell 2';
folders{3} = 'C:\Data Analysis\Rig3\2016-March-02';
folders{4} = 'C:\Data Analysis\Rig3\2016-March-11 Bonnie\Cell 1';
folders{5} = 'C:\Data Analysis\Rig3\2016-March-11 Bonnie\Cell 2';
folders{6} = 'C:\Data Analysis\Rig3\2016-March-11 Clyde\Cell 1';
folders{7} = 'C:\Data Analysis\Rig3\2016-March-11 Clyde\Cell 2';

FlagSave = 0;

BinCenters = [10 20 30 40 50 60 70 80 90 100];
n_bins = length(BinCenters); % set the bins in histogram, depends on number of imaged branches

nCells = length(folders);
StartingPath = pwd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initilalise variables
% spike distribution
BAPDistr = [];
dSpikesDist = [];
PercentEventsBAP = NaN(nCells, n_bins);
PercentEventsDSpikes = NaN(nCells, n_bins);
PercentEvents = NaN(nCells, n_bins);
PercentEventsBAPOverAll = NaN(nCells, n_bins);
PercentEventsDSpikesOverAll = NaN(nCells, n_bins);
% relation spike amplitude/integral and spatial spread
BAPSVal = [];
BranchActiveBAP = [];
DSpikesAmpl = [];
DSpikesInt = [];
BranchActivedSpike = [];
% relation distance from the soma and spread
BranchActiveOrderBAP = [];
BranchActiveEuclBAP = [];
BranchActiveOrderdSpikes = [];
BranchActiveEucldSpikes = [];
BranchActivePercBAP = [];
BranchActivePercdSpikes = [];
BranchActiveEuclBAPNorm = [];
BranchActiveEucldSpikesNorm = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data for each cell

for  f = 1:nCells
    
    CheckFlag = 0;
    cd(folders{f})
    ReadFiles = dir('*.mat');
    
    for ff = 1:length(ReadFiles)
        
        % load spatial distribution data
        if length(ReadFiles(ff).name)> 20 && strcmp(ReadFiles(ff).name(1:20),'Spatial distribution') == 1
            
            load(ReadFiles(ff).name, 'VarToPlotdSpike', 'VarToPlotbAP')
            BAPDistr = [BAPDistr VarToPlotbAP];
            dSpikesDist = [dSpikesDist VarToPlotdSpike];
            
            PercentEventsBAP(f,1:n_bins) = hist(VarToPlotbAP,BinCenters)/length(VarToPlotbAP)*100;
            PercentEventsDSpikes(f,1:n_bins) = hist(VarToPlotdSpike,BinCenters)/length(VarToPlotdSpike)*100;
            
            VarToPlotAll = [VarToPlotbAP VarToPlotdSpike];
            PercentEventsBAPOverAll(f,1:n_bins) = hist(VarToPlotbAP,BinCenters)/length(VarToPlotAll)*100;
            PercentEventsDSpikesOverAll(f,1:n_bins) = hist(VarToPlotdSpike,BinCenters)/length(VarToPlotAll)*100;
            PercentEvents(f,1:n_bins) = hist(VarToPlotAll,BinCenters)/length(VarToPlotAll)*100;
            
            CheckFlag = 1;
        end
        
        % load data for BAP
        if length(ReadFiles(ff).name)> 14 && strcmp(ReadFiles(ff).name(1:14),'PlotBAPsSpread') == 1
            load(ReadFiles(ff).name, 'BAPSValAll', 'PercBranchesActive','OrderBranch','EuclBranch','BranchActivePerc')
            
            % spatial distribution
            BAPSVal = [BAPSVal; BAPSValAll];
            BranchActiveBAP = [BranchActiveBAP; PercBranchesActive];

            % distance from soma
            BranchActiveOrderBAP = [BranchActiveOrderBAP; OrderBranch];
            BranchActiveEuclBAP = [BranchActiveEuclBAP; EuclBranch];
            BranchActivePercBAP = [BranchActivePercBAP; BranchActivePerc];
            
            BranchActiveEuclBAPNorm = [BranchActiveEuclBAPNorm; (EuclBranch-min(EuclBranch))./max(EuclBranch-min(EuclBranch))];
            
            CheckFlag = 1;
        end
        
        % load data for dSpikes
        if length(ReadFiles(ff).name)> 16 && strcmp(ReadFiles(ff).name(1:16),'PlotDSPIKESpread') == 1
            
            load(ReadFiles(ff).name, 'MeanAmpl', 'MeanIntegr','PercBranchesActive','OrderBranch','EuclBranch','BranchActivePerc')
            % spatial distribution
            DSpikesAmpl = [DSpikesAmpl; MeanAmpl];
            DSpikesInt = [DSpikesInt; MeanIntegr];
            BranchActivedSpike = [BranchActivedSpike; PercBranchesActive];
            
            % distance from soma
            BranchActiveOrderdSpikes = [BranchActiveOrderdSpikes; OrderBranch];
            BranchActiveEucldSpikes = [BranchActiveEucldSpikes; EuclBranch];
            BranchActivePercdSpikes = [BranchActivePercdSpikes; BranchActivePerc];
            
            BranchActiveEucldSpikesNorm = [BranchActiveEucldSpikesNorm; (EuclBranch-min(EuclBranch))./max(EuclBranch-min(EuclBranch))];
            
            CheckFlag = 1;
        end
    end
    
    if CheckFlag == 0
        disp(['ERROR!!! No data found for folder ' folders{f}])
    end
    
end

cd(StartingPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot all data

% plot spatial distribution
figure;
hist(BAPDistr,n_bins)
title('Spatial Distribution BAPs')
axis tight; box off;
xlim([-10 110])
%ylim([0 YMax])
xlabel('% of branches'), ylabel('Number of events')

if FlagSave
   saveas(gcf,'Spatial Distribution BAPs.fig') 
end

figure;
hist(dSpikesDist,n_bins)
title('Spatial Distribution dSpikes')
axis tight; box off;
xlim([-10 110])
%ylim([0 YMax])
xlabel('% of branches'), ylabel('Number of dendritic events')

if FlagSave
   saveas(gcf,'Spatial Distribution dSpikes.fig') 
end

AllSpikes = [BAPDistr dSpikesDist];
figure;
hist(AllSpikes,n_bins)
title('Spatial Distribution All Spikes')
axis tight; box off;
xlim([-10 110])
%ylim([0 YMax])
xlabel('% of branches'), ylabel('Number of events')

if FlagSave
   saveas(gcf,'Spatial Distribution All.fig') 
end

% plot spatial distribution, mean and error across cells
% all events
MeanDistrib = nanmedian(PercentEvents, 1);  % calculate mean and error
SEM = nanstd(PercentEvents,1)./sqrt(nCells);

figure;
bar(MeanDistrib)
hold on; 
errorbar(MeanDistrib, SEM,'k.')
title(['Spatial Distribution of all events from ' num2str(nCells) ' cells'])
xlabel('% of branches'), ylabel('% of events')
box off; 

if FlagSave
   saveas(gcf,'Spatial Distribution All Norm.fig') 
end

% bAPs
MeanDistribBAP = nanmedian(PercentEventsBAP, 1);  % calculate mean and error
SEMBAP = nanstd(PercentEventsBAP,1)./sqrt(nCells);

figure;
bar(MeanDistribBAP)
hold on; 
errorbar(MeanDistribBAP, SEMBAP,'k.')
title(['Spatial Distribution of bAPs from ' num2str(nCells) ' cells'])
xlabel('% of branches'), ylabel('% of events')
box off; 

if FlagSave
   saveas(gcf,'Spatial Distribution BAP Norm.fig') 
end

% dSPikes
MeanDistribDSpikes = nanmedian(PercentEventsDSpikes, 1);  % calculate mean and error
SEMDSpikes = nanstd(PercentEventsDSpikes,1)./sqrt(nCells);

figure;
bar(MeanDistribDSpikes)
hold on; 
errorbar(MeanDistribDSpikes, SEMDSpikes,'k.')
title(['Spatial Distribution of dSpikes from ' num2str(nCells) ' cells'])
xlabel('% of branches'), ylabel('% of events')
box off; 

if FlagSave
   saveas(gcf,'Spatial Distribution dSpike Norm.fig') 
end

% dSpikes and bAPs overlapping
MeanDistribBAPOverAll = nanmedian(PercentEventsBAPOverAll, 1);  % calculate mean and error
SEMBAPOverAll = nanstd(PercentEventsBAPOverAll,1)./sqrt(nCells);
MeanDistribDSpikesOverAll = nanmedian(PercentEventsDSpikesOverAll, 1);  % calculate mean and error
SEMDSpikesOverAll = nanstd(PercentEventsDSpikesOverAll,1)./sqrt(nCells);

figure;
bar(MeanDistribBAPOverAll,'FaceColor','b')
hold on; 
errorbar(MeanDistribBAPOverAll, SEMBAPOverAll,'b.')
hold all;
bar(MeanDistribDSpikesOverAll,'FaceColor','g')
hold all; 
errorbar(MeanDistribDSpikesOverAll, SEMDSpikesOverAll,'g.')

title(['Spatial Distribution from ' num2str(nCells) ' cells'])
xlabel('% of branches'), ylabel('% of events')
box off; 

if FlagSave
   saveas(gcf,'Spatial Distribution BAP and dSpikes Norm.fig') 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot BAPs amplitude vs number of branches active
figure;
scatter(BAPSVal(:,1), BranchActiveBAP,50)
ylabel('% of imaged branches active')
xlabel('Amplitude (Df/f) of the AP at the soma')
ylim([0 105])
title('BAPs')

if FlagSave
    saveas(gcf,'bAPs Amplitude Vs Spread.fig') 
end


figure;
scatter((BAPSVal(:,2)), BranchActiveBAP,50)
ylabel('% of imaged branches active')
xlabel('Integral of the AP at the soma')
ylim([0 105])
title('BAPs')

if FlagSave
    saveas(gcf,'bAPs Integral Vs Spread.fig') 
end

% plot dSpikes amplitude vs number of branches active
figure;
scatter(DSpikesAmpl, BranchActivedSpike,50)
ylabel('% of imaged branches active')
xlabel('Mean Amplitude (Df/f) of the dendritic spike')
ylim([0 105])
title('Dendritic events')

if FlagSave
    saveas(gcf,'dSpikes Amplitude Vs Spread.fig') 
end


figure;
scatter(DSpikesInt, BranchActivedSpike,50)
ylabel('% of imaged branches active')
xlabel('Mean Integral of the dendritic spike')
ylim([0 105])
title('Dendritic events')

if FlagSave
    saveas(gcf,'dSpikes Integral Vs Spread.fig') 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot distance of active branches, BAPs
figure; scatter(BranchActiveOrderBAP, BranchActivePercBAP,50)
xlabel('Order of branch'), ylabel('% of bAPs')
title('BAPs')

figure; scatter(BranchActiveEuclBAPNorm, BranchActivePercBAP,50)
xlabel('Normalized distance of branch from soma in um'), ylabel('% of bAPs')
title('BAPs') 

figure; scatter(BranchActiveEuclBAP, BranchActivePercBAP,50)
xlabel('Distance of branch from soma in um'), ylabel('% of bAPs')
title('BAPs')
if FlagSave
    saveas(gcf,'bAPs Spread Vs Distance.fig') 
end


% plot distance of active branches, dSpikes
figure; scatter(BranchActiveOrderdSpikes, BranchActivePercdSpikes,50)
xlabel('Order of branch'), ylabel('% of dSPikes')
title('Dendritic events')

figure; scatter(BranchActiveEucldSpikesNorm, BranchActivePercdSpikes,50)
xlabel('Normalized distance of branch from soma in um'), ylabel('% of transients')
title('Dendritic events')

figure; scatter(BranchActiveEucldSpikes, BranchActivePercdSpikes,50)
xlabel('Distance of branch from soma in um'), ylabel('% of transients')
title('Dendritic events')
if FlagSave
    saveas(gcf,'dSpikes Spread Vs Distance.fig') 
end



if FlagSave
    save('SpikeDistribDataAcrossCells.mat')
end
