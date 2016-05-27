function [TransientsChar, ResponsesToDiscard, ResponsesBin] = DiscardResponses( TransientsChar,  Baseline, data, ResponsesBin)
% discard responses lower than hard threshold or 3 standard deviations of the noise

% determine threshold for amplitude
if length(Baseline) > 1 % as 3 standard deviations of noise if baseline is a vector    
    Thr = 3*nanstd( data(Baseline(1):Baseline(2)) );
else
    Thr = Baseline; % threshold = baseline is baseline is a scalar
end


% find responses with amplitudes lower than threshold and discard them
counter = 0;
ResponsesToDiscard = [];

for response = 1 : length(TransientsChar.Amplitude)
    if TransientsChar.Amplitude(response) < Thr
        counter = counter + 1;
        ResponsesToDiscard(counter) = response;
    end
end

% add zero at beginning and end of ResponsesBin to detect correctly responses at
% limits of recording
ResponsesBin = [ 0 ResponsesBin 0] ;

% remove responses to discard from ResponsesBin
BegAllResp=find(diff(ResponsesBin) == 1); %indexes where responses start in ResponsesBin
EndAllResp=find(diff(ResponsesBin) == -1); %indexes where responses end in ResponsesBin

for R = 1 : length(ResponsesToDiscard)
    BR = find( BegAllResp <= TransientsChar.PosMaxInDetec(ResponsesToDiscard(R))+1,1,'last' ) ; %index where response to discard starts
    ER = find( EndAllResp >= TransientsChar.PosMaxInDetec(ResponsesToDiscard(R))+1,1) ; %index where response to discard ends
    ResponsesBin(BegAllResp(BR) : EndAllResp(ER)) = 0;
end

% remove zeroes added before
ResponsesBin(1) = [];
ResponsesBin(end) = [];

% remove data for responses to discard
TransientsChar.Amplitude(ResponsesToDiscard) = [];
TransientsChar.PosMax(ResponsesToDiscard) = [];
TransientsChar.PosMaxInDetec(ResponsesToDiscard) = [];

end

