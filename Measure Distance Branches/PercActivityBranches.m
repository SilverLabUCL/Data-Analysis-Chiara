
PercActivity = NaN(5,length(FilesLoaded));

for f = 1:length(FilesLoaded)
    
    load(FilesLoaded{f}, 'ResponsesBin', 'Segments')

    for s = 1:length(Segments)
        
       PercActivity(Segments(s),f) = nansum(ResponsesBin(Segments(s),:))/length(ResponsesBin(Segments(s),:));
        
        
    end
end

MeanAct = nanmean(PercActivity,2);

MeanActAll = [MeanActAll; MeanAct];