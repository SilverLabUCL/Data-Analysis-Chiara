% compare onsets at soma and tuft (and spatial spread and duration) for all events in the soma

% for data obtained in rig3, when I was imaging tuft and soma of L5 neurons
% at the same time. This code needs the info from the code CharacteriseTransients4
clear all;
% load data
load('CharacteriseTransients.mat', 'TransientsChar','Times_Lin','TimeRes')

% initialise stuff
Interval = 1000; % to determine if it's the same response, and if onset was measured right in milliseconds

n_APs = length(TransientsChar(1,1).Amplitude);
n_segments = length(TransientsChar);

OnsetsSoma = NaN(1,n_APs); % all in seconds
OnsetsTuft = NaN(1,n_APs);
DurationSoma = NaN(1,n_APs);
DurationTuft = NaN(1,n_APs);
Distrib = NaN(1,n_APs);
OnsetsBranch = NaN(n_APs,n_segments);
DurationBranch = NaN(n_APs,n_segments);

% get onset values
 for AP = 1:n_APs % for each event at the soma
     
     OnsetsSoma(AP) = Times_Lin(1,TransientsChar(1,1).OnsetApprox(AP))*1e-3;
     Distrib(AP) = TransientsChar(1,1).Distribution(AP);
     DurationSoma(AP) = TransientsChar(1,1).Duration(AP)*TimeRes*1e-3;
     
     % for each tuft branch
     for br = 3:n_segments
         
         Oonsets = TransientsChar(1,br).OnsetApprox(:); % onsets of all responses
         
         % find right response in tuft
         for o = 1:length(Oonsets)
             if abs(TransientsChar(1,br).OnsetApprox(o) - TransientsChar(1,1).OnsetApprox(AP))*TimeRes < Interval
                 OnsetsBranch(AP,br) = Times_Lin(br,TransientsChar(1,br).OnsetApprox(o))*1e-3;
                 DurationBranch(AP,br) = TransientsChar(1,br).Duration(AP)*TimeRes*1e-3;
             end
         end
         clear Oonsets
     end
     
     OnsetsTuft(AP) = nanmean(OnsetsBranch(AP,:));
     DurationTuft(AP) = nanmean(DurationBranch(AP,:));
     
 end