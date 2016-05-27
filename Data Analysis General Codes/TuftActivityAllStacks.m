function [ AllStacksConcat, TimeAllStacks ] = TuftActivityAllStacks( nStacks, FlagSave, FilesLoaded )
%This code averages all branches in each stack, concatenates all stack and
%plot average activity in the tuft for each trial. 
%Useful to have an idea of dendritic activity and if dendrites respond to visual stimulation, like figure in roscoff conference poster done with population data

% ATTENTION: need to run this code on Df/f calculated after 15 september(code DeltaFoFPOIsDendrites5)!!
% because in older versions of that code, when a branch is missing the times are all set to zeros, and that
% messes up the timescale in this code. In the newer version of the
% DeltaFoFPOIsDendrites code, when a segment is missing the times are set
% to NaN

%% beginning stuff

if nargin < 3
    FilesLoaded = cell(nStacks,1);Data = cell(nStacks,1);
end

if nargin < 2
    FlagSave = true;
end

% initialise stuff
Time = cell(nStacks,1);
TimePoints = zeros(1,nStacks);

%% load data

for st =1 : nStacks
    
    % load data
    if nargin < 3
        [filename,pathname] = uigetfile('*.mat'); %the user needs to load a file that contains a matrix DeltaFoverF_Sm(cell,trial,time)
        FilesLoaded{st} = [pathname filename];
    end
    load(FilesLoaded{st},'DeltaFoverF_Sm','TimesSegment')
    
    % remove missing segments and segments full of NaNs
    for seg = 1 : size(DeltaFoverF_Sm,1)
       if sum(TimesSegment(seg,1,:)) == 0 || sum(isnan(reshape(DeltaFoverF_Sm(seg,:,:),1,[]))) > 0.75*length(reshape(DeltaFoverF_Sm(seg,:,:),1,[]))
           DeltaFoverF_Sm(seg,:,:) = NaN; 
           TimesSegment(seg,:,:) = NaN;
       end        
    end
    
    % average all segments
    Data{st} = squeeze(nanmean(DeltaFoverF_Sm,1));
    Time{st} = squeeze(nanmean(TimesSegment,1));

% look only at soma (segment 1)
%     Data{st} = squeeze(DeltaFoverF_Sm(1,:,:));
%     Time{st} = squeeze(TimesSegment(1,:,:));
    
    TimePoints(st) = size(DeltaFoverF_Sm,3);
    
end

%% interpolate data so all stacks have the same temporal scale

[NumberTimePoints , SmallerStack]= min(TimePoints);
NumberTrials = size(DeltaFoverF_Sm,2);
DataInt = zeros( nStacks, NumberTrials, NumberTimePoints);
AllStacksConcat = [];

for st = 1 : nStacks
    for tr = 1 : NumberTrials
        
        %interpolate
        DataInt(st, tr, 1:NumberTimePoints) = interp1( Time{st}(tr,:), Data{st}(tr,:), Time{SmallerStack}(tr,:));
        
        % look only at segment 1
        %DataInt(st, tr, 1:NumberTimePoints) = interp1( Time{st}(tr,:), Data{st}(tr,:), Time{SmallerStack}(tr,:));
    end
        
        %concatenate all the stacks
        AllStacksConcat = [ AllStacksConcat; squeeze(DataInt(st,:,:))];
end

TimeAllStacks = Time{SmallerStack}(1,:);
TimeRes = Time{SmallerStack}(1,end)/NumberTimePoints;

%% plot

% plot activity in all trials
figure; 
imagesc(AllStacksConcat); colorbar
title(['Time resolution is ' num2str(TimeRes) ' ms' ])
xlabel('Time, timepoints')
ylabel('Df/f')

% plot mean of actiivity across all trials
MeanAll = nanmean(AllStacksConcat,1); 

figure; 
plot(TimeAllStacks,MeanAll); 
title('Mean Activity across all trials')
xlabel('Time, seconds')
ylabel('Df/f')

%% save

if FlagSave == 1
    
    save([' TuftActivityAllStacks ' date '.mat'])
    saveas(gcf-1, 'TuftActivityAllStacks.fig' )
    saveas(gcf, 'TuftMeanActivityInTrial.fig' )
    
end


end

