function [ DeltaFoverF_Sm, DeltaFoverF, TimesSegment, RedChannelData, DeltaFoverF_Sm_Lin , Times_Lin] = DeltaFoFPOIsDendrites5RemovePOIs(PathExp,RedChFlag,SmoothingFactor)
%This function calculates mean from all POIs in a dendrite, deltafoverf and
%then concatenates trials. If red channel is present, controls for
%movement.


% version 5: initialise all variables to NaN, not to zeros. So missing segments have NaNs

%% default inputs
if nargin<1
    PathExp=pwd; %pathway of experiment to analyse: defaut is current folder
end

if nargin<2
    RedChFlag=true; %use red channel to correct for movement
end

if nargin<3
    if RedChFlag
        SmoothingFactor=10; %less smoothing if red channel correction is on, because a bit of smoothing done already there
    else
        SmoothingFactor=20;
    end
end

%% load data

if exist([PathExp '\pointTraces.mat']) == 1
    load([PathExp '\pointTraces.mat'])
    load([PathExp '\images.mat'])
else
     Slash = find(PathExp == '\',1,'last');
     PathUp = PathExp(1:Slash);
     load([PathUp 'pointTraces.mat'])
     load([PathUp 'images.mat'])
end


MatFiles = dir('*.mat');  % find mat files
PutPointsFile = [];
counter = 0;

for i = 1:length(MatFiles)
    if strcmp(MatFiles(i,1).name,'PutPointsInDendritesRemovedPOIsMultipleCells.mat') == 1 % find mat files that start with PutP
        counter = counter + 1;
        PutPointsFile(counter) = i;
    end
end

if counter == 1
    string = MatFiles(PutPointsFile,1).name;
else
    [FileName, PathName]=uigetfile('*.mat','Select the file with the data that attributes imaged POIs to dendritic branches');
    string=[PathName FileName];
end
load(string)

%attribute some basic variables
n_segments=length(PointsInSegments);
n_trials=size(DataGreenCh,1);
n_timepoints=size(DataGreenCh,3);

%% Visual stimulation parameters for final plot: leave empty if don't want to
%plot bars corresponding to when visual stimuli went on

if n_trials == 16 %gratings
    TimeVisStim1=2; %time when visual stimulus goes on in each trial, in seconds
    TimeVisStim2=4; %time when second visual stimulus goes on in each trial, in seconds
    TimeVisStim3=[];
    TrialLength=8; %length of each trial, in seconds
elseif n_trials == 24 % retinotopy
    TimeVisStim1=2;
    TimeVisStim2=[];
    TimeVisStim3=[];
    TrialLength=5;
% elseif n_trials == 10 % natural images
%     TimeVisStim1=2;
%     TimeVisStim2=5;
%     TimeVisStim3=8;
%     TrialLength=11;
else
    TimeVisStim1=[];
    TimeVisStim2=[];
    TimeVisStim3=[];
    TrialLength=5;
end

%% correct for movement with red channel
if RedChFlag
    [GreenOverRed]=CorrectMovementRedCh5(DataGreenCh,DataRedCh, Times, false);
    GreenData=GreenOverRed;
else
    GreenData=DataGreenCh;
end

%% calculate mean for all points in a segment
MeanSegment=zeros(n_segments,n_trials,n_timepoints);
MeanSegmentRed=zeros(n_segments,n_trials,n_timepoints);
TimesSegment=NaN(n_segments,n_trials,n_timepoints);%same as above , but for times

for Seg=1:n_segments
    if isempty(PointsInSegments{1,Seg})==0
        
        POIs=PointsInSegments{1,Seg};
        IndPOIs2Seg=find(ismember(POIs,POIsIn2Segm)); %check if any of the POIs are in 2 segments, and in that case discards them
        POIs(IndPOIs2Seg)=[];
        
        for trial=1:n_trials
            MeanSegment(Seg,trial,:)=nanmean(GreenData(trial,POIs,:),2); %green channel
            MeanSegmentRed(Seg,trial,:)=nanmean(DataRedCh(trial,POIs,:),2); %red channel
            TimesSegment(Seg,trial,:)=nanmean(Times(trial,POIs,:),2);
        end
        clear POIs IndPOIs2Seg
    end
end


%% calculate deltafoverf and smooth
DeltaFoverF=NaN(n_segments,n_trials,n_timepoints);

%calculate baseline for each trial separately, as the mean fluorescence in
%time for that segment, but taking out the highest and lowest values before
%calculating the mean
% for Seg=1:n_segments
%     if isempty(PointsInSegments{1,Seg})==0 && isnan(squeeze(MeanSegment(Seg,1,1)))==0
%         for trial=1:n_trials
%             MeanFluor=MeanSegment(Seg,trial,:);
%             HighLim=prctile(MeanFluor,80);
%             LowLim=prctile(MeanFluor,10);
%             SortedVal=MeanFluor(MeanFluor>LowLim);
%             SortedVal=SortedVal(SortedVal<HighLim);
%             Baseline=nanmean(SortedVal);
%             Baseline=LowLim; %7 October 2013, changed to take the baseline as the lowest 10% values of the trace
%
%             if Baseline==0 || isnan(Baseline)==1
%                 Baseline=nanmean(MeanFluor);
%             end
%
%             DeltaFoverF(Seg,trial,:)=(MeanSegment(Seg,trial,:)-Baseline)./Baseline;
%
%             clear SortedVal MeanFluor
%         end
%     end
% end

%calculate baseline as the mean fluorescence in
%time for that segment, but taking out the highest and lowest values. Here it takes the mean fluorescence
%of the same segment across all trials
for Seg=1:n_segments
    if isempty(PointsInSegments{1,Seg})==0 && nansum(MeanSegment(Seg,1,:)) ~=0 %if there are points in the segment
        FluoSeg=reshape(MeanSegment(Seg,:,:),1,[]);
        HighLim=prctile(FluoSeg,80); %remove higher and lower 20% of the values
        LowLim=prctile(FluoSeg,20);
        SortedVal=FluoSeg(FluoSeg>LowLim);
        SortedVal=SortedVal(SortedVal<HighLim);
        Baseline=nanmean(SortedVal);
        
        if Baseline==0
            SortedVal=FluoSeg(FluoSeg>LowLim);
            Baseline=nanmean(SortedVal);
        end
        
        DeltaFoverF(Seg,:,:)=(MeanSegment(Seg,:,:)-Baseline)./Baseline;
        
        clear SortedVal FluoSeg
    end
end

%smooth
DeltaFoverF_Sm=NaN(n_segments,n_trials,n_timepoints);
RedChannelData=NaN(n_segments,n_trials,n_timepoints);

for Seg=1:n_segments
    if isempty(PointsInSegments{1,Seg})==0 && nansum(MeanSegment(Seg,1,:)) ~= 0
        for trial=1:n_trials
            if sum(isnan(DeltaFoverF(Seg,trial,:))) < 50 % don't smooth if there are too many nan because then creates weird things
                DeltaFoverF_Sm(Seg,trial,:)=smooth(DeltaFoverF(Seg,trial,:),SmoothingFactor,'lowess');
                RedChannelData(Seg,trial,:)=smooth(MeanSegmentRed(Seg,trial,:),SmoothingFactor,'lowess');
            else
                DeltaFoverF_Sm(Seg,trial,:)=DeltaFoverF(Seg,trial,:);
                RedChannelData(Seg,trial,:)=MeanSegmentRed(Seg,trial,:);
            end
        end
    end
end


%% plot deltafoverf for each segment in a different figure, and it concatenates
%all trials in time

DeltaFoverF_Sm_Lin=NaN(n_segments,n_trials*n_timepoints);
RedChannelData_Lin=NaN(n_segments,n_trials*n_timepoints);
Times_Lin=NaN(n_segments,n_trials*n_timepoints);

for Seg=1:n_segments
    if isempty(PointsInSegments{1,Seg})==0 && nansum(MeanSegment(Seg,1,:)) ~= 0
        
        %concatenate deltafof and recordings in the red channel
        temp=squeeze(DeltaFoverF_Sm(Seg,:,:));
        DeltaFoverF_Sm_Lin(Seg,:)=reshape(temp',1,[]);
        
        temp1=squeeze(RedChannelData(Seg,:,:));
        RedChannelData_Lin(Seg,:)=reshape(temp1',1,[]);
        
        clear temp temp1
        
        %concatenate time
        EndPreviousTrial=0;
        for trial=1:n_trials
            Times_Lin(Seg, (trial-1)*n_timepoints+1 : n_timepoints*trial)=TimesSegment(Seg,trial,:) + EndPreviousTrial;
            EndPreviousTrial=Times_Lin(Seg,n_timepoints*trial);
        end
        
        %plot
        figure;
        
        %plot deltaF/F data from green channel
        handle=subplot(2,1,1);
        h=plot(squeeze(Times_Lin(Seg,:))*1e-3,squeeze(DeltaFoverF_Sm_Lin(Seg,:)),'b');
        set(h,'LineWidth',1.5)
        hold on
        ylabel('DeltaF / F','FontSize',25, 'FontWeight', 'Bold','FontName','Tahoma')
        set(gca,'FontSize',25, 'FontWeight','Bold','XTick',[])
        axis tight, box off
        xlim([-1 Times_Lin(Seg,end)*1e-3+1])
        
        %plot bars for visual stimulation
        YVector=min(DeltaFoverF_Sm_Lin(Seg,:)) : ( (abs(min(DeltaFoverF_Sm_Lin(Seg,:)))+abs(max(DeltaFoverF_Sm_Lin(Seg,:))))/1e2 )  : max(DeltaFoverF_Sm_Lin(Seg,:));
        for trial=1:n_trials
            if isempty(TimeVisStim1)==0
                TimeVisStimTrial1=TimeVisStim1 + ((trial-1)*TrialLength);
                VisStimPlot1=repmat(TimeVisStimTrial1,length(YVector),1);
                plot(VisStimPlot1,YVector,'-','Color',[0.8 0.8 0.8]) %gray
                hold all
            end
            
            if isempty(TimeVisStim2)==0
                TimeVisStimTrial2=TimeVisStim2 + ((trial-1)*TrialLength);
                VisStimPlot2=repmat(TimeVisStimTrial2,length(YVector),1);
                plot(VisStimPlot2,YVector,'-','Color',[0.9 0.75 0.0]) %gold
                hold all
            end
            
            if isempty(TimeVisStim3)==0
                TimeVisStimTrial3=TimeVisStim3 + ((trial-1)*TrialLength);
                VisStimPlot3=repmat(TimeVisStimTrial3,length(YVector),1);
                plot(VisStimPlot3,YVector,'-','Color',[0.9 0.75 0.0]) %gold
                hold all
            end
        end
        
        %plot red data
        handle2=subplot(2,1,2);
        h=plot(squeeze(Times_Lin(Seg,:))*1e-3,squeeze(RedChannelData_Lin(Seg,:)),'r');
        set(h,'LineWidth',1.5)
        hold on
        xlabel('Time (seconds)','FontSize',25, 'FontWeight', 'Bold','FontName','Tahoma'), ylabel('Red','FontSize',25, 'FontWeight', 'Bold','FontName','Tahoma')
        set(gca,'FontSize',25, 'FontWeight','Bold')
        axis tight, box off
        xlim([-1 Times_Lin(Seg,end)*1e-3+1])
        
        %set subplot positions and sizes
        Pos=get(handle,'Position'); %subplot 1 - green
        Pos(2)=Pos(2) - Pos(4)/2 - 0.1;
        Pos(4)=Pos(4) + Pos(4)/2 + 0.1;
        set(handle,'Position',Pos)
        
        Pos2=get(handle2,'Position'); %subplot 2 - red
        Pos2(4)=Pos2(4)/2;
        set(handle2,'Position',Pos2)
        
        %title
        handle3=suptitle(['Segment ' num2str(Seg)]);
        set(handle3, 'FontSize',35, 'FontWeight', 'Bold','FontName','Tahoma','Color','b')
        
        %save figures and data in current folder
        ImageHandle=gcf;
        name=['Segment ' num2str(Seg) '.fig'];
        saveas(ImageHandle,name)
        
    end
end

save(['DFoF' date '.mat'])

end






