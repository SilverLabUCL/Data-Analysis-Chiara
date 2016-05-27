function [ TimesCorrected, TimesSegment ] = CorrectTimeRig3( Times, PointsInSegments, POIsIn2Segm )
% corrects for a bug in code that import microscope data into matlab...
% bug was fixed on 26/4/2016, so data imported in matlab after then do not
% need this code.

% fill time for AODs in rig3 is 24.5 microseconds, and not 24. This causes
% an error in the timescale of the imaged points.


n_POIs = size( Times,2 );
n_cycles = size( Times,3 );

% correct time, add 0.5 microseconds for each imaged voxel
TimesCorrected = NaN(n_POIs,n_cycles);
DelayCycle = 0;
for c = 1:n_cycles % for each cycle (= timepoints)
    for p = 1:n_POIs % for each point
        
        DelayPOI = (p-1)*0.5*1e-3;
        TimesCorrected( p,c ) = Times(1,p,c) + DelayPOI + DelayCycle;
    end
    
    DelayCycle = DelayCycle + 0.5*1e-3*n_POIs;
end

% average times for POIs in different branches

n_segments = length(PointsInSegments);
TimesSegment = NaN(n_segments,n_cycles);

for Seg=1:n_segments
    if isempty(PointsInSegments{1,Seg})==0
        
        POIs=PointsInSegments{1,Seg};
        IndPOIs2Seg=find(ismember(POIs,POIsIn2Segm)); %check if any of the POIs are in 2 segments, and in that case discards them
        POIs(IndPOIs2Seg)=[];
        
        TimesSegment(Seg,:)=nanmean(TimesCorrected(POIs,:),1);
        
        clear POIs IndPOIs2Seg
    end
end
end

