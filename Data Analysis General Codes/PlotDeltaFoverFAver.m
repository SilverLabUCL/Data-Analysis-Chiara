%Plot deltaF over F of the points and averages it across the points
%%%
%inputs:
% - Times: matrix(trial,point,timepoint) containing the values of the time points in ms,
% output of the script 'extractdata2'
% - DataGreenCh: matrix(trial,point,timepoint) containing raw intensity values for green channel,
% output of the script 'extractdata2'
% - InpP: points whose traces you want to plot
% - SmoothingFactor: smoothing factor. Equal to 1 for no smoothing
% - ImageHandle

%output
% - one figure with deltaF over F averaged for points InpP 

function [DeltaFoverFAv,time]=PlotDeltaFoverFAver(Times, DataGreenCh, InpP, trial, SmoothingFactor, ImageHandle)

%default inputs
if nargin<6
    
FigHandles = findall(0,'Type','figure');
if isempty(FigHandles)==0
    ImageHandle=max(FigHandles)+1;
else
    ImageHandle=1;
end

end


if nargin<5
SmoothingFactor=10;
end

n_timepoints=size(DataGreenCh,3);

DeltaFoverF=zeros(length(InpP),n_timepoints);
    
%compute deltaFoverF
for point=1:length(InpP)
    
    time(1:n_timepoints)=Times(trial,InpP(point),:);
    data(1:n_timepoints)=DataGreenCh(trial,InpP(point),:);
    baseline=mean(data(1:100));
    DeltaFoverF(point,:)=(data-baseline)./baseline;
    DeltaFoverF(point,:)=smooth(DeltaFoverF(point,:),SmoothingFactor);
end


DeltaFoverFAv=mean(DeltaFoverF,1); 

figure(ImageHandle);    
plot(time,DeltaFoverFAv)
title(['DeltaF/F, Points ' num2str(InpP) ' Trials ' num2str(trial)])








end