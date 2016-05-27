function [DfoFDSpikes, DfoFBAPS, DfoFAll] = DfoFSeparateSpikes


load('IsolateDendSpike.mat', 'bAPsFinal')
load('IsolateDendSpike.mat', 'DendriticSpikesFinal')
load('IsolateDendSpike.mat', 'ResponsesBin')
load('CharacteriseTransients.mat', 'DeltaFoverF_Sm_Lin')
load('CharacteriseTransients.mat', 'Times')
load('CharacteriseTransients.mat', 'FileLoaded')
load(FileLoaded, 'TimesSegment','PointsInSegments','MeanSegment','NodesInfo','SortedTree')

n_trials = size(Times,1);
n_timepoints = size(Times,3);
n_segments = size(DeltaFoverF_Sm_Lin,1);

DfoFDSpikes_Lin = NaN(n_segments, n_trials*n_timepoints);
DfoFBAPS_Lin = NaN(n_segments, n_trials*n_timepoints);
DfoFAll_Lin = NaN(n_segments, n_trials*n_timepoints);

for seg = 1:n_segments
    DfoFDSpikes_Lin(seg,:) = DendriticSpikesFinal(seg,:).*DeltaFoverF_Sm_Lin(seg,:);
    DfoFBAPS_Lin(seg,:) = bAPsFinal(seg,:).*DeltaFoverF_Sm_Lin(seg,:);
    DfoFAll_Lin(seg,:) = ResponsesBin(seg,:).*DeltaFoverF_Sm_Lin(seg,:);
end

DfoFDSpikes = DivideConcatenatedTrials(n_trials, n_timepoints, DfoFDSpikes_Lin);
DfoFBAPS = DivideConcatenatedTrials(n_trials, n_timepoints, DfoFBAPS_Lin);
DfoFAll = DivideConcatenatedTrials(n_trials, n_timepoints, DfoFAll_Lin);
save('DfoFSeparateSpikes.mat')

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