function [SegmentsNoResponses] = FindNoResponses( DeltaFoverF_Sm_Lin, Times_Lin, Segments, RiseTime, DecayTime, TimeRes, Baseline)
% look for segments with no responses 
% look for at least n points in the recording above 4 standard deviations
% of the noise
% n is determined by the expected rise time and decay time of response

n_segments = length(Segments);
TimeResponse = (RiseTime*1e3 + DecayTime*1e3)/TimeRes ; 

counter=1;
SegmentsNoResponses=[];

for s = 1:n_segments
   
    [ ~, BaselineTimePoints(1) ] = min( abs(Times_Lin(Segments(s),:) - Baseline(1)*1e3 ));
    [ ~, BaselineTimePoints(2) ] = min( abs(Times_Lin(Segments(s),:) - Baseline(2)*1e3 ));
    
    Thr = 4*nanstd( DeltaFoverF_Sm_Lin(Segments(s), BaselineTimePoints(1):BaselineTimePoints(2)) ) + nanmean( DeltaFoverF_Sm_Lin( Segments(s),BaselineTimePoints(1):BaselineTimePoints(2)) );
    
    PointsAboveThr = sum( DeltaFoverF_Sm_Lin(Segments(s),:) > Thr ); % number of points aboe threshold Thr
    
    if PointsAboveThr < TimeResponse
        SegmentsNoResponses(counter) = Segments(s);
        counter = counter +1;
    end
    
end

end

