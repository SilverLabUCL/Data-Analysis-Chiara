function [ CaTransients ] = TransientsBranchesActiveState( PathTransientsChar)
% for each response, determines:
% - how many and which branches are active
% - when the response occurred and how long it lasted
% - animal speed when response occurred

%%%%% input:
% - path where variable TransientsChar from code CharacteriseTransients4 is
% - Times when visual stimulus was on
%%%%% output: structure CaTransients: one element per response, fields:
% - BranchesActive: ID of branches active
% - MeanOnset: mean onset of the response across branches, in seconds
% - MeanDuration: mean duration of the response across branches, in seconds
% - MeanAmplitude: mean amplitude of the response across branches, in Df/f
% - MouseSpeed: in cm/s
% - BranchesImaged

% load data
[ResponsesBin, TimeResponses, TimeRes, TransientsChar, Segments, Speed, TimeSpeed, TrialLength] = LoadData(PathTransientsChar);

% find responses from ResponsesBin
[ ~, Locations, StartR, EndR ] = FindResponsesInResponsesBin( ResponsesBin );

% find branches active in each response, and get mean onset and mean
% duration of response
[ CaTransients] = FindBranchesActiveOnsetDuration(Locations, StartR, EndR, ResponsesBin, TransientsChar, TimeResponses, TimeRes);

% get speed data during each response
SpeedInt = interp1(TimeSpeed, Speed, TimeResponses);
for resp = 1:length(CaTransients)
    
    SpeedMean = nanmean(SpeedInt(CaTransients(resp).BranchesActive,:),1);
    TimeSpeedMean = nanmean(TimeResponses(CaTransients(resp).BranchesActive,:),1);
    
    [~, IndexResponseStart] = (min( abs( CaTransients(resp).MeanOnset*1e3 - TimeSpeedMean ) ));
    [~, IndexResponseEnd] = (min( abs( (CaTransients(resp).MeanOnset + CaTransients(resp).MeanDuration)*1e3 - TimeSpeedMean ) ));
    
    CaTransients(resp).MouseSpeed = SpeedMean(IndexResponseStart:IndexResponseEnd)*50/60;
end

% convert onset of responses in onset inside the trial, and not inside
% concatenated trials, and add info about imaged segments
for resp = 1:length(CaTransients)
    CaTransients(resp).MeanOnset = mod(CaTransients(resp).MeanOnset,TrialLength);
    CaTransients(resp).BranchesImaged = Segments;
end


end

function [ResponsesBin, Times_Lin, TimeRes, TransientsChar, Segments, speedD, timeD, TrialLength] = LoadData(PathTransientsChar)

load(PathTransientsChar, 'ResponsesBin','Segments','TransientsChar','Times_Lin','TimeRes')
PathSpeed = PathTransientsChar(1: find(PathTransientsChar == '\', 2,'last') );
load([PathSpeed '\SpeedConcat.mat'],'timeD','speedD')
load([PathSpeed '\pointTraces.mat'],'Times')
TrialLength = round(Times(1,end,end)*1e-3);

end

function [ Peaks, Locations, StartR, EndR ] = FindResponsesInResponsesBin( ResponsesBin )

SumResponses = [0 sum(ResponsesBin,1)];

% find beginning and end of each response in the summation vector
Zeros = (SumResponses>0);
StartR = find( diff(Zeros) == 1);
EndR = find( diff(Zeros) == -1);

% find responses and number of branches co active in each response
Peaks = zeros(1,length(StartR));
Locations = zeros(1,length(StartR));
for i=1:length(StartR)
    [Peaks(i), Locations(i)]= max(SumResponses(StartR(i):EndR(i)));
    Locations(i) = Locations(i) + StartR(i) - 2;
end

end

function [ CaTransients] = FindBranchesActiveOnsetDuration(Locations, StartR, EndR, ResponsesBin, TransientsChar, TimesResponses, TimeRes)

CaTransients = struct;

for resp = 1:length(Locations)
    
    counter = 0;
    CaTransients(resp).BranchesActive = [];
    
    for br = 1:size(ResponsesBin,1)
        if ResponsesBin(br,Locations(resp)) == 1
            counter = counter + 1;
            CaTransients(resp).BranchesActive (counter) = br;
            
            IndexResp = find(TransientsChar(1,br).PosMaxInDetec > StartR(resp) & TransientsChar(1,br).PosMaxInDetec < EndR(resp));
            if length(IndexResp) == 1 && isnan(TransientsChar(1,br).OnsetApprox(IndexResp)) == 0
                Onset(counter) = TimesResponses( br, TransientsChar(1,br).OnsetApprox(IndexResp)) * 1e-3;
                Duration(counter) = TransientsChar(1,br).Duration(IndexResp)*TimeRes*1e-3;
                Amplitude(counter) = TransientsChar(1,br).Amplitude(IndexResp);
            else
                Onset(counter) = NaN;
                Duration(counter) = NaN;
                Amplitude(counter) = NaN;
            end
        end
    end
    
    CaTransients(resp).MeanOnset = nanmean(Onset);
    CaTransients(resp).MeanDuration = nanmean(Duration);
    CaTransients(resp).MeanAmplitude = nanmean(Amplitude);
    
    clear Onset Duration Amplitude
end

end
