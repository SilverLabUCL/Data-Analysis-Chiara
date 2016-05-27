% Extract data from .dat files in Points_data folder, and put data in 2
% matrixes NumberOfTrials x PointNumber x Time

function [DataGreenCh,DataRedCh,Times]=extractdata3(DirName)

addpath(genpath(DirName));
ReadFiles=dir([DirName '\Points_data']);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%open .dat files and saves the data in the variable 'data', plus for every
%file it registers in the matrix 'DataDescriptor' the point #, trial # and channel type 

%for each file: first element=# of point, second element: 65=redchannel 66=greenchannel, third element=# of trial
DataDescriptor=zeros(3,length(ReadFiles)); 

n_files=0; %counter of files with data

for i=1:length(ReadFiles)
        
        temp=sscanf(ReadFiles(i,1).name,'%*c%*c%*c%*c%*u%*c%*c%*c%*c%*c%*c%u%*c%*c%*c%c%*c%u'); %test if it's a file with the data (i.e. it has a correct name)
        
        if length(temp)==2 %if there is only one trial, temp doesn't contain the trial #, so I add it manually
          temp=[temp(1) temp(2) 1]  ;
        end
        
        if isempty(temp)==0
            n_files=1+n_files;
            DataDescriptor(:,n_files)=temp; %save point #, channel type and trial # for file i
            fid=fopen(ReadFiles(i,1).name,'r');
            data(:,n_files)=fscanf(fid,'%f'); %save data of file i
            fclose('all');
        end

end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%put the data saved in two matrixes number of trials x number of points x
%time, for red channel 'DataRedCh' and for green channel 'DataGreenCh'
n_points=max(DataDescriptor(1,:));
n_trials=max(DataDescriptor(3,:));
n_timepoints=size(data,1);

DataRedCh=zeros(n_trials,n_points,n_timepoints);
DataGreenCh=zeros(n_trials,n_points,n_timepoints);
dataRed=zeros(n_trials,n_points); %stores indexes 
dataGreen=zeros(n_trials,n_points);

for t=1:n_trials
    
    dataRed(t,:)=find(DataDescriptor(2,:)==65 & DataDescriptor(3,:)==t);
    dataGreen(t,:)=find(DataDescriptor(2,:)==66 & DataDescriptor(3,:)==t);
    
    for p=1:n_points
        pointRed= DataDescriptor(1,dataRed(t,:))==p;
        pointGreen= DataDescriptor(1,dataGreen(t,:))==p;
        
        DataRedCh(t,p,:)=data(:,dataRed(t,pointRed));
        DataGreenCh(t,p,:)=data(:,dataGreen(t,pointGreen));
    end
    
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create matrix Times (milliseconds) with right times corresponding to datapoints. At each trial, first
%acquisition of point 1 = time zero.

%if I want to zero time only at the beginning of first trial and then keep counting instead of zeroing time at every
%trial:
%TimeBetweenTrials=; %milliseconds 
%LengthOneTrial=; %milliseconds

Times=zeros(n_trials,n_points,n_timepoints);
CycleNumber=0:n_timepoints-1; % 1 cycle=scan all the points once
ScanTime=0.028; %time to move from one point to the next point, milliseconds
TrialStart=0;

for t=1:n_trials

    for p=1:n_points
        
        TZero=(p)*ScanTime + TrialStart; 
        Times(t,p,:)=(n_points*ScanTime)*CycleNumber+TZero;
        
    end
    
    %TrialStart=TrialStart + TimeBetweenTrials*LengthOneTrial; %if I want to zero time only at the beginning of first trial, and not to zero time at every
%trial:
    
end




%end