% start and end point of calcium transient to analyse, in indexes
start = 112100;
End =  122400;

Soma = SomaDS(start:End)';  % data in soma
Tuft = TuftDS(start:End)'; % data in tuft
time = TimeConcat(start:End)'*1e-3; % time

figure; plot(Soma,'r'); hold on; plot(Tuft,'b')

% set baseline to zero
BaselineEnd = 500; 
baseline = mean(Tuft(1:BaselineEnd));
Tuft = Tuft - baseline;
baseline = mean(Soma(1:BaselineEnd));
Soma = Soma - baseline;

