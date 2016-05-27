function [Speed] = ExtractEncoderData_Rig3( Dir_Name )
%imports data of mouse speed from encoder
%Dir Name=directory where data is
%Speed: first column: time in ms, second column: speed in rpm (1 rotation =
%50 cm)

addpath(genpath(Dir_Name));
ReadFiles=dir([Dir_Name '\Functional imaging TDMS data files\Speed_Data']);

% find speed file
for f = 1:length(ReadFiles)
    if strcmp(ReadFiles(f).name(1),'S') == 1
        SpeedFile = ReadFiles(f).name;
    end
end

% import speed data
SpeedData = importdata(SpeedFile);
Speed = SpeedData.data(:,1:2);

Speed(:,1) = Speed(:,1)*1e-3; % convert to ms
Speed(:,2) = smooth(Speed(:,2),10); % smooth data a bit

end

