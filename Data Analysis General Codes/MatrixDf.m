function [ DF ] = MatrixDf( DataGreenCh, Points, Title )
%calculate deltaF/F for Points in DataGreenCh, and plots the matrix with
%trials and responses, and saves the figure with the title

if nargin<3
    FlagSave=0;
    Title=' ';
else
    FlagSave=1;
end

n_trials=size(DataGreenCh,1);
n_points=size(DataGreenCh,2);
n_TimePoints=size(DataGreenCh,3);

DF=zeros(n_trials,n_TimePoints);

Act=squeeze(mean(DataGreenCh(:,Points,:),2));

for t=1:n_trials
    baseline=mean(Act(t,1:100));
    DF(t,:)=(Act(t,:) - baseline)./baseline;
end

figure; imagesc(DF); colorbar;
title([ Title ' : Points ' num2str(Points)])

if FlagSave==1
saveas(gcf,[ Title '.fig'])
end

end

