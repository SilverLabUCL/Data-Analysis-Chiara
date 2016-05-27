function [RunningActivity, StationaryActivity] = BranchActivity3RunStat(nStacks,n_segments,FlagSave, FilesLoaded)
%calculate branch activity for different animal states: running and stationary.

%% parameters

ThresholdRunningRPM=5; % 1 rotation= 50 cm
BinSizeMs=100; %length of time bin in ms

%% set default inputs

if nargin<1
    nStacks=inputdlg('How many stacks do you want to analyze?');
    nStacks=str2double(nStacks{1});
end

if nargin<2
    n_segments=inputdlg('How many segments has this neuron?');
    n_segments=str2double(n_segments{1});
end

if nargin<3
    FlagSave=true;
end


%% load the data


RunningActivity=cell(n_segments,1);
StationaryActivity=cell(n_segments,1);
counterBinRun=ones(n_segments,1);
counterBinStat=ones(n_segments,1);

for s=1:nStacks
    
    if nargin < 4
        [filename,pathname]=uigetfile('*.mat'); %the user needs to load a file that contains a matrix DeltaFoverF_Sm(cell,trial,time)
        FilesLoaded{s}=[pathname filename];
    else
        Index = find(FilesLoaded{s} == '\',1,'last');
        pathname = FilesLoaded{s}(1:Index);
    end
    load(FilesLoaded{s},'DeltaFoverF','TimesSegment','PointsInSegments','MeanSegment','NodesInfo','SortedTree')
    %     load(FilesLoaded{s},'DfoFBAPS','TimesSegment','PointsInSegments','MeanSegment','NodesInfo','SortedTree')
    %    DeltaFoverF = DfoFBAPS;
 
    %load speed data
    UpOneFolder = find(pathname == '\',2,'last');
    pathnameUpOneFolder = pathname(1:UpOneFolder(1));
    if exist([pathnameUpOneFolder 'SpeedData.mat'],'file') == 2
        load([pathnameUpOneFolder 'SpeedData.mat'],'Speed')
    else
        load([pathname 'SpeedData.mat'],'Speed')
    end
    n_timepoints=size(DeltaFoverF,3);
    n_trials=size(DeltaFoverF,2);
    
    DeltaFoF=NaN(n_segments,n_trials,n_timepoints);
    
    %% smooth the deltaF/F data
    
    for Seg=1:n_segments
        if isempty(PointsInSegments{1,Seg})==0 && isnan(squeeze(MeanSegment(Seg,1,1)))==0
            for trial=1:n_trials
                DeltaFoF(Seg,trial,:)=smooth(DeltaFoverF(Seg,trial,:),30);
                
                %remove negative values
                NegativeValues=DeltaFoF(Seg,trial,:)<0;
                DeltaFoF(Seg,trial,NegativeValues)=0;
            end
        end
    end
    
    %% find running and stationary periods
    RunningT=cell(n_segments,n_trials); %timepoints when mouse is running
    StationaryT=cell(n_segments,n_trials); %timepoints when mouse is stationary
    
    for Seg=1:n_segments
        for t=1:n_trials
            if  ismember(t, Speed{end})==1 %if speed was recorded for this trial
                t_Sp=find(Speed{end}==t);
                %interpolate speed data to the same temporal scale as imaging data
                SpeedInt=interp1(Speed{1,t_Sp}(:,1),Speed{1,t_Sp}(:,2),squeeze(TimesSegment(Seg,t,:)));
                
                %find running and stationary periods
                RunningT{Seg,t}=find(SpeedInt>ThresholdRunningRPM);
                StationaryT{Seg,t}=find(SpeedInt<ThresholdRunningRPM);
                
                clear SpeedInt
            end
        end
    end
    
    
    %% divide running and stationary periods into bins and calculate activity in the bin as sum of deltaF/F
    
    for Seg=1:n_segments
        
        BinSize=round(BinSizeMs/TimesSegment(Seg,1,2));
        
        for trial=1:n_trials
            
            AlreadyMeasuredTimes=0;
            AlreadyMeasuredTimesS=0;
            
            if  ismember(trial, Speed{end})==1 && isempty(PointsInSegments{1,Seg})==0 && isnan(squeeze(MeanSegment(Seg,1,1)))==0 %if speed was recorded for this trial and if segments has points
                
                for t=1:(length(RunningT{Seg,trial}) - BinSize)
                    
                    if RunningT{Seg,trial}(t+BinSize)==RunningT{Seg,trial}(t)+BinSize && RunningT{Seg,trial}(t)>AlreadyMeasuredTimes %to consider only bins where each point is consecutive in time
                        
                        RunningActivity{Seg}(counterBinRun(Seg))=nanmean(DeltaFoF(Seg,trial,RunningT{Seg,trial}(t):RunningT{Seg,trial}(t+BinSize)));
                        counterBinRun(Seg)=counterBinRun(Seg)+1;
                        AlreadyMeasuredTimes=RunningT{Seg,trial}(t+BinSize); % so it doesn't count timepoints twice
                    end
                    
                end
                
                for t=1:(length(StationaryT{Seg,trial}) - BinSize)
                    
                    if StationaryT{Seg,trial}(t+BinSize)==StationaryT{Seg,trial}(t)+BinSize && StationaryT{Seg,trial}(t)>AlreadyMeasuredTimesS %to consider only bins where each point is consecutive in time
                        
                        StationaryActivity{Seg}(counterBinStat(Seg))=nanmean(DeltaFoF(Seg,trial,StationaryT{Seg,trial}(t):StationaryT{Seg,trial}(t+BinSize)));
                        counterBinStat(Seg)=counterBinStat(Seg)+1;
                        AlreadyMeasuredTimesS=StationaryT{Seg,trial}(t+BinSize); % so it doesn't count timepoints twice
                    end
                    
                end
                
            end
        end
    end
    
    clear DeltaFoverF TimesSegment PointsInSegments MeanSegment Speed RunningT StationaryT %clear stuff before loading next stack
    
end


%% average bins and calculate standard error of the mean

for Seg=1:n_segments
    
    ActivitySegRun(Seg)=nanmean(RunningActivity{Seg});
    SemRun(Seg)=nanstd(RunningActivity{Seg})/sqrt(length(RunningActivity{Seg}));
    
    ActivitySegStat(Seg)=nanmean(StationaryActivity{Seg});
    SemStat(Seg)=nanstd(StationaryActivity{Seg})/sqrt(length(StationaryActivity{Seg}));
    
    ActivitySegAll(Seg)=nanmean([ RunningActivity{Seg} StationaryActivity{Seg} ]);
    SemAll(Seg)=nanstd([ RunningActivity{Seg} StationaryActivity{Seg} ])/sqrt(length([ RunningActivity{Seg} StationaryActivity{Seg} ]));
end

%% plot neuron dendritic tree color-coded for the activity

%attribute activity to each node
for node=1:size(NodesInfo,1)
    NodesActivityR(node)=ActivitySegRun(NodesInfo(node,1));
    NodesActivityS(node)=ActivitySegStat(NodesInfo(node,1));
    NodesActivityA(node)=ActivitySegAll(NodesInfo(node,1));
end

Cmin=min([ActivitySegRun ActivitySegStat]); %use same scale for all 3 graphs
Cmax=max([ActivitySegRun ActivitySegStat]);
CMap=hot; %colormap

%plot
figure;
plot_tree(SortedTree,NodesActivityS'); shine;
caxis([Cmin Cmax])
colormap(CMap)
colorbar
title('Stationary')

figure;
plot_tree(SortedTree,NodesActivityR'); shine;
caxis([Cmin Cmax])
colormap(CMap)
colorbar
title('Running')

figure;
plot_tree(SortedTree,NodesActivityA'); shine;
caxis([Cmin Cmax])
colormap(CMap)
colorbar
title('All')

%% plot bars with activity per segment, ordered following distance from the root

% find branch order (number of branches that separate its branch from the
% root)
NodesOrder=BO_tree(SortedTree); %TREES toolbox
%attribute branch order to branch
[~, Index]=unique(NodesInfo(:,1));
BranchOrder=NodesOrder(Index)+1; %this vector has n_segments elements and contains branch order

%build matrices to plot bar graph in 3d for three conditions
RepOrder=histc(BranchOrder,0:max(BranchOrder));

PlottingMatRun=NaN(max(RepOrder),max(BranchOrder));
SemMatRun=NaN(max(RepOrder),max(BranchOrder));
PlottingMatStat=NaN(max(RepOrder),max(BranchOrder));
SemMatStat=NaN(max(RepOrder),max(BranchOrder));
PlottingMatAll=NaN(max(RepOrder),max(BranchOrder));
SemMatAll=NaN(max(RepOrder),max(BranchOrder));

for brO=1:max(BranchOrder)
    branches=find(BranchOrder==brO);
    for b=1:length(branches)
        
        %running
        PlottingMatRun(end-b+1, brO)=ActivitySegRun(branches(b));
        SemMatRun(end-b+1, brO)=SemRun(branches(b));
        %stationary
        PlottingMatStat(end-b+1, brO)=ActivitySegStat(branches(b));
        SemMatStat(end-b+1, brO)=SemStat(branches(b));
        %all
        PlottingMatAll(end-b+1, brO)=ActivitySegAll(branches(b));
        SemMatAll(end-b+1, brO)=SemAll(branches(b));
        
    end
    clear branches
end

%plot 3d bars graph,NB: these 3 graphs do not have same scale
figure; bar3_std(PlottingMatRun,SemMatRun)
colormap(CMap); axis tight; box off
title('Running')

figure; bar3_std(PlottingMatStat,SemMatStat)
colormap(CMap); axis tight; box off
title('Stationary')

figure; bar3_std(PlottingMatAll,SemMatAll)
colormap(CMap); axis tight; box off
title('All')

% standard 2d bar plots
% figure; bar(ActivitySegRun)
% hold on; errorbar(ActivitySegRun,SemRun,'k.')
% box off, title('Running')
%
% figure; bar(ActivitySegStat)
% hold on; errorbar(ActivitySegStat,SemStat,'k.')
% box off, title('Stationary')
%
% figure; bar(ActivitySegAll)
% hold on; errorbar(ActivitySegAll,SemAll,'k.')
% box off, title('All')

%% plot activity versus distance from the root

BranchDist=zeros(1,n_segments);
%for each node calculate distance from the root along the dendritic tree
NodesDist=Pvec_tree(SortedTree); %TREES toolbox

%calculate mean distance from the root for each branch
for s=1:n_segments
    NodesInSeg=find(NodesInfo(:,1)==s);
    BranchDist(s)=median(NodesDist(NodesInSeg));
    clear NodesInSeg
end

Ymin=min([ActivitySegRun ActivitySegStat]);
Ymax=max([ActivitySegRun ActivitySegStat]);
Ymin=Ymin-Ymin*0.2;
Ymax=Ymax+Ymax*0.2;

%plot
figure;
errorbar(BranchDist,ActivitySegStat,SemStat,'k.','MarkerSize',20);
xlabel('Mean distance from the root'), ylabel('Average activity, Df/f')
ylim([Ymin Ymax])
box off
title('Stationary')

[R,P]=corrcoef(BranchDist,ActivitySegStat);
disp(['Correlation coefficient for stationary data ' num2str(R(1,2)) ' and P-value ' num2str(P(1,2))])

figure;
errorbar(BranchDist,ActivitySegRun,SemRun,'k.','MarkerSize',20);
xlabel('Mean distance from the root'), ylabel('Average activity, Df/f')
ylim([Ymin Ymax])
box off
title('Running')

[R,P]=corrcoef(BranchDist,ActivitySegRun);
disp(['Correlation coefficient for running data ' num2str(R(1,2)) ' and P-value ' num2str(P(1,2))])

%% save the data in the current folder

if FlagSave
    %save data
    Date=date;
    location=pwd;
    save(['BranchActivityRunStat ' date '.mat'])
    %save figures
    saveas(gcf,'RunningAct Vs Dist.fig')
    saveas(gcf-1,'StatAct Vs Dist.fig')
    saveas(gcf-2,'3DBarPlot AllPeriods.fig')
    saveas(gcf-3,'3DBarPlot StationaryPeriods.fig')
    saveas(gcf-4,'3DBarPlot RunningPeriods.fig')
    saveas(gcf-5,'Neuron AllPeriods.fig')
    saveas(gcf-6,'Neuron RunningPeriods.fig')
    saveas(gcf-7,'Neuron StationaryPeriods.fig')
    
end


end

