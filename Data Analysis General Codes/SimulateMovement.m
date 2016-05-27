function [M, MFRAMMOVIES] = SimulateMovement(PathZStack, FrameNumber)

% code from Vicki, original name: sub_pixel_shifted_chiara, 21/05/2016

% load data
dirOutputR = dir(fullfile(PathZStack, 'RedChannel*.tif'));
fileNamesR = {dirOutputR.name}';

cd(PathZStack)
for i = 1:length(fileNamesR)
    my_videoR(:,:,i) = imadjust(imread(fileNamesR{i}));
end

implay (my_videoR, 2)
pause
%%%%%choose one frame and find maxpixel for that frame - used to derive
%%%%%threshold

if nargin < 2
    FrameNumber = inputdlg('Which frame should I use?');
    FrameNumber = str2num(cell2mat(FrameNumber));
end

IOR = imread(fileNamesR{FrameNumber});
maxpixel = max(max(IOR));
figure, imshow(IOR, [0 maxpixel]);
title('Frame chosen')

%find size of frame
IORSize = size(IOR);
ymax = IORSize(1);   %rows
xmax = IORSize(2);   %column

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set Fx at 0 and step through Fy frequencies at fixed Ay = 7 = 5.2um 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fxmov = 5;  % was 5Hz movement = 4um/ms**
Ax = 10;    % was 15 maximum displacement in x (columns)<->
Ay = 10;    % was 7 maximum displacement in y (rows)^**
Fymov = 10 % was 17


scan_time = 0;
%scan_interlude_time = 2e-3;   %default was every 2e-3
dwell_time = 1e-6;
aol_fill_time = 24e-6;
%num_ref_points = 40; % was 200 
x_offset = 0;
y_offset = 0;
x_offset_new = 0;
y_offset_new = 0;


%nb x is colums so I(y,x)
sum_xs = 0;
sum_ys = 0;
sumall = 0;
scan_time = 0;


MFRAMEMOVING = zeros(ymax, xmax);
MFRAMEFIXED = zeros(ymax, xmax);


time_to_scan_line = aol_fill_time + (xmax * dwell_time);
time_to_scan_frame = time_to_scan_line * ymax;
num_ref_points  = ceil(time_to_scan_frame/time_to_scan_line); % this shows a frame frame shifting the image every line
%num_ref_points effectively gives the number of snapshots captured while
%building a single frame
scan_int = time_to_scan_line;  % time between snapshots 
number_of_frames = 2;

% 
% 
% lines_between_ref = floor(scan_interlude_time/time_to_scan_line);  % was floor
% scan_int = lines_between_ref * time_to_scan_line;
% num_ref_points = ceil((time_to_scan_line * ymax)/scan_int);
% % total_frame_time = time_to_scan_line * ymax
% calc_scan_time = num_ref_points * scan_int

%show frame unmoved
figure, imshow(IOR, [0 maxpixel]);
hold on
title(['Unmoved frame']);
hold off

MOVEDFRAME = zeros(ymax, xmax);


for j= 1:ymax
  for i = 1:xmax
    scan_time = (j*time_to_scan_line)+ (i*dwell_time);
    y_pix_disp = round(Ay * sin(2*pi*Fymov*scan_time)); 
    x_pix_disp =  round(Ax * sin(2*pi*Fxmov*scan_time));
    if ((j + y_pix_disp < 1) | (j + y_pix_disp > ymax))
        MOVEDFRAME(j,i) = 0;
    elseif ((i + x_pix_disp < 1) | (i + x_pix_disp > xmax))
         MOVEDFRAME(j,i) = 0;
    else
       MOVEDFRAME(j,i) = IOR(j + y_pix_disp, i + x_pix_disp);
    end
  end
end

%work out the 2D correlation with unmoved frame
IORINT = int16(IOR);
MOVEDFRAMEINT = int16(MOVEDFRAME);
clear MFRAMMOVIES,
imcorrel_uncorrected = (round(corr2(IORINT,MOVEDFRAMEINT)* 100))/100

MFRAMEMOVING = zeros(ymax, xmax);


%show distorted frame with correlation coeeficient
figure, imshow(MOVEDFRAME, [0 maxpixel]);
hold on
title(['Moved frame , 2D Correlation =',num2str(imcorrel_uncorrected) ]);
hold off



%build and show movie of the movement during plane acquistion with sub
%pixel shifts
MFRAMEMOVING = zeros(ymax, xmax);

for f=1:num_ref_points * number_of_frames
    time= scan_int * f ;
    ydisp = Ay * sin(2*pi*Fymov*time);
    %ydispr = round(ydisp);
    xdisp = Ax * sin(2*pi*Fxmov*time);
    %xdispr = round(xdisp);
    
    
        xform = [ 1  0  0
          0  1  0
          xdisp  ydisp 1 ];
         tform_translate = maketform('affine',xform);
        IORshift = imtransform(IOR, tform_translate, 'XData',[1 size(IOR,2)],'YData',[1 size(IOR,1)] );
    
      MFRAMMOVIES(:,:, f) = IORshift;

end

% adjust contrast and play movie
figure,
for f=1:num_ref_points*number_of_frames
   imshow(MFRAMMOVIES(:,:, f), [0 maxpixel]);
  M(f) = getframe;
end

implay(M, 100);

end
