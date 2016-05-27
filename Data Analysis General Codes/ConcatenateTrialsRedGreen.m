function [ Green, Red, TimeConcat ] = ConcatenateTrialsRedGreen( DataGreenCh,DataRedCh,Times, point, SmoothingFactor )
% plot red and green data and concatenate trials

if nargin < 5
    SmoothingFactor = 1;
end

% intialise stuff
n_trials = size(DataGreenCh,1);
n_timepoints = size(DataGreenCh,3);
Green = zeros(1,n_trials*n_timepoints);
Red = zeros(1,n_trials*n_timepoints);
TimeConcat = zeros(1,n_trials*n_timepoints);

% concatenate trials

for t = 1:n_trials
    
    Green( (t-1)*n_timepoints+1 : n_timepoints*t ) = DataGreenCh(t, point,:);
    Red( (t-1)*n_timepoints+1 : n_timepoints*t ) = DataRedCh(t, point,:);
    TimeConcat( (t-1)*n_timepoints+1 : n_timepoints*t ) = Times(t, point,:) + Times(1, point,end)*(t-1);

end

% smooth
Green = smooth(Green,SmoothingFactor);
Red = smooth(Red, SmoothingFactor);
TimeConcat = TimeConcat*1e-3; % convert to seconds

figure;
plot(TimeConcat, Green,'Color',[0.3 1 0.1])
hold on;
plot(TimeConcat,Red,'r')
xlabel('Time seconds')
ylabel('raw data')
axis tight

end

