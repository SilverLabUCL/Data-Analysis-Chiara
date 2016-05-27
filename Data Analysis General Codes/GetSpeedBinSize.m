function [ BinSize, nBins,MaxSpeed ] = GetSpeedBinSize( nStacks )
%Load speed data from multiple stacks and determines speed bin size such
%that mouse spends at least a defined number of seconds running at the
%speed of each bin

%threshold to accept bin size
ThrBin=20; %in seconds: so mouse had to pass at least 3 s running at the speed in each bin

FilesLoaded=cell(nStacks,1);
SpeedAll=[];

%load data
for s=1:nStacks
    [filename,pathname]=uigetfile('*.mat'); %the user needs to load a file that contains a matrix with speed data concatenated
    FilesLoaded{s}=[pathname filename];
    load(FilesLoaded{s},'speedD')
    
    SpeedAll=[SpeedAll speedD];
end

%set threshold to accept bin size
NAN= isnan(SpeedAll); %remove NaN
SpeedNoNAN=SpeedAll;
SpeedNoNAN(NAN)=[];

SpeedMoving=SpeedNoNAN; %remove when animal is stationary (a lot of time) or percentage doesn't work
Stationary=SpeedNoNAN<5;
SpeedMoving(Stationary)=[];

Thr=ThrBin*1e3/20; %time resolution of speedD is 20 ms because 2 ms is time res of encored, but this data was downsample by a factor 10


% look for bin with right size
MinSpeed=min(SpeedMoving);
MaxSpeed=max(SpeedMoving)-10; %3 rpm is uncertainty of the encoder anyway, plus want to avoid a sudden peak in running messing all data

binCounts=1;
nBins=101; %start with 100 bins

while min(binCounts)<Thr
    
    nBins=nBins - 1;
    
    binRanges=linspace(MinSpeed,MaxSpeed,nBins+1);
    binCounts=histc(SpeedMoving,binRanges);
    
    binCounts(end-1)=binCounts(end) + binCounts(end-1);  %weird thing at last number 
    binCounts(end)=[];
end

BinSize=(MaxSpeed + abs(MinSpeed)) / nBins; %Bin size, in rpm

figure;
hist(SpeedMoving,nBins) 

figure;
hist(SpeedNoNAN)%total running data binned, matlab chooses bin size

end

