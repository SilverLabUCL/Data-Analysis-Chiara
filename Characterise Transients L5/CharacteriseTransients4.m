function [ TransientsChar, ResponsesDistPerc, ResponsesDist, ResponsesBin ] = CharacteriseTransients4(SkipSegment, FlagPlot, FlagSave)
%characterize calcium transients in the data recorded in a AOD stack.

%Detect responses in all branches using algorithm published in Clements
% and Bekkers 1997 (Biophysical Journal, Vol73, July 1997, 220-229), and characterise transients.

% inputs:
% 1 - SkipSegments: segments that will not be analysed, default is empty (=
% no segments skipped)
% 2 - FlagSave: set to 1/true to save data and figures generated from this
% code
% 3 - FlagPlot: set to 1/true to plot extra figures (figures with responses
% detected by Clements and Bekkers alogirthm are plotted anyway)

%outputs: 
% 1 - TransientsChar: structure 1x NumberOfSegments, where each field
%contains a different characteristic of the detected calcium transient:
% - Amplitude
% - PosMax: when the responses occurred, take the position corresponding to
% the maximum peak in original data
%- PosMaxInDetec: maximum peak in data treated with Bekkers and Clements algorithm)
% - Onset time: first point 3 st dev above noise
% - Duration of event: from onset to end of event, measured as 3 st dev
% above noise
% - Rise time: 10-90% of the peak (first peak if multiple spikes in same event)
% - Decay time: from max to 37% of the peak, only for small events
% - Distribution: spatial distribution in dendritic tree: % of branches having same
% transient simultaneously

% 2 - ResponsesDist: contains list with only spatial distribution (% of
% branches coactive) of each transient in the dendritic tree

% this code calls the functions:
% - DiscardResponses
% - event_detection2
% - FindMaximumResponses
% - DetermineOnset
% - DetermineDuration
% - DetermineRiseTimeDecayTime
% - SpatialDistributionSpikes2

% compared to version 2: discards detected responses that have amplitudes
% lower than a hard threshold or 3 std dev of baseline

% compared to version 3: computes onset using crossing between 2 lines:
% line that goes from 10 to 20% of fluorescence rise and baseline just
% before response
% also added integral of response

%% parameters to set

% for Clements Bekkers algorithm
Thr = 2;
RiseTime = 1.2;%0.045; %rise time and decay times in seconds
DecayTime = 0.7;%0.142;

%baseline, where to calculate st dev of noise. 
Baseline =[101 110]; % start and end points, seconds

%Cut = 7532;

%% default inputs

if nargin<3
    FlagPlot = true; % if true, plot a figure for (almost) each step in the code. If false, plots only figures with responses detected for each segment
end

if nargin <2
    FlagSave = false; % if true, saves the data and the figures
end

if nargin <1
    SkipSegment = []; % default: it doesn't skip any segment, set it to skip a segment if there are too many NaNs in the recording of that segment
end

%% load file

[filename,pathname] = uigetfile('*.mat'); %the user needs to load a file that contains a matrix DeltaFoverF_Sm(cell,trial,time)
FileLoaded=[pathname filename];
load(FileLoaded,'DeltaFoverF_Sm_Lin','Times', 'Times_Lin','n_segments')

% % downsample for big data with high temporal resolution
% for seg = 1:n_segments
% DeltaFoverF_Sm_LinD(seg,:) = downsample(DeltaFoverF_Sm_Lin(seg,1:Cut),1);
% Times_LinD(seg,:) = downsample(Times_Lin(seg,1:Cut),1);
% end
% 
% DeltaFoverF_Sm_Lin = DeltaFoverF_Sm_LinD;
% Times_Lin = Times_LinD;


%% find segments with data

%find segments with data
SumDeltaF = nansum(DeltaFoverF_Sm_Lin,2) ;
Segments = find(SumDeltaF ~= 0);

% remove segments with no data
RemoveSegments = [ SkipSegment ];
for s = 1:length(RemoveSegments)
    Segments(Segments == RemoveSegments(s)) = [];
end

%% initialise variables

ResponsesBin = zeros(n_segments, size(DeltaFoverF_Sm_Lin,2)); %contains binary vector with ones where there is a response
DetectionCriterion = zeros(n_segments, size(DeltaFoverF_Sm_Lin,2)); % detection criterion from Clements and Bekkers algorithm

durationRec = Times(1,1,end) * size(Times,1) * 1e-3;  %duration of recording, in seconds

TransientsChar = struct; %structure with final outputs
TimeRes = mean(diff(Times(1,1,:))); % time resolution, in milliseconds
%% detect and characterize responses

for s = 1:length(Segments)
    
    data = DeltaFoverF_Sm_Lin(Segments(s),:);
    
    % convert baseline times from seconds to vector indexes
    [ ~, BaselineTimePoints(1) ] = min( abs(Times_Lin(Segments(s),:) - Baseline(1)*1e3 ));
    [ ~, BaselineTimePoints(2) ] = min( abs(Times_Lin(Segments(s),:) - Baseline(2)*1e3 ));
    
    % run Clements and Bekkers algorithm to find responses
    [DetectionCriterion(Segments(s),:)] = event_detection2(data , durationRec, RiseTime, DecayTime,  Thr, false );
    
    % find amplitude and maximum of responses
    [ TransientsChar(1,Segments(s)).Amplitude, TransientsChar(1,Segments(s)).PosMax, ~, TransientsChar(1,Segments(s)).PosMaxInDetec, ResponsesBin(Segments(s),:) ] = FindMaximumResponses( DetectionCriterion(Segments(s),:), Thr, data, round(RiseTime*1e3/TimeRes) , false);
    
    % discard responses with amplitude lower than 1, or give
    % BaselineTimePoints if want to use 3 std dev of noise
    [TransientsChar(1,Segments(s)), ~, ResponsesBin(Segments(s),:)] = DiscardResponses( TransientsChar(1,Segments(s)), BaselineTimePoints, data, ResponsesBin(Segments(s),:));

    % plot detected responses
    figure;
    plot(data)
    hold on; plot(TransientsChar(1,Segments(s)).PosMax,TransientsChar(1,Segments(s)).Amplitude,'ro')
    title(['Responses detected in segment ' num2str(Segments(s))])
    
    % determine onset of responses as first point 3 std dev above noise
    [ TransientsChar(1,Segments(s)).OnsetApprox ] = DetermineOnset( data, TransientsChar(1,Segments(s)).PosMax, BaselineTimePoints, false );
    
    % determine onset of responses as crossing between baseline and rise of
    % response
    %[ TransientsChar(1,Segments(s)).Onset ] = DetermineOnsetBetter( data, Times_Lin(Segments(s),:), TransientsChar(1,Segments(s)).PosMax, TransientsChar(1,Segments(s)).Amplitude, TransientsChar(1,Segments(s)).OnsetApprox, FlagPlot );
    TransientsChar(1,Segments(s)).Onset = [];
    % determine duration of responses
    [ TransientsChar(1,Segments(s)).Duration, TransientsChar(1,Segments(s)).Integral] = DetermineDurationAndIntegral( data, TransientsChar(1,Segments(s)).PosMax, BaselineTimePoints, TransientsChar(1,Segments(s)).OnsetApprox, FlagPlot);
    
    % determine rise time and decay time
    [ TransientsChar(1,Segments(s)).RiseTime, TransientsChar(1,Segments(s)).DecayTime ] = DetermineRiseTimeDecayTime( data, TransientsChar(1,Segments(s)).PosMax, TransientsChar(1,Segments(s)).Amplitude, TransientsChar(1,Segments(s)).OnsetApprox, TransientsChar(1,Segments(s)).Duration, FlagPlot );
    
    % convert times from array indexes into seconds
    for e = 1 : length( TransientsChar(1,Segments(s)).Onset )
        if isnan( TransientsChar(1,Segments(s)).Onset(e) ) == 0
            TransientsChar(1,Segments(s)).OnsetApprox(e) =  Times_Lin( Segments(s) , TransientsChar(1, Segments(s) ).OnsetApprox(e)) * 1e-3 ;
            TransientsChar(1,Segments(s)).Duration(e) = TransientsChar(1,Segments(s)).Duration(e).* TimeRes * 1e-3;
            TransientsChar(1,Segments(s)).RiseTime(e) = TransientsChar(1,Segments(s)).RiseTime(e).* TimeRes * 1e-3;
            TransientsChar(1,Segments(s)).DecayTime(e) = TransientsChar(1,Segments(s)).DecayTime(e).* TimeRes * 1e-3;
        end
    end
end

%% measure spatial distribution for each response

[TransientsChar, ResponsesDistPerc, ResponsesDist] = SpatialDistributionSpikes3( ResponsesBin(1:end,:), Segments(1:end), TransientsChar, true );

%% save data and figures

if FlagSave
    
    %generate folder that contains data from this code
    DirName = ['CharacteriseTransients' date];
    mkdir(DirName)
    
    % save data
    save([DirName '\CharacteriseTransients.mat'])
    
    % save images
    ImageHandle = gcf;
    
    if FlagPlot == 0
        
        for ImageHandle = 1: length(Segments)
            saveas(ImageHandle,[DirName '\ResponsesSegment ' num2str(Segments(ImageHandle)) '.fig'])
        end
        
    else
        
        saveas(ImageHandle,[DirName '\SpatialDistributionEvents.fig'])
        saveas(ImageHandle-1,[DirName '\SpatialDistributionEventsPercentage.fig'])
        saveas(ImageHandle-2,[DirName '\SumResponses.fig'])
        
        ImageHandle = ImageHandle -3 - length(Segments)*3 +1;
        
        for s = 1:length(Segments)
            
            saveas(ImageHandle, [DirName '\Responses Segment ' num2str(Segments(s)) '.fig'])
            %saveas(ImageHandle + 1, [DirName '\Onsets Segment ' num2str(Segments(s)) '.fig'])
            saveas(ImageHandle + 1, [DirName '\Duration Segment ' num2str(Segments(s)) '.fig'])
            saveas(ImageHandle + 2, [DirName '\RiseDecayTimes Segment ' num2str(Segments(s)) '.fig'])
            
            ImageHandle = ImageHandle + 3;
        end
        
    end
    
    
end

end

