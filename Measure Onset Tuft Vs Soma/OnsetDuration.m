function [Onset, Duration] = OnsetDuration(dataOrig,cursor_info)


StartPoint = cursor_info(1,3).Position(1);
EndPoint = cursor_info(1,1).Position(1);
Baseline(2) = cursor_info(1,2).Position(1) - StartPoint;
Baseline(1) = 1;

data = dataOrig(StartPoint:EndPoint);
[~, PosMax] = max(data);

noise = nanstd(data(Baseline(1):Baseline(2)));
offset = nanmean(data(Baseline(1):Baseline(2)));
AboveNoise = find( data > (offset+noise*3) );
Onset = AboveNoise(1);
figure; plot(data); hold on; plot(Onset,data(Onset),'ro')

[ Duration, End ] = DetermineDuration( data, PosMax, Baseline, Onset);
if isnan(End) == 1
    End = length(data);
    Duration = End - Onset;
end

hold on; plot(End,data(End),'ro')

Onset = Onset + StartPoint;

end