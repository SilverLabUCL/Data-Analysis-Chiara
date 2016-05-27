function [ OrientationCurveIntegral, SemIntegral, DataPerOrient ] = OrTuning( AllStacksConcat, TimeAllStacks, FlagNorm, FlagSave)
% Computes orientation tuning for all the dendrites averaged together, need
% to run it after the code TuftActivityAllStacks or BranchActivityAllStacks
% that concatenate data from different stacks together

% version 2: adds errorbar to tuning curves, and normalized curves if
% FlagNorm = 1. 

%% beginning stuff

if nargin < 4
    FlagSave = 1;
end

if nargin < 3
    FlagNorm = 1;
end

% parameters
NumberOrientations = 8;
StimulusOn = 4; %time when visual stimulus goes on in seconds
StimulusOff = 6; %time when visual stimulus goes off in seconds

NumberTrials = size( AllStacksConcat,1 );
NumberTimePoints = size( AllStacksConcat,2 );
NumberRepetitions = NumberTrials/NumberOrientations;
TimeRes = mean(diff(TimeAllStacks)); % time resolution, in miliseconds

%% divide data based on orientation presented
DataPerOrient = NaN(NumberOrientations, NumberRepetitions, NumberTimePoints);

for Trial = 1 : NumberOrientations : NumberTrials
    for Or = 1 : NumberOrientations
        
        Tr = Trial +Or -1 ;
        DataPerOrient( Or, (Tr-Or)/NumberOrientations+1, : ) = AllStacksConcat( Tr,: );
        
    end
end

%% plot activity at all trials for each orientation
CMax = squeeze(max(max(max(DataPerOrient))));
CMin = squeeze(min(min(min(DataPerOrient))));

for Or = 1 : NumberOrientations
    
    figure;
    imagesc(squeeze(DataPerOrient( Or,:,: )))
    colormap(jet)
    caxis([CMin CMax]) %set same scale
    colorbar;
    hold on;
    plot( repmat(2*1e3/TimeRes, NumberRepetitions+2 ), 0:(NumberRepetitions+1), 'k-','LineWidth',2)
    hold all;
    plot( repmat(4*1e3/TimeRes, NumberRepetitions+2 ), 0:(NumberRepetitions+1), 'k-','LineWidth',2)
    title([' Orientation ' num2str(Or)])
    xlabel(['TimePoints, Time resolution: ' num2str(TimeRes) ' ms' ])
    ylabel('Repetitions')
    
    % plot average activity of all trials for each orientations
    figure;
    plot(TimeAllStacks*1e-3,squeeze(nanmean(DataPerOrient( Or, :,: ),2)))
    title([' Orientation ' num2str(Or)])
    %ylim([-0.5 1.8])
    axis tight
    xlabel(' Time, seconds')
    ylabel(' Df/f ')
    
    %save figures
    if FlagSave
        saveas(gcf-1,[' ActivityAllRepetitionsOr ' num2str(Or)])
        saveas(gcf,[' ActivityAveragedAcrossRepetitionsOr ' num2str(Or)])
    end
    
end

%% compute mean, median, peak and integral of response, during visual stim presentation
StimulusOnIndex = round(StimulusOn*1e3/TimeRes);
StimulusOffIndex = round(StimulusOff*1e3/TimeRes);

MeanResponse = NaN( NumberOrientations, NumberRepetitions);
MedianResponse = NaN( NumberOrientations, NumberRepetitions);
PeakResponse = NaN( NumberOrientations, NumberRepetitions);
IntegralResponse = NaN( NumberOrientations, NumberRepetitions);

for Or = 1 : NumberOrientations
    for Rep = 1 : NumberRepetitions
        
        MeanResponse( Or, Rep) = nanmean( squeeze(DataPerOrient(Or, Rep, StimulusOnIndex:StimulusOffIndex)) );
        MedianResponse( Or, Rep) = nanmedian( squeeze(DataPerOrient(Or, Rep, StimulusOnIndex:StimulusOffIndex)) );
        PeakResponse( Or, Rep) = nanmax( squeeze(DataPerOrient(Or, Rep, StimulusOnIndex:StimulusOffIndex)) );
        IntegralResponse( Or, Rep) = nansum( squeeze(DataPerOrient(Or, Rep, StimulusOnIndex:StimulusOffIndex)) );
        
    end
end

%% normalize tuning curves

if FlagNorm 
    
    for rep = 1:NumberRepetitions
        
        MeanResponse(:,Rep) = MeanResponse(:,Rep) - min(MeanResponse(:,Rep));
        MedianResponse(:,Rep) = MedianResponse(:,Rep) - min(MedianResponse(:,Rep));
        PeakResponse(:,Rep) = PeakResponse(:,Rep) - min(PeakResponse(:,Rep));
        IntegralResponse(:,Rep) = IntegralResponse(:,Rep) - min(IntegralResponse(:,Rep));

    end
end

%% compute orientation tuning curves

OrientationCurveMean = nanmean( MeanResponse,2 );
OrientationCurveMedian = nanmean( MedianResponse,2 );
OrientationCurvePeak = nanmean( PeakResponse,2 );
OrientationCurveIntegral = nanmean( IntegralResponse,2 );

SemMean = NaN(1,NumberOrientations);
SemMedian = NaN(1,NumberOrientations);
SemPeak = NaN(1,NumberOrientations);
SemIntegral = NaN(1,NumberOrientations);

for or = 1:NumberOrientations
    SemMean(or) = nanstd( MeanResponse(or,:) )./sqrt(NumberRepetitions);
    SemMedian(or) = nanstd( MedianResponse(or,:) )./sqrt(NumberRepetitions);
    SemPeak(or) = nanstd( PeakResponse(or,:) )./sqrt(NumberRepetitions);
    SemIntegral(or) = nanstd( IntegralResponse(or,:) )./sqrt(NumberRepetitions);
end

% plot orientation tuning curves
figure;

subplot(2,2,1)
plot(OrientationCurveMean)
hold on;
errorbar(OrientationCurveMean, SemMean,'.')
title('Mean')
xlim([0.5 NumberOrientations+0.5])

subplot(2,2,2)
plot(OrientationCurveMedian)
hold on;
errorbar(OrientationCurveMedian, SemMedian,'.')
title('Median')
xlim([0.5 NumberOrientations+0.5])

subplot(2,2,3)
plot(OrientationCurvePeak)
hold on;
errorbar(OrientationCurvePeak, SemPeak,'.')
title('Peak')
xlim([0.5 NumberOrientations+0.5])

subplot(2,2,4)
plot(OrientationCurveIntegral)
hold on;
errorbar(OrientationCurveIntegral, SemIntegral,'.')
title('Integral')
xlim([0.5 NumberOrientations+0.5])

%% save
if FlagSave
    save(['OrTuning ' date ' .mat'])
    saveas(gcf, 'OrTuningCurves.fig')
end

end

