% grating presentation
folders{1} = '\\192.168.15.61\data\3D_RIG_2\Camera data\09 February 2016 Karina'; 
folders{2} = '\\192.168.15.61\data\3D_RIG_2\Camera data\09 February 2016 Bonnie'; 
folders{3} = '\\192.168.15.61\data\3D_RIG_2\Camera data\17 June 2015 robinson';
folders{4} = '\\192.168.15.61\data\3D_RIG_2\Camera data\18 June 2015 robinson';
folders{5} = '\\192.168.15.61\data\3D_RIG_2\Camera data\03 February 2015 experiment Tina';
folders{6} = '\\192.168.15.61\data\3D_RIG_2\Camera data\07 August 2015 Tita';
folders{7} = '\\192.168.15.61\data\3D_RIG_2\Camera data\12 August 2015 tito';
folders{8} = '\\192.168.15.61\data\3D_RIG_2\Camera data\03 June 2015 theodora';
folders{9} = '\\192.168.15.61\data\3D_RIG_2\Camera data\27 January 2015 experiment tina';
%folders{10} = '\\192.168.15.61\data\3D_RIG_2\Camera data\01 June 2015 Theodora';


EyeMovAll = [];
EyeMovTemp = [];
EyeMovDayExp = NaN(length(folders),1);
OriginalFolder = pwd;

for f = 1:length(folders) % for each day of experiment
    cd(folders{f})
    subfolders = dir(folders{f});
    
    for ff = 3:length(subfolders) % for each stack
        if subfolders(ff,1).isdir == 1
            cd(subfolders(ff,1).name)
            files = dir('*.mat'); % take only mat file
            
            for fff = 1:length(files) % for all mat files
                if strcmp(files(fff,1).name(1:4), 'EyeT') == 1 % take file with eye tracking data
                    % load eye tracking data
                    load(files(fff,1).name,'PupilCentroid','TimeStamps')
                    [EyeMov] = AnalyseEyeMov(PupilCentroid, TimeStamps);
                    EyeMovAll = [EyeMovAll EyeMov];
                    EyeMovTemp = [EyeMovTemp EyeMov];
                    close all;
                end
            end
            cd .. % move back to folder of day of experiment
        end  
    end
    
    % save data for one day of experiment
    EyeMovDayExp(f) = sum(EyeMovTemp) / length(EyeMovTemp) ;
    EyeMovTemp = [];
end

cd(OriginalFolder)