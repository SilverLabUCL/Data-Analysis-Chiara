function [ M, MLog2 ] = DensityPlot( x,y, n_bins )
% calculate density plot from a scatter plot x,y
% bins in 3d and plots in logarithmic scale

% bin in 3d
M = hist3([y,x],[n_bins, n_bins]);
% apply logarithmic scale
MLog = log10(M+0.1);

% interpolate
%MLog = interp2(MLog,1:0.5:n_bins,(1:0.5:n_bins)');


% plot

%Map = [linspace(0,43/255,64)' linspace(0,160/255,64)' linspace(0,86/255,64)'];
%Map = [linspace(0,11/255,64)' linspace(0,132/255,64)' linspace(0,199/255,64)'];

% generate x and y axis 
XAxis = linspace(min(x),max(x),n_bins);
YAxis = linspace(min(y),max(y),n_bins);
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

