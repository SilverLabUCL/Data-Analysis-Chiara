function [ AmplHist ] = CompareAmplitudesEvents( BranchesActive, Ampl )
% Compare the amplitudes of calcium events that occurred in different
% numbers of imaged branches

bins = 0:10:100;

AmplHist = cell(1,10);
AmplMean = NaN(1,10);
AmplSem = NaN(1,10);

for b = 1:length(bins)-1
    
    BinIndexes = find(BranchesActive > bins(b) & BranchesActive < bins(b+1));
    AmplHist{b} = Ampl(BinIndexes);
    clear BinIndexes
    
    AmplMean(b) = nanmean(AmplHist{b});
    AmplSem(b) = nanstd(AmplHist{b})/length(AmplHist{b});
end

figure;
bar(AmplMean)
hold on; errorbar(AmplMean, AmplSem, 'k.')

end

