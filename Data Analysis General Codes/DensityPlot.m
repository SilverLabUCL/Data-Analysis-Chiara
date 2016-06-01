function [ M, MLog2 ] = DensityPlot( x, y, n_bins, ylim )
% calculate density plot from a scatter plot x,y
% bins in 3d and plots in logarithmic scale

% ylim: if you want to set yaxis to a different scale, you can specify
% maximum value on y axis

% for graph on amplitude of events vs spatial spread, I used 20 bins, and
% ylim = 100;

% bin in 3d
if nargin > 3
    SizeBin = round(ylim/n_bins);
    DiffBins = round((ylim - max(y))/SizeBin); % number of missing bins to get to ylim
    MaxY = ylim;
else
    DiffBins = 0;
    MaxY = max(y);
end

M = hist3([y,x],[n_bins-DiffBins, n_bins]);

% apply logarithmic scale
MLog = log10(M+0.1);

if nargin > 3
    for row = n_bins-DiffBins+1 : n_bins
        MLog(row, :) = min(MLog); % add missing bins as zeroes
    end
end

% interpolate
%MLog = interp2(MLog,1:0.5:n_bins,(1:0.5:n_bins)');


% plot

%Map = [linspace(0,43/255,64)' linspace(0,160/255,64)' linspace(0,86/255,64)'];
%Map = [linspace(0,11/255,64)' linspace(0,132/255,64)' linspace(0,199/255,64)'];

% generate x and y axis
XAxis = linspace(min(x),max(x),n_bins);
YAxis = linspace(min(y),MaxY,n_bins);

% rescale from 1 to 64
MM = 63;
mn = min(MLog(:));
rng = max(MLog(:))-mn;
MLog2 = 1+MM*(MLog-mn)/rng; % Self scale data
% plot
figure;
image(XAxis, YAxis,MLog2);
set(gca,'YDir','Normal')
colormap(hot)
% mark ticks in colorbar as non-log values
hC = colorbar;
L = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000];
l = 1+MM*(log10(L)-mn)/rng; % Tick mark positions
set(hC,'Ytick',l,'YTicklabel',L);





end

