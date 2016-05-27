function [Speed] = ExtractEncoderData( Dir_Name )
%imports data of mouse speed from encoder
%Dir Name=directory where data is
%Speed{trial}(Time(ms), Speed (rpm)). Last cell contains the number of the
%trial (in order) where speed data has been saved successfully

addpath(genpath(Dir_Name));
ReadFiles=dir([Dir_Name '\Speed_Data']);

Speed=cell(1,length(ReadFiles)-1);

for file=3:length(ReadFiles)
    
    TZero=1;    
    %read trial number
    TrialN(file-2)=sscanf(ReadFiles(file,1).name,'%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%*c%f');
    
    %import data
    SpeedData=importdata(ReadFiles(file,1).name);
    times=SpeedData.data(:,1);
    
    %look for a moment when hard trigger zeroes time count.
    for t=1:(round(length(times)/2))
        if SpeedData.data(t+1,1) < SpeedData.data(t,1)
            TZero=t+1;
        end
    end
    
    %save data
    Speed{file-2}(:,1)=SpeedData.data(TZero:end,1)*1e-3; %time data in ms
    Speed{file-2}(:,2)=smooth(SpeedData.data(TZero:end,2),10); %speed data in rpm, smoothed
end

%save the number of the trials for which speed data has been imported, in the
%same order as in the Speed cell
Speed{length(ReadFiles)-1}=TrialN;

end

