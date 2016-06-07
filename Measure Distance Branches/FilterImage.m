function [ ImageFilt ] = FilterImage(Image, Thr, FlagPlot)
% filter an image and apply a threshold to identify neurons

if nargin < 3
    FlagPlot = 1;
end

if nargin < 2
    Thr = 5;
end

% parameters
FilterSize = 5; % size of Gaussian filter, in microns
FrameSize = size(Image,1); % number of pixels
FOVSize = 220; % size of field of view, assume that images are square
FilterParam = round(FrameSize/FOVSize*FilterSize);

% normalize by average intensity level
I = Image/mean(Image(:));

% smoothing
Filter = fspecial('gaussian',[FilterParam FilterParam], 0.5);
I1 = imfilter(I, Filter);

if FlagPlot
    figure; imagesc(I1)
    title('Image Filtered and Normalized')
end

% apply threshold
I2 = I1 > Thr;

% remove small objects
ImageFilt = bwareaopen(I2, FilterParam);

if FlagPlot
    figure; imagesc(ImageFilt)
    title('Image Filtered')
end

end

