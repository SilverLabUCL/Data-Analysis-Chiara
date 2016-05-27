function [ Concat,ConcatTime ] = ConcatenateTrials( DataGreenCh, Times, Point, SmoothingFactor,trials )

if nargin<5
   trials=1:size(DataGreenCh,1);
end

if nargin<4
    SmoothingFactor=1;
end

n_trials=length(trials);
n_timepoints=size(DataGreenCh,3);
Concat=zeros(1,n_trials*n_timepoints);
ConcatTime=zeros(1,n_trials*n_timepoints);
DeltaFoverF=zeros(n_trials,length(Point),n_timepoints);

for p=1:length(Point)

    %calculate DeltaFoverF
%     for t=1:n_trials
%         MeanFluor=DataGreenCh(trials(t),Point(p),:);
%         HighLim=prctile(MeanFluor,80);
%         LowLim=prctile(MeanFluor,20);
%         SortedVal=MeanFluor(MeanFluor>LowLim);
%         SortedVal=SortedVal(SortedVal<HighLim);
%         Baseline=mean(SortedVal);
%         
%         DeltaFoverF(t,p,:)=(DataGreenCh(trials(t),Point(p),:)-Baseline)./Baseline;
%         
%         clear SortedVal MeanFluor
%     end
    
        FluoSeg=reshape(DataGreenCh(trials,Point(p),:),1,[]);
        HighLim=prctile(FluoSeg,80);
        LowLim=prctile(FluoSeg,20);
        SortedVal=FluoSeg(FluoSeg>LowLim);
        SortedVal=SortedVal(SortedVal<HighLim);
        Baseline=nanmean(SortedVal);
        
        if Baseline==0 
            SortedVal=FluoSeg(FluoSeg>LowLim);
            Baseline=nanmean(SortedVal);
        end
        
        DeltaFoverF(:,p,:)=(DataGreenCh(trials,Point(p),:)-Baseline)./Baseline;
        DeltaFoverF(:,p,:)=(DataGreenCh(trials,Point(p),:));
        clear SortedVal FluoSeg
end

%average points

DeltaFoverFAv=squeeze(mean(DeltaFoverF,2));
TimeAv=squeeze(mean(Times(trials,Point,:),2));

%Concatenate trials
for i=1:n_trials
    
    Concat((i-1)*n_timepoints+1:i*n_timepoints)=squeeze(DeltaFoverFAv(i,:));
    if i==1
        ConcatTime((i-1)*n_timepoints+1:i*n_timepoints)=squeeze(TimeAv(i,:));
    else
        ConcatTime((i-1)*n_timepoints+1:i*n_timepoints)=squeeze(TimeAv(i,:)) + TimeAv(i-1,n_timepoints)*(i-1);
    end
end

ConcatTime=ConcatTime*1e-3; %convert from ms to seconds

%smooth
Concat=smooth(Concat,SmoothingFactor);

%plot
figure; plot(ConcatTime,Concat)
axis tight
ylabel('DeltaF / F')
xlabel('seconds')


end

