%copy data of an experiment from this computer (computer that controls the microscope) to the folder Chiara in the server. 
%It copies only the "useful" files, specified in the variable: FilesToCopy

%Write as input the date (ExpDate) of the experiment. Note:it has to be written
%in the same way as the folder's name where the data are saved

%%% input: date of the experiment in the format: 'dd Month yyyy'

function CopyDataToServer2(ExpDate)

ExpMonth=sscanf(ExpDate,'%*c%*c%*c%s%c%s');
PathRead=['Y:\3D_RIG_2\Microscope data\' ExpMonth '\' ExpDate]; %where it reads the data
%PathRead=['E:\AOL_Rig2 Data\' ExpMonth '\' ExpDate]; %if the data is in the external storage hard disk
PathSave=['H:\Microscope data\' ExpDate];%where it copies the data
addpath(genpath(PathRead));
addpath('H:\Microscope data');

%name of the files/folders that it will copy
FilesToCopy{1}='Points_data'; %contains the data of the points
FilesToCopy{2}='Zstack Images'; %contains stack images
FilesToCopy{3}='norm_points.dat'; %contains normalized xyz coordinates of the points
FilesToCopy{4}='points.dat'; %contains xyz coordinates of the points
FilesToCopy{5}='Zplane_Pockels_Values.dat'; %contains z coordinates and pockel values of the planes in the stack
FilesToCopy{6}='Speed_Data';

mkdir(PathSave)
ReadFolders=dir(PathRead); %read all the folders (=stacks usually) to copy

for folder=1:length(ReadFolders) %for every folder, it copies the files specified in FilesToCopy and the tif files
    if length(ReadFolders(folder).name)>3
       PathSaveTime=[PathSave '\' ReadFolders(folder).name];
       mkdir(PathSaveTime)
       
       PathReadTime=[PathRead '\' ReadFolders(folder).name];
       
       for file=1:length(FilesToCopy) %looks for the files with names specified at the beginning in FilesToCopy
           ReadFile=[PathReadTime '\' FilesToCopy{file}];
           if exist(ReadFile,'dir') %if it is a directory, it creates a directory with the same name on the server and then copy the data in there
               PathSaveTimeFile=[PathSaveTime '\' FilesToCopy{file}];
               mkdir(PathSaveTimeFile)
               copyfile(ReadFile,PathSaveTimeFile)
           elseif exist(ReadFile,'file') %if it's a file it just copies the file
               copyfile(ReadFile,PathSaveTime)
           end
       end
       
       %looks for and copy all the tiff files, =images not included in a folder
       %called 'ZStack Images', useful for timelapse or snap images
       FindTiff=dir(PathReadTime);
       for t=1:length(FindTiff)
           if length(FindTiff(t).name)>3
       EndFileName=[FindTiff(t).name(end-2) FindTiff(t).name(end-1) FindTiff(t).name(end)];
       if strcmp(EndFileName,'tif') 
          TiffPath=[PathReadTime '\' FindTiff(t).name]; 
          copyfile(TiffPath,PathSaveTime) 
       end
           end
       end
    end
end

end