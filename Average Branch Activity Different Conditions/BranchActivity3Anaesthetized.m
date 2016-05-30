function [StationaryActivity] = BranchActivity3Anaesthetized(nStacks,n_segments,FlagSave,Cmin,Cmax)
%calculate branch activity for different animal states: running and stationary.

%% parameters

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

FilesLoaded=cell(nStacks,1);
StationaryActivity=cell(n_segments,1);
counterBinStat=ones(n_segments,1);

for s=1:nStacks
    [filename,pathname]=uigetfile('*.mat'); %the user needs to load a file that contains a matrix DeltaFoverF_Sm(cell,trial,time)
    FilesLoaded{s}=[pathname filename];
    load(FilesLoaded{s},'DeltaFoverF','TimesSegment','PointsInSegments','MeanSegment','NodesInfo','SortedTree')
    
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
    
    
    %% divide recordings into bins and calculate activity in the bin as mean of deltaF/F
    
    for Seg=1:n_segments
        
        BinSize=round(BinSizeMs/TimesSegment(Seg,1,2));
        
        for trial=1:n_trials

            AlreadyMeasuredTimesS=0;
            
            if  isempty(PointsInSegments{1,Seg})==0 && isnan(squeeze(MeanSegment(Seg,1,1)))==0 %if segments has points
                
                for t=1:(n_timepoints - BinSize)
                    
                    if t>AlreadyMeasuredTimesS 
                        
                        StationaryActivity{Seg}(counterBinStat(Seg))=nanmean(DeltaFoF(Seg,trial,t:t+BinSize));
                        counterBinStat(Seg)=counterBinStat(Seg)+1;
                        AlreadyMeasuredTimesS=t+BinSize; % so it doesn't count timepoints twice
                    end
                    
                end
            end
        end
    end
    
    clear DeltaFoverF TimesSegment PointsInSegments MeanSegment %clear stuff before loading next stack
    
end


%% average bins and calculate standard error of the mean

for Seg=1:n_segments
    ActivitySegStat(Seg)=mean(StationaryActivity{Seg});
    SemStat(Seg)=std(StationaryActivity{Seg})/sqrt(length(StationaryActivity{Seg}));
end

%% plot neuron dendritic tree color-coded for the activity

%attribute activity to each node
for node=1:size(NodesInfo,1)
    NodesActivityS(node)=ActivitySegStat(NodesInfo(node,1));
end

CMap=hot; %colormap

%plot
figure;
plot_tree(SortedTree,NodesActivityS'); shine;
colormap(CMap)
colorbar

if nargin > 3
    figure;
    plot_tree(SortedTree,NodesActivityS'); shine;
    colormap(CMap)
    colorbar
    caxis([Cmin Cmax])
end


%% plot bars with activity per segment, ordered following distance from the root

% find branch order (number of branches that separate its branch from the
% root)
NodesOrder=BO_tree(SortedTree); %TREES toolbox
%attribute branch order to branch
[~, Index]=unique(NodesInfo(:,1));
BranchOrder=NodesOrder(Index)+1; %this vector has n_segments elements and contains branch order

%build matrices to plot bar graph in 3d for three conditions
RepOrder=histc(BranchOrder,0:max(BranchOrder));

PlottingMatStat=NaN(max(RepOrder),max(BranchOrder));
SemMatStat=NaN(max(RepOrder),max(BranchOrder));

for brO=1:max(BranchOrder)
    branches=find(BranchOrder==brO);
    for b=1:length(branches)

        %stationary
        PlottingMatStat(end-b+1, brO)=ActivitySegStat(branches(b));
        SemMatStat(end-b+1, brO)=SemStat(branches(b));
        
    end
    clear branches
end

%plot 3d bars graph,NB: these 3 graphs do not have same scale
figure; bar3_std(PlottingMatStat,SemMatStat)
colormap(CMap); axis tight; box off

% standard 2d bar plots

% figure; bar(ActivitySegStat)
% hold on; errorbar(ActivitySegStat,SemStat,'k.')
% box off, title('Stationary')


%% save the data in the current folder

if FlagSave
    %save data
    Date=date;
    location=pwd;
    save(['BranchActivityAnaesthet ' date '.mat'])
    
    %save figures
    if nargin>3
        saveas(gcf,'3DBarPlot.fig')
        saveas(gcf-1,'Neuron Branch Act ManualScale.fig')
        saveas(gcf-2,'Neuron Branch Act.fig')
    else
        saveas(gcf,'3DBarPlot.fig')
        saveas(gcf-1,'Neuron Branch Act.fig')
    end
    
end


end

