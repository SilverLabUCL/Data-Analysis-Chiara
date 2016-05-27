function RunAnalyzeData5(ExpDate,FlagServer)
%%% This function extracts the data from the output files of the AOL microscope, and it returns them in matlab matrices and basic figures. No real data processing here.

%%% UPDATES:
%%% same as RunAnalyzeData4, but this imports also speed data. Plus I removed all
%%% the code to plot points data.

%%% same as RunAnalyzeData3, but this works with the new labview indexing system
%%% where points and trials indexing start from 1 instead of 0

%%% same as RunAnalyzeData but this works for multiple stacks (or images in general) taken the same day

%%%INPUTS:
% 1 - 'ExpDate': Date if the experiment. It will then look for the data into the folder with the date name. This folder has to
% contain a folder 'Zstack Images' with the stack images,
% and a folder 'Points_data' with the recordings in the points, and
% a dat file 'points.dat' with the points coordinates.
% 2 - 'FlagServer' - set to 1 if data is in the server. If different to 1,
% the code looks for the data in the computer. Check the Path (Line 42, variable DirNameRead)....

%%% OUTPUTS saved automatically:
% 1 - GreenChStack{Plane} and RedChStack{Plane}: images of the stack, green and
%red channel
% 2 - DataGreenCh(Trial,Point,Timepoint) and
% DataRedCh(Trial,Point,Timepoint): traces of the points (POIs).
% 3 - PointPlane{plane}: the coordinates of the points (POIs) that are in each plane
% 4 - Times(Trial,Point,Timepoint): has the time values in milliseconds for
% the matrices DataGreenCh and DataRedCh
% 5 - Speed{trial}(Time(ms), Speed (rpm)). Last cell contains the number of the
%trial (in order) where speed data has been saved successfully
%Plus figures are saved in fig and tiff format with the image and the POIs

%%%NB CAREFUL!! this code closes all images already open in matlab.



%set paths and folder names
DirNameSave=['C:\Data Analysis\Bonnie\' ExpDate];

if FlagServer==1
    DirNameRead=['\\192.168.15.60\data\Chiara\' ExpDate]; %server Z
elseif FlagServer==2
    DirNameRead=['K:\Microscope data\' ExpDate]; %backup Hard drive
else
    DirNameRead=['C:\Data\Microscopy data\Veronica\' ExpDate]; %server Y downstairs
end

%addpath(genpath(DirNameRead))
ExpTime=dir(DirNameRead); %reads the folders= number of stacks


for jj=3:length(ExpTime)%1:length(ExpTime) %extracts the data for every stack
    
    if length(ExpTime(jj).name)>2 %remove "null files" that are erroneously found by matlab
        
        try
            
            disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    folder ' num2str(jj) ' out of ' num2str(length(ExpTime))])
            disp(['I am now reading the folder  ' ExpTime(jj).name])
            
            close all
            
            DirNameRead_Time=[DirNameRead '\' ExpTime(jj).name];
            DirNameSave_Time=[DirNameSave '\' ExpTime(jj).name];
            mkdir(DirNameSave_Time) %create directory with stack name
            
            
            if ExpTime(jj).isdir==0 %if the file isn't a folder, it copies and paste it in the saving folder
                copyfile(ExpTime(jj).name,DirNameSave_Time)
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Reads images from stacks, it plots them and saves the figures in the folder Zstack Images
            disp('I am now reading the images')
            
            [GreenChStack, RedChStack, PointPlane,~]=readImages4(DirNameRead_Time,1);
            
            disp('I am now saving the images')
            save([DirNameSave_Time '\images.mat'], 'GreenChStack', 'RedChStack', 'PointPlane');
            
            DirSavedImages=[DirNameSave_Time '\Zstack Images'];
            DirSavedImagesTif=[DirNameSave_Time '\Zstack Images\tif Format'];
            
            mkdir(DirSavedImages)
            mkdir(DirSavedImagesTif)
            for i=1:length(RedChStack)
                saveas(i,[DirSavedImages '\Plane ' num2str(i) ' Green channel'],'fig');
                saveas(i,[DirSavedImagesTif '\Plane ' num2str(i) ' Green channel'],'tif');
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Reads points traces
            if exist([DirNameRead_Time '\Points_data'],'dir') ~=0 %if points have been taken for this stack
                
                disp('I am now reading the points')
                
                [DataGreenCh,DataRedCh,Times]=extractdata3(DirNameRead_Time);
                
                %save the extracted data im matlab matrices and structures
                disp('I am now saving the data of the points into matlab matrices')
                save([DirNameSave_Time '\pointTraces.mat'], 'DataGreenCh', 'DataRedCh', 'Times');
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Reads speed data
            if exist([DirNameRead_Time '\Speed_Data'],'dir') ~=0 %if speed data has been saved for this stack
                
                disp('I am now extracting the speed data')
                
                [Speed]=ExtractEncoderData(DirNameRead_Time);
                
                %save the extracted data im matlab matrices and structures
                disp('I am now saving speed data into matlab matrices')
                save([DirNameSave_Time '\SpeedData.mat'], 'Speed');
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            clear GreenChStack RedChStack PointPlane DataGreenCh DataRedCh Times Speed %clear the data of one stack before starting to analyze another stack
            
        catch ME
            disp(['Error: could not extract the data for the folder/file  ' ExpTime(jj).name])
            ME %displays matlab error
        end
        
        
    end
    
    
end




end