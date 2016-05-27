
Perc = 0.05;

% calculate onset of soma from fit SomaFit
[MM, posMax] = max(SomaFit(:,2));
[ ~, TenPercIndex] = min( abs(MM*Perc - SomaFit(1:posMax,2)) );
OnsetSoma = (SomaFit(TenPercIndex,1));
% calculate onset of tuft
[MMT, posMax]= max(TuftFit(:,2));
[ ~, TenPercIndexT] = min( abs(MMT*Perc - TuftFit(1:posMax,2)) );
OnsetTuft = (TuftFit(TenPercIndexT,1));

% find indexes of onsets in original time vector
[~, OnsetTuftInd] = min(abs( OnsetTuft - time ));
[~, OnsetSomaInd] = min(abs( OnsetSoma - time ));

% plot
figure; 
plot(SomaFit(:,1),SomaFit(:,2),'r')
hold on; plot(OnsetSoma, SomaFit(TenPercIndex,2),'ro')
hold all;
plot(TuftFit(:,1),TuftFit(:,2))
hold on; plot(OnsetTuft, TuftFit(TenPercIndexT,2),'bo')

figure; 
plot(time,Soma,'r')
hold on;
plot(SomaFit(:,1),SomaFit(:,2),'r')
hold all;
plot(OnsetSoma, SomaFit(TenPercIndex,2),'ro')


figure; 
plot(time,Tuft,'b')
hold on;
plot(TuftFit(:,1),TuftFit(:,2),'b')
hold all;
plot(OnsetTuft, TuftFit(TenPercIndexT,2),'bo')

figure;
plot(time,Soma,'r')
hold on; plot(OnsetSoma, Soma(OnsetSomaInd),'ro')
hold all;
plot(time,Tuft,'b')
hold on; plot(OnsetTuft, Tuft(OnsetTuftInd),'bo')
