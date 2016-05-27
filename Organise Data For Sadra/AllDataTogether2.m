function [ AllData ] = AllDataTogether2( FileMetaData, VisStimPath )
% put df/f data together from different experiments, different animals,
% different visual stimuli, etc

% compared to version 1, it adds raw green and red data for each segment

%%%%%%%% OUTPUT
% all data goes into the structure AllData, where each element is a trial,
% and it has the following fields:
% - MouseID: mouse name
% - RegionID
% - CellID
% - State: awake or anaesthetized
% - VisStim: type of visual stimuli: full-field gratings, small-field
%            gratings, natural images, grey screen or dark (no visual stimuli)
% - DayExp: day when the experiment was done.Useful only if need to go back to original
%           data.
% - Stack: name of stack where data is coming from. Useful only if need to go back to original
%          data.
% - Tree: dendritic tree reconstruction, saved in the format of the TREES
%         toolbox
% - NodesInfo: assigns branch ID to each node in the tree
% - Df: df/f data, for all branches in the tree. Smoothed over 100 ms to be
%       able to do movement correction with the red
% - DfSm: df/f data, smoothed over 100 ms and then over 10 time points.
% - Time: time data for Df/f data, in ms
% - Green: data in the green channel for all branches in the tree, no
%          smoothing
% - Red: data in the red channel for all branches in the tree, no smoothing
% - VisStimID: number of visual stimulus, i.e. number of orientation (full-field gratings),
%              position in the screen (small-field grating), or natural
%              image
% - TrialN: number of trial. Useful only if need to go back to original
%           data.
% - MouseSpeed: mouse speed in rotation per minute (rpm). 1 rotation = 50
%               cm, i.e. the circumference of the wheel is 50 cm.
% - SpeedTime: time data for mouse speed, in ms

% NEED TO ADD EYE TRACKING DATA


%%%%%%%% INPUT
% - FileMetaData: excel file that gives the following info for each stack:
% Mouse ID,	Region ID, Cell ID,	Animal State (Awake or anaesthetized), Day
% Experiment, Visual Stimulus (full gratings, natural images, etc), Stack
% Name, Main Path (where to find the folder of the stack)
% - VisStimPath: path where data for visual stimuli was saved: where
% matrices with info of which natural images was shown when.



if nargin < 2
    VisStimPath = 'H:\visual stim data';
end

if nargin < 1
    FileMetaData = 'C:\Users\Chiara\Desktop\DataDeepNeurons.xlsx' ;
end

% read excel file
[~, ~, MetaData] = xlsread( FileMetaData );

AllData = struct;
n_Stacks = length(MetaData);
counter = 0;

for s = 2 : n_Stacks %starts at 2 because first row contains headers
    
    if isstrprop(MetaData{s,7}(1), 'digit') == 0 % sometimes name of stack begins with ', remove it
        MetaData{s,7} = MetaData{s,7}(2:end-1);
    end
    
    disp([' Working on mouse ' MetaData{s,1} ' experiment ' MetaData{s,5} ' stack ' MetaData{s,7}])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load data from stack folder
    PathData = [ MetaData{s,8} '\' MetaData{s,7}];
    [ DfFile ] = FindDfData( PathData, MetaData(s,:) ); % find newest mat file with Df/f data
    
    load(DfFile, 'SortedTree','NodesInfo','DeltaFoverF','DeltaFoverF_Sm_Lin','DeltaFoverF_Sm','TimesSegment','DataGreenCh','DataRedCh','PointsInSegments','POIsIn2Segm')
    
    if exist( [ PathData '\SpeedData.mat'], 'file') == 2
        load([ PathData '\SpeedData.mat'],'Speed')
    else
        Speed = [];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % average green channel and red channel data over POIs in same branch
    [Green, Red] = AveragePOIs(DataGreenCh, DataRedCh, PointsInSegments, POIsIn2Segm);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % put to NaNs all non-imaged branches (and corresponding times?) in Df/f matrices,
    SumDeltaF = nansum(DeltaFoverF_Sm_Lin,2) ;
    MissingSegments = find(SumDeltaF == 0);
    
    for seg = 1:length(MissingSegments)
        DeltaFoverF( MissingSegments(seg),:,: ) = NaN;
        DeltaFoverF_Sm( MissingSegments(seg),:,: ) = NaN;
        TimesSegment( MissingSegments(seg),:,: ) = NaN;
        Green( MissingSegments(seg),:,: ) = NaN;
        Red( MissingSegments(seg),:,: ) = NaN;
    end
    
    n_trials = size(DeltaFoverF, 2);
    for trial = 1:n_trials
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % separate df/f data and times into trials
        counter = counter + 1;
        AllData(counter).Df = squeeze(DeltaFoverF(:, trial, :));
        AllData(counter).DfSm = squeeze(DeltaFoverF_Sm(:, trial, :));
        AllData(counter).Time = squeeze(TimesSegment(:, trial, :));
        AllData(counter).Green = squeeze(Green(:, trial, :));
        AllData(counter).Red = squeeze(Red(:, trial, :));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % assign vis stim for each trial
        AllData(counter).VisStimID = AssignVisStimID(trial, MetaData(s,:), VisStimPath);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % assign speed data to trials
        if isempty(Speed) == 0 && ismember(trial, Speed{end})
            TrialIndex =  find(Speed{end} == trial);
            AllData(counter).MouseSpeed = Speed{TrialIndex}(:,2);
            AllData(counter).SpeedTime = Speed{TrialIndex}(:,1);
        else
            AllData(counter).MouseSpeed = NaN;
            AllData(counter).SpeedTime = NaN;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save metadata
        AllData(counter).MouseID = MetaData{s,1};
        AllData(counter).RegionID = MetaData{s,2};
        AllData(counter).CellID = MetaData{s,3};
        AllData(counter).State = MetaData{s,4};
        AllData(counter).VisStim = MetaData{s,6};
        AllData(counter).DayExp = MetaData{s,5};
        AllData(counter).Stack = MetaData{s,7};
        AllData(counter).TrialN = trial;
        AllData(counter).Tree = SortedTree;
        AllData(counter).NodesInfo = NodesInfo;
        
    end
    
end


end

function [ DfFile ] = FindDfData( PathData, MetaData)
% find newest mat file with Df/f data

% looks for files with Df/f info
[ NDFoF, FilesList ] = LookForFile(PathData);

% if it can't find any df/f file, looks into subfolder called "Cell .."
if isempty(NDFoF) == 1
    PathData =  [ PathData '\Cell ' num2str(MetaData{3})];
    [ NDFoF, FilesList ] = LookForFile(PathData);
end

if length(NDFoF) == 1
    DfFile = [ PathData '\' FilesList(NDFoF).name];
elseif isempty(NDFoF) == 1
    disp('ERROR!! No file with Df/f data found')
elseif length(NDFoF) > 1 % if multiple mat files with DF/F data are found, take the newest
    
    Dates = zeros( 1, length(NDFoF));
    for j = 1 : length(NDFoF)
        Dates(j) = FilesList(NDFoF(j)).datenum;
    end
    
    [~, new] = max(Dates); % find the "bigger" date
    
    DfFile = [ PathData '\' FilesList(NDFoF(new)).name];
    
end
end

function [ NDFoF, FilesList ] = LookForFile(Path)
% looks for all mat files that start with DFoF

if exist(Path, 'dir') == 7 % if path exists
    
    FilesList = dir(Path);
    NDFoF = [];
    counter = 0;
    
    for i = 1:length(FilesList)
        if length(FilesList(i).name) > 8 && strcmp(FilesList(i).name(1:4),'DFoF') == 1 && strcmp(FilesList(i).name(end-3:end),'.mat') == 1
            counter = counter + 1;
            NDFoF(counter) = i;
        end
    end
    
else
    NDFoF = [];
end

end

function  [Green, Red] = AveragePOIs(DataGreenCh, DataRedCh, PointsInSegments, POIsIn2Segm)
% average POIs in branch for data in the green and in the red channel
% separately
n_segments =  size(PointsInSegments,2);
n_trials = size(DataGreenCh, 1);
n_timepoints = size(DataGreenCh, 3);
Green = NaN(n_segments, n_trials, n_timepoints);
Red = NaN(n_segments, n_trials, n_timepoints);

for Seg = 1:n_segments
    if isempty(PointsInSegments{1,Seg})==0
        
        POIs=PointsInSegments{1,Seg};
        IndPOIs2Seg=find(ismember(POIs,POIsIn2Segm)); %check if any of the POIs are in 2 segments, and in that case discards them
        POIs(IndPOIs2Seg)=[];
        
        for trial=1:n_trials
            Green(Seg,trial,:)=nanmean(DataGreenCh(trial,POIs,:),2); % green channel
            Red(Seg,trial,:)=nanmean(DataRedCh(trial,POIs,:),2); % red channel
        end
        clear POIs IndPOIs2Seg
    end
end

end

function VisStimID = AssignVisStimID(trial, MetaData, VisStimPath)

if strcmp(MetaData{6},'Full Gratings') == 1
    
    VisStimID = mod( trial, 8 );
    if mod( trial, 8 ) == 0
        VisStimID = 8;
    end
    
elseif strcmp(MetaData{6},'Small Gratings') == 1
    
    VisStimID = mod( trial, 12 );
    if mod( trial, 12 ) == 0
        VisStimID = 12;
    end
    
elseif strcmp(MetaData{6},'Natural Images') == 1
    
    % find folder where info on visual stimuli is saved
    FolderVisStim = [VisStimPath '\20' MetaData{1,7}(1:2) '_'  MetaData{1,7}(3:4) '_'  MetaData{1,7}(5:6)];
    Files =  dir(FolderVisStim);
    % convert dates and times into numbers
    FilesDatenum = zeros(1,length(Files));
    for f = 3:length(Files)
        FilesDatenum(f) = datenum(Files(f).name, 'yyyy_mm_dd_HH_MM_SS');
    end
    TimeStack = datenum(MetaData{1,7},'yymmdd_HH_MM_SS');
    % find and load info on visual stimuli
    [~, Ind] = min( abs(TimeStack - FilesDatenum) ); % find folder closer in time to when stack was taken
    FileVisStim = Files(Ind).name;
    if exist([FolderVisStim '\' FileVisStim '\image_sequence.mat'],'file') == 2
        load([FolderVisStim '\' FileVisStim '\image_sequence.mat'])
        VisStimID = frame_order(trial,:);
    else
        VisStimID = NaN; % if order of images presented was not saved
    end
    
elseif strcmp(MetaData{6},'Dark') == 1
    VisStimID = NaN;
elseif strcmp(MetaData{6},'Grey Screen') == 1
    VisStimID = NaN;
else
    disp(['WARNING!!! Could not identify visual stimuli type for day of experiment ' MetaData{5} ' stack ' MetaData{7} ])
end


end
