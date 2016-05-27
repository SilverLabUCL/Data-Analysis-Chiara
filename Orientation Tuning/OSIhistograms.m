function [ OSI,DI,best_ori,best_dir ] = OSIhistograms( or_tuningcurves_Input )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if iscell(or_tuningcurves_Input)==1
    %convert cell to matrix
    n_cells=length(or_tuningcurves_Input);
    n_ori=size(or_tuningcurves_Input{4},1);
    or_tuningcurves=zeros(n_cells,n_ori);
    for i=1:n_cells
        if isempty(or_tuningcurves_Input{i})==0
            or_tuningcurves(i,:)=or_tuningcurves_Input{i};
        else
            or_tuningcurves(i,1:n_ori)=NaN;
        end
    end
    
else
    or_tuningcurves=or_tuningcurves_Input;
    n_cells=size(or_tuningcurves,1);
end

best_dir=NaN(1,n_cells);
DI=NaN(1,n_cells);
best_ori=NaN(1,n_cells);
OSI=NaN(1,n_cells);
ydatai = NaN(n_cells,360);
null_ori=NaN(1,n_cells);

for cell=1:n_cells
    if isnan(or_tuningcurves(cell,1))==0
    [best_dir(cell),DI(cell),best_ori(cell),null_ori(cell),OSI(cell),ydatai(cell,:)] = InterpDirTuning (or_tuningcurves(cell,:), 'cubic', 1);
    figure(gcf); title(['Segment number ' num2str(cell)])
    end

end

figure; 
hist(OSI)
title('Orientation selectivity index')

figure; 
hist(DI)
title('Direction selectivity index')

% figure;
% scatter(OrCells,best_ori(OrCells),'r')

save('OSI.mat','OSI','DI','best_ori','best_dir','null_ori','ydatai')

end

