function ConvertMatToTiff( PathName, FileName, FrameSize, FlagPlot )
% save images from mat files to tiff in the current folder

% default inputs
if nargin < 4
    FlagPlot = 0;
end

if nargin < 3
    FrameSize = 200;
end

% load data
load(PathName, FileName)
Stack = eval(FileName);
n_planes = size(Stack,1);

% save first plane
Image = uint16(reshape(Stack(1,:),FrameSize,FrameSize));
imwrite(mat2gray(Image),[FileName '.tif' ])

% add next planes to same tiff files
for pl = 2:n_planes
    
    Image = uint16(reshape(Stack(pl,:),FrameSize,FrameSize));
    imwrite(mat2gray(Image),[FileName '.tif' ], 'writemode', 'append')
    
    if FlagPlot
        figure; 
        imagesc(Image); 
        colormap(gray)
        axis off
    end
end

end

