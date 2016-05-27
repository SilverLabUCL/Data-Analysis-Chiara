VisualStim = 'Small Gratings';
Mouse = 'Mary';
DayExper = '14/04/2015';

counter = 0;
for i = 1:length(DF)
    if strcmp(DF(1,i).VisStim,VisualStim) == 1 && strcmp(DF(1,i).MouseID,Mouse) == 1 && strcmp(DF(1,i).DayExp,DayExper)
        counter = counter + 1;
        Indexes(counter) = i;
    end
end

EyeData = NaN(length(Indexes), size(DF(1,Indexes(i)).Eyetrack.PupilArea) + 50);
SpeedData = NaN(length(Indexes), size(DF(1,Indexes(i)).Eyetrack.PupilArea) + 50);
SpeedTime = NaN(length(Indexes), size(DF(1,Indexes(i)).Eyetrack.PupilArea) + 50);

for i = 1:length(Indexes)
    temp = length(DF(1,Indexes(i)).Eyetrack.PupilArea);
    EyeData(i,1:temp) = DF(1,Indexes(i)).Eyetrack.PupilArea;
    temp = length(DF(1,Indexes(i)).MouseSpeed);
    SpeedData(i,1:temp) = DF(1,Indexes(i)).MouseSpeed;
    temp = length(DF(1,Indexes(i)).SpeedTime);
    SpeedTime(i,1:temp) = DF(1,Indexes(i)).SpeedTime;
end