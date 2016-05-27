% put together data of spike distribution for different cells

% just spatial spread of spikes versus amplitude of the event, and
% distance

% path of cells with data, L5 tuft dendrites

% % during gratings presentation
% folders{1} = 'C:\Data Analysis\Veronica\27 November 2014\Spatial Distribution dendritic spikes';
% folders{2} = 'C:\Data Analysis\Gandalf\10 December 2014\Spatial distribution dendritic events\Dendritic spikes spread VisStim 17May2016';
% folders{3} = 'C:\Data Analysis\Theodora\01 June 2015 Region 1\Spatial Distribution events';
% folders{4} = 'C:\Data Analysis\Theodora\01 June 2015 Region 1\Cell 2 Spatial distribution';
% folders{5} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\Cell 1';
% folders{6} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\Cell 2';
% folders{7} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\Cell 3';
% folders{8} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2\Cell 4';
% folders{9} = 'C:\Data Analysis\Tita\07 August 2015';

% in the dark
folders{1} = 'C:\Data Analysis\Veronica\20 November 2014\Cell 4 Spatial Distribution Dark';
folders{2} = 'C:\Data Analysis\Theodora\28 May 2015\Cell 1 Spatial distribution dark';
folders{3} = 'C:\Data Analysis\Robinson\17 June 2015\Spatial distribution Cell1 Dark';
folders{4} = 'C:\Data Analysis\Tito\13 August 2015\Spatial Distribution Dark';

FlagSave = 1;

nCells = length(folders);
StartingPath = pwd;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initilalise variables
% relation spike amplitude/integral and spatial spread
DSpikesAmpl = [];
DSpikesInt = [];
BranchActivedSpike = [];
% relation distance from the soma and spread
BranchActiveOrderdSpikes = [];
BranchActiveEucldSpikes = [];
BranchActivePercdSpikes = [];
BranchActiveEucldSpikesNorm = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data for each cell

for  f = 1:nCells
   
    CheckFlag = 0;
    cd(folders{f})
    ReadFiles = dir('*.mat');
    
    for ff = 1:length(ReadFiles)
        
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
    save('AmplitudeVsBranchesActiveDataAcrossCells.mat')
end
