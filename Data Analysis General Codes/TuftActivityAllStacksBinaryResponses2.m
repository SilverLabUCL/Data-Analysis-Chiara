function [ AllStacksConcat, TimeAllStacks ] = TuftActivityAllStacksBinaryResponses2( nStacks, FlagSave, FilesLoaded )
%This code binarizes responses of all branches in each stack, using the event detection algorithms in the CharacterizeTransients code, sums up activity across branches, concatenates all stacks and
%plots activity in the tuft for each trial.
%Useful to have an idea of dendritic activity and if dendrites respond to visual stimulation, like figure in roscoff conference poster done with population data

% from code as TuftActivityAllStacks, but here "binary" responses, so
% doesn't consider amplitudes of events but only if branches are on or off

%% beginning stuff

if nargin < 3
    FilesLoaded = cell(nStacks,1);
end

if nargin < 2
    FlagSave = true;
end

warning('off','MATLAB:colon:nonIntegerIndex')

% initialise stuff
Data = cell(nStacks,1);
Time = cell(nStacks,1);
TimePoints = zeros(1,nStacks);


%% load data

for st =1 : nStacks
    
    % load data
    if nargin < 3
        [filename,pathname] = uigetfile('*.mat'); %the user needs to load a file that contains a structure TransientChar with info about detected events
        FilesLoaded{st} = [pathname filename];
    end
    load(FilesLoaded{st},'TransientsChar','DeltaFoverF_Sm_Lin','Times_Lin','TimeRes','Times','FileLoaded','Segments')
    load(FileLoaded,'TimesSegment')
    
    n_trials = size(Times,1);
    n_timepoints = size(Times,3);
    
    % Create binarized responses using info of onset and duration of each
    % TransientsChar
    [ResponsesBin] = CreateBinarizedResponses( TransientsChar, Times_Lin, TimeRes, n_trials, n_timepoints, Segments);
    
    % ResponsesBin has all trials concatenated, divide trials again
    [ResponsesBinT] = DivideConcatenatedTrials(n_trials, n_timepoints, ResponsesBin);
    
    % remove segments full of NaNs
    for seg = 1 : length(Segments)
        if sum(isnan(DeltaFoverF_Sm_Lin(Segments(seg)))) > 0.75*length(DeltaFoverF_Sm_Lin(Segments(seg)))
            ResponsesBinT(Segments(seg),:,:) = NaN;
            TimesSegment(Segments(seg),:,:) = NaN;
        end
    end
    
    % sum all segments
    Data{st} = squeeze(nansum(ResponsesBinT,1));
    Time{st} = squeeze(nanmean(TimesSegment,1));
    
    TimePoints(st) = size(ResponsesBinT,3);
    
end

%% interpolate data so all stacks have the same temporal scale

[NumberTimePoints , SmallerStack]= min(TimePoints);
DataInt = zeros( nStacks, n_trials, NumberTimePoints);
AllStacksConcat = [];

for st = 1 : nStacks
    for tr = 1 : n_trials
        %interpolate
        DataInt(st, tr, 1:NumberTimePoints) = interp1( Time{st}(tr,:), Data{st}(tr,:), Time{SmallerStack}(tr,:));
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
ylabel('Trial Number')

% plot mean of actiivity across all trials
MeanAll = nanmean(AllStacksConcat,1);

figure;
plot(TimeAllStacks,MeanAll);
title('Mean Activity across all trials')
xlabel('Time, seconds')
ylabel('Mean Number of branches active')

%% save

if FlagSave == 1
    
    save(['TuftActivityAllStacks Binarized' date '.mat'])
    saveas(gcf-1, 'TuftActivityAllStacks Binarized.fig' )
    saveas(gcf, 'TuftMeanActivityInTrial Binarized.fig' )
    
end


end


function [ResponsesBin] = CreateBinarizedResponses( TransientsChar, Times_Lin, TimeRes, n_trials, n_timepoints, Segments)

ResponsesBin = NaN( length(Segments), n_trials*n_timepoints );

for seg = 1 : length(Segments)
    
    n_events = length(TransientsChar(1,Segments(seg)).PosMax);
    ResponsesBin(Segments(seg), :) = 0;
    
    for e = 1:n_events
        % if onset and duration are not NaN
        if isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 0 && isnan( TransientsChar(1,Segments(seg)).Duration(e) ) == 0
            Onset = find(Times_Lin(Segments(seg), :) == TransientsChar(1,Segments(seg)).OnsetApprox(e)*1e3);
            End = Onset + round(TransientsChar(1,Segments(seg)).Duration(e)*1e3/TimeRes);
            % if only duration is NaN, assume that duration was not found
            % because the event occurred at the end of the recording
        elseif isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 0 && isnan( TransientsChar(1,Segments(seg)).Duration(e) ) == 1
            Onset = find(Times_Lin(Segments(seg), :) == TransientsChar(1,Segments(seg)).OnsetApprox(e)*1e3);
            End = n_trials*n_timepoints;
            % if onset is NaN, take PosMax and a few elements before and after (not very precise...)
        elseif isnan( TransientsChar(1,Segments(seg)).OnsetApprox(e)) == 1
            Onset = TransientsChar(1,Segments(seg)).PosMax(e) ;
            End = TransientsChar(1,Segments(seg)).PosMax(e) ;
        end
        
        try
            ResponsesBin(Segments(seg), Onset : End ) = 1;
        catch
            disp(['ERROR Skipped Response ' num2str(e) ' of branch ' num2str(Segments(seg))])
        end
    end
end
end


function [DataInTrials] = DivideConcatenatedTrials(n_trials, n_timepoints, data)

n_segments = size(data,1);

DataReshaped = NaN(n_segments, n_timepoints, n_trials);
DataInTrials = NaN(n_segments, n_trials, n_timepoints);

for seg = 1 : n_segments
    DataReshaped(seg,:,:) = reshape( data(seg,:), n_timepoints, n_trials);
    DataInTrials (seg,:,:)= (squeeze(DataReshaped(seg,:,:)))';
end

end
