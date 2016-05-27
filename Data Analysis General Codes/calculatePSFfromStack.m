function [ PSFZfromXProj, PSFZfromYProj, PSFXY ] = calculatePSFfromStack( FolderRead, zoom,ZStep )
%Plots PSF from a stack with beads, the user needs to select the roi with
%the bead, and the function calculates the PSF (in microns) as the width of the gaussian
%at half peak

%input: folder where the stack is

n_pixels1Image=200; %image is 200X200
MicronPerPixel=n_pixels1Image/181/zoom; %field of view 175 microns

%imports the stack with the beads
Files=dir(FolderRead);
for i=3:length(Files)-1
stack(i-2,:,:)=imread([FolderRead '\' Files(i,1).name]);
end
n_planes=size(stack,1)/2;
greenstack=stack(1:n_planes,:,:);

%calculates projections on x,y,x axis
GreenProjX=mean(greenstack,3);
GreenProjY=mean(greenstack,2);
GreenProjZ=mean(greenstack,1);

%plot projections, and user has to select a roi with a bead
figure;
imagesc(squeeze(GreenProjX))
title('X projection')
BWX=roipoly;

figure;
imagesc(squeeze(GreenProjY))
title('Y projection')
BWY=roipoly;

figure;
imagesc(squeeze(GreenProjZ))
title('Z projection')
BWZ=roipoly;

%calculate the PSF
roiX=squeeze(GreenProjX).*BWX;
roiY=squeeze(GreenProjY).*BWY;
roiZ=squeeze(GreenProjZ).*BWZ;

%PSF length in z, from X projection
[yCoor,xCoor]=find(roiX==max(max(roiX)));
HalfPeak=max(max(roiX))/2;
PSF=roiX(:,xCoor);
Diff=abs(PSF-HalfPeak);
[val1,index1]=min(Diff);
Diff2=Diff;
Diff2(index1-1:index1+1)=100;
[val2,index2]=min(Diff2);
PSFZfromXProj=abs(index1-index2)*ZStep;
clear HalfPeak PSF Diff yCoor xCoor Diff val1 index1 Diff2 val2 index2 

%PSF length in z, from Y projection
[yCoor,xCoor]=find(roiY==max(max(roiY)));
HalfPeak=max(max(roiY))/2;
PSF=roiY(:,xCoor);
Diff=abs(PSF-HalfPeak);
[val1,index1]=min(Diff);
Diff2=Diff;
Diff2(index1-1:index1+1)=100;
[val2,index2]=min(Diff2);
PSFZfromYProj=abs(index1-index2)*ZStep;
clear HalfPeak PSF Diff yCoor xCoor Diff val1 index1 Diff2 val2 index2 

%PSF length in xy, from Z projection
[yCoor,xCoor]=find(roiZ==max(max(roiZ)));
HalfPeak=max(max(roiZ))/2;
PSF=roiZ(:,xCoor);
Diff=abs(PSF-HalfPeak);
[val1,index1]=min(Diff);
Diff2=Diff;
Diff2(index1-1:index1+1)=100;
[val2,index2]=min(Diff2);
PSFXY=abs(index1-index2);
PSFXY=PSFXY*MicronPerPixel;
end

