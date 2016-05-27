%load images of Z stack in matrices, load coordinates of the points and if FlagPlot=1
%plot images and points on images 

function [GreenChStack, RedChStack, PointPlane, FlagPlot]=readImages3_rig3(DirName,FlagPlot)

addpath(genpath(DirName));

%check if images are in folder ZStack Images
if exist([DirName '/Zstack Images'],'dir') ~=0 
DirNameImages=[DirName '/Zstack Images'];
else
DirNameImages=DirName;
end


ReadFiles=dir(DirNameImages);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load stack into structures GreenChStack and RedChStack

NumberOfPlanes=round((length(ReadFiles)-3)/2); %roughly calculate the number of planes/images to preallocate the structures. It's the number of files -3 (two empty files,and the scan parameters file) and divided by 2 because there are two (red and green) channels
GreenChStack=cell(NumberOfPlanes,1);
RedChStack=cell(NumberOfPlanes,1);

for i=1:length(ReadFiles)
        if ReadFiles(i).bytes ~= 0 && strcmp(ReadFiles(i).name,'scan parameters.xml')==0 %skips empty files and scan parameters file
        
            if isempty(regexp(ReadFiles(i).name, 'ee', 'once'))==0 %the file is considered green channel if the name of the file contains "ee"
            %channel
            %it reads the number of the plane/image from the last digits in
            %the file name:
               IsANumber=ismember(ReadFiles(i).name(end-6), ['a':'z', 'A':'Z']); %this is zero if the image number is a 3-digit number (higher than 99). Attention: this code doesn't work if the image number is a 4-digit number (higher than 999) 
               if IsANumber==0
                   plane=str2num([ReadFiles(i).name(end-6) ReadFiles(i).name(end-5) ReadFiles(i).name(end-4)]); %plane has 3 digits here
               else
                   plane=str2num([ReadFiles(i).name(end-5) ReadFiles(i).name(end-4)]); %plane has 2 digits here
               end
               GreenChStack{plane}(:,:)=imread(ReadFiles(i).name); 
               
            elseif isempty(regexp(ReadFiles(i).name, 'Red', 'once'))==0 %it's considered red channel if the name of the file contains "red" 
               %it reads the number of the plane/image from the last digits in
               %the file name:
                IsANumber=ismember(ReadFiles(i).name(end-6), ['a':'z', 'A':'Z']);
               if IsANumber==0
                   plane=str2num([ReadFiles(i).name(end-6) ReadFiles(i).name(end-5) ReadFiles(i).name(end-4)]);
               else
                   plane=str2num([ReadFiles(i).name(end-5) ReadFiles(i).name(end-4)]);
               end
               RedChStack{plane}(:,:)=imread(ReadFiles(i).name); 
               
            else
                disp(['Warning: the file named ' ReadFiles(i).name ' cannot be attributed to red or green channel'])
            end
            
        end
end



if exist([DirName '\Functional_Data'],'dir') ~=0  %if points have been taken for this stack


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%import point data

PointsData=importdata([ DirName '\ROI.dat']);

PointsCoor = PointsData.data(:,5:7); % points x,y,z coordinates
PointsInd =  PointsData.data(:,1); % indexes of points

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% attributes points to planes

PlanesData=importdata([ DirName '\Zplane_Pockels_Values.dat']);

for plane=1:length(RedChStack)
    
    planeAOL = PlanesData.data(plane,1);
    pp = find(PointsCoor(:,3) == planeAOL); % find points in plane
    
    PointPlane{plane}(:,1)=PointsInd(pp,1);
    PointPlane{plane}(:,2:3)=PointsCoor(pp,1:2);
   
    clear pp
end


else %if points have NOT been taken for this stack

PointPlane=[];
FlagPlot=0;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot points on images

if FlagPlot ==1

for plane=1:length(RedChStack)
    
figure;
imagesc(GreenChStack{plane})
colormap(gray)
title(['Plane ' num2str(plane)])
if exist([DirName '/Functional_Data'],'dir') ~=0  %if points have been taken for this stack, it plots them on the images
hold on
plot(PointPlane{plane}(:,2),PointPlane{plane}(:,3),'r*','MarkerSize',3)
text(PointPlane{plane}(:,2),PointPlane{plane}(:,3), num2str(PointPlane{plane}(:,1)),'FontSize',9,'Color','red')
end


end

end



    


end
