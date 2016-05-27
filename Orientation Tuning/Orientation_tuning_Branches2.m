function [ BigAllStructure, Or_Tuning_SumRNorm, SemSumNorm] = Orientation_tuning_Branches2(nStacks,FlagCompareMethods, FilesLoaded)

%  it computes orientation tuning for several stacks taken on the same
%  cells, it takes data coming out from the code PutPointsInCells

% January 2015: adapted to work on dendrites instead of cells, takes data
% coming out from code: deltaFPOisDendrites

%The user has to load the deltaFoverF for each stack, where deltafof
%has been calculated with the code PutPointsInCells (or Put_Points_In_Dendrites for dendrites) and with the same ID number fot the same cells in different stacks.
%
%All the loaded data is sorted in a matrix BigAllStructure {cell} (orientation, repetition, time)of one trial.
%Then responses are detected as mean, median, peak or sum (=integral) of
%the trace when the stimulus is presented. Each repetition of all the
%orientations (basically each tuning curve) is
%normalized, i.e. the smaller response is substracted to all the
%others, so all the tuning curves start from zero, have the same offset.
%An average tuning curve and standard error of the mean are calculated from all repetitions and plotted.
%Data and all the figures are saved in the current folder.

%%% inputs:
%- nStacks : number of stacks to analyze
%- FlagCompareMethods: equal to true if you want to plot extra graphs with the tuning curves resulting from different methods
%(mean, median and sum/integral of deltaF/F)

%%% outputs:
%- BigAllStructure: {cell} (orientation, repetition, time of one trial). Contains all the data
%- Or_Tuning_SumR: orientation tuning curve for each segment, obtained by
%summing the fluorescence (integral of the response) during time when the stimulus is presented.
% - SemSum: standard error of the mean of the above tuning curve

%%%% NB Check visual stimulation parameters (when stimulus goes on, length
% of trial, etc) before running the code!!!


if nargin<2
    FlagCompareMethods=true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% characteristics of the visual stimuli

n_orientations=8; %number of orientations
n_repetitions=2; %number of repetitions in one trial

timeOneTrial=8000; %time of one trial in milliseconds
start_delay=2000;  %time from the trigger to when the visual stimulus starts, in ms
or_time=4000; %for how long the visual stimulus is presented, in ms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ask the user to load the DeltaFoF for points in the stacks

if nargin<1 %if number of stacks isn't specified as input of the function
    nStacks=inputdlg('How many stacks do you want to analyze?');
    nStacks=str2double(nStacks{1});
end

nTimepoints=zeros(1,nStacks); %contains number of timepoints for each stack (it depends on the number of points put in each stack!)
MaxCellN=zeros(1,nStacks);%max cell number in each stack

%load the data into the cell array DeltaFoverF{stack} (cell,trial,time)
for s=1:nStacks
    if nargin < 3
        [filename,pathname]=uigetfile('*.mat'); %the user needs to load a file that contains a matrix DeltaFoverF_Sm(cell,trial,time)
        FilesLoaded{s}=[pathname filename];
    end
    load(FilesLoaded{s},'DeltaFoverF_Sm','TimesSegment')
%     load(FilesLoaded{s},'DfoFAll','TimesSegment')
%     DeltaFoverF_Sm =  DfoFAll;
    
    DeltaFoF{s}=DeltaFoverF_Sm;
    TimesSeg{s}=TimesSegment;
    
    nTimepoints(s)=size(DeltaFoverF_Sm,3);
    clear DeltaFoverF_Sm
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sort the data in BigAllStructure {cell} (orientation, repetition, time of
%one trial(ms))
n_segments=size(DeltaFoF{1},1);
n_trials=size(DeltaFoF{1},2);
n_max_timepoints=max(nTimepoints);%maximum number of timepoints in all stacks
n_rep=zeros(1,n_segments); %number of repetitions for each cell

for seg=1:n_segments
    
    RepetitionFlag=1;
    
    for stack=1:nStacks
        
        OrFlag=0;
        
        for trial=1:n_trials
            
            BigAllStructure{seg}(trial-OrFlag,RepetitionFlag,1:n_max_timepoints)=NaN;
            BigAllStructure{seg} (trial-OrFlag,RepetitionFlag,1:nTimepoints(stack))=DeltaFoF{stack} (seg, trial, : );
            
            BigAllStructureTimes{seg}(trial-OrFlag,RepetitionFlag,1:n_max_timepoints)=NaN;
            BigAllStructureTimes{seg} (trial-OrFlag,RepetitionFlag,1:nTimepoints(stack))=TimesSeg{stack} (seg, trial, : );
            
            if mod(trial,n_orientations)==0
                RepetitionFlag=1+RepetitionFlag;
                OrFlag=OrFlag+n_orientations;
            end
        end
    end
    
    n_rep(seg)=RepetitionFlag-1;
    
    if n_rep(seg)==0
        BigAllStructure{seg} =[];
        BigAllStructureTimes{seg}=[];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute orientation tuning... try different things to measure responses:
%mean, median, maximum peak, sum
or_tuning_meanR = cell(1,n_segments);
or_tuning_medianR = cell(1,n_segments);
or_tuning_peakR = cell(1,n_segments);
or_tuning_sumR = cell(1,n_segments);

for seg=1:n_segments
    
    if isempty(BigAllStructure{seg})==0 && sum(isnan(reshape(BigAllStructure{seg},1,[]))) < length(reshape(BigAllStructure{seg},1,[]))*0.9
        
        for or=1:n_orientations
            for rep=1:n_rep(seg)
                Diff_StartStim=abs(BigAllStructureTimes{seg}(or,rep,:)-start_delay);
                Index_Start=find(Diff_StartStim==min(Diff_StartStim));
                
                Diff_EndStim=abs(BigAllStructureTimes{seg}(or,rep,:)- (start_delay+or_time) );
                Index_End=find(Diff_EndStim==min(Diff_EndStim));
                
                if isempty(Index_Start)==0
                    or_tuning_meanR{seg} (or,rep)=nanmean(BigAllStructure{seg}(or,rep,Index_Start(1) : Index_End(end)));
                    or_tuning_medianR{seg} (or,rep)=nanmedian(BigAllStructure{seg}(or,rep,Index_Start(1) : Index_End(end)));
                    or_tuning_peakR{seg} (or,rep)=nanmax(BigAllStructure{seg}(or,rep,Index_Start(1) : Index_End(end)));
                    or_tuning_sumR{seg} (or,rep)=nansum(BigAllStructure{seg}(or,rep,Index_Start(1) : Index_End(end)));
                else
                    or_tuning_meanR{seg} (or,rep)=NaN;
                    or_tuning_medianR{seg} (or,rep)=NaN;
                    or_tuning_peakR{seg} (or,rep)=NaN;
                    or_tuning_sumR{seg} (or,rep)=NaN;
                end
                clear Index_Start Index_End
            end
        end
        
    else
        
        or_tuning_meanR{seg} = NaN;
        or_tuning_medianR{seg}=NaN;
        or_tuning_peakR{seg}=NaN;
        or_tuning_sumR{seg} =NaN;
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalize each repetition to minimum response to orientations

for seg=1:n_segments
    
    if length(or_tuning_meanR{seg})>1
        for rep=1:n_rep(seg)
            or_tuning_meanRNorm{seg}(:,rep)=or_tuning_meanR{seg}(:,rep)-min(or_tuning_meanR{seg}(:,rep));
            or_tuning_peakRNorm{seg}(:,rep)=or_tuning_peakR{seg}(:,rep)-min(or_tuning_peakR{seg}(:,rep));
            or_tuning_sumRNorm{seg}(:,rep)=or_tuning_sumR{seg}(:,rep)-min(or_tuning_sumR{seg}(:,rep));
        end
        
    else
        or_tuning_meanRNorm{seg}=NaN;
        or_tuning_peakRNorm{seg}=NaN;
        or_tuning_sumRNorm{seg}=NaN;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%average across repetitions

for seg=1:n_segments
    if length(or_tuning_meanR{seg})>1
        
        Or_Tuning_MeanR{seg}=nanmean(or_tuning_meanR{seg},2);
        Or_Tuning_MedianR{seg}=nanmean(or_tuning_medianR{seg},2);
        Or_Tuning_PeakR{seg}=nanmean(or_tuning_peakR{seg},2);
        Or_Tuning_SumR{seg}=nanmean(or_tuning_sumR{seg},2);
        
        Or_Tuning_mMeanRNorm{seg}=nanmean(or_tuning_meanRNorm{seg},2);
        Or_Tuning_PeakRNorm{seg}=nanmean(or_tuning_peakRNorm{seg},2);
        Or_Tuning_SumRNorm{seg}=nanmean(or_tuning_sumRNorm{seg},2);
        
    else
        Or_Tuning_MeanR{seg}=NaN;
        Or_Tuning_MedianR{seg}=NaN;
        Or_Tuning_PeakR{seg}=NaN;
        Or_Tuning_SumR{seg}=NaN;
        
        Or_Tuning_mMeanRNorm{seg}=NaN;
        Or_Tuning_PeakRNorm{seg}=NaN;
        Or_Tuning_SumRNorm{seg}=NaN;
    end
end

%calculate standard errors of the mean across repetitions
for Seg=1:n_segments
    
    if length(or_tuning_meanR{Seg})>1
        
        for or=1:n_orientations
            SemMean{Seg}(or)=nanstd(or_tuning_meanR{Seg}(or,:))/sqrt(length(or_tuning_meanR{Seg}(or,:)));
            SemMedian{Seg}(or)=nanstd(or_tuning_medianR{Seg}(or,:))/sqrt(length(or_tuning_medianR{Seg}(or,:)));
            SemPeak{Seg}(or)=nanstd(or_tuning_peakR{Seg}(or,:))/sqrt(length(or_tuning_peakR{Seg}(or,:)));
            SemSum{Seg}(or)=nanstd(or_tuning_sumR{Seg}(or,:))/sqrt(length(or_tuning_sumR{Seg}(or,:)));
            SemMeanNorm{Seg}(or)=nanstd(or_tuning_meanRNorm{Seg}(or,:))/sqrt(length(or_tuning_meanRNorm{Seg}(or,:)));
            SemSumNorm{Seg}(or)=nanstd(or_tuning_sumRNorm{Seg}(or,:))/sqrt(length(or_tuning_sumRNorm{Seg}(or,:)));
        end
        
    else
        SemMean{Seg}=NaN;
        SemMedian{Seg}=NaN;
        SemPeak{Seg}=NaN;
        SemSum{Seg}=NaN;
        SemMeanNorm{Seg}=NaN;
        SemSumNorm{Seg}=NaN;
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot
colormap=jet(n_segments);

for Seg=1:n_segments
    
    if FlagCompareMethods == 1 && length(Or_Tuning_MeanR{Seg})> 1
        figure;
        suptitle(['Segment ' num2str(Seg)])
        
        subplot(2,2,1)
        Vector(1:n_orientations)=Or_Tuning_mMeanRNorm{Seg};
        StDev(1:n_orientations)=SemMeanNorm{Seg};
        errorbar(Vector,StDev)
        title('Mean normalized')
        
        subplot(2,2,2)
        Vector(1:n_orientations)=Or_Tuning_PeakR{Seg};
        StDev(1:n_orientations)=SemPeak{Seg};
        errorbar(Vector,StDev)
        title('Max Peak')
        
        subplot(2,2,3)
        Vector(1:n_orientations)=Or_Tuning_SumR{Seg};
        StDev(1:n_orientations)=SemSum{Seg};
        errorbar(Vector,StDev)
        title('Integral')
        
        subplot(2,2,4)
        Vector(1:n_orientations)=Or_Tuning_SumRNorm{Seg};
        StDev(1:n_orientations)=SemSumNorm{Seg};
        errorbar(Vector,StDev)
        title('Integral Normalized')
        
        name=['segment ' num2str(Seg) ' Or Tuning CompareMethods'];
        handle=gcf;
        saveas(handle,name)
        
        clear Vector StDev
    end
    
    if length(Or_Tuning_SumRNorm{Seg})>1
        
        figure;
        Vector(1:n_orientations)=Or_Tuning_mMeanRNorm{Seg};
        StDev(1:n_orientations)=SemMeanNorm{Seg};
        errorbar(Vector,StDev,'Color',[0 0.498039215803146 0],'LineWidth',2)
        title(['Segment ' num2str(Seg)], 'FontSize',35, 'FontWeight', 'Bold','FontName','Calisto MT','Color',colormap(Seg,1:3))
        xlabel('Visual Stimulus','FontSize',25, 'FontWeight', 'Bold','FontName','Calisto MT'), ylabel('Average Response, DF/F','FontSize',25, 'FontWeight', 'Bold','FontName','Calisto MT')
        set(gca,'FontSize',25, 'FontWeight','Bold')
        box off
        
        clear Matrix2D Vector
        
        name=['segment ' num2str(Seg) ' Or Tuning'];
        handle=gcf;
        saveas(handle,name)
        
        
        figure;
        Matrix2D(1:n_orientations,1:n_rep(Seg))=or_tuning_meanRNorm{Seg}(:,:);
        plot(Matrix2D,'-ko')
        xlim([0 9])
        hold on
        Vector(1:n_orientations)=Or_Tuning_mMeanRNorm{Seg};
        plot(Vector,'-ro')
        title(['Cell ' num2str(Seg)])
        
        name=['segment ' num2str(Seg) 'Or tuning ALlCurves'];
        handle=gcf;
        saveas(handle,name)
        
        
        clear Matrix2D Vector
    end
    
end


Date=date;
location=pwd;
save('OrTuning.mat');

end


