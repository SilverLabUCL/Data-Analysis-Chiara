function [ PercTimesActive ] = PercAPsEachBranch( BranchesCoActivebAP, ImagedBranchesbAP )
% for each branch, measure how often it is active with a somatic AP.
% Usefule control to check if there are branches that are never active
% with the soma.

BranchesActive = cell2mat(BranchesCoActivebAP');
BranchesImaged = cell2mat(ImagedBranchesbAP');

n_branches = max(BranchesImaged); % number of branches

PercTimesActive = NaN(1,n_branches);

for br = 1:n_branches
   
    if length(find( BranchesImaged == br )) > 10 % if branch has been imaged at least 10 times
        
        PercTimesActive(br) = length(find( BranchesActive == br ))/length(find( BranchesImaged == br ))*100;
        
        if PercTimesActive(br) == 0
            disp(['ATTENTION!! Found branch ' num2str(br) ' never active with a AP'])
        end
    end
end

figure;
bar(PercTimesActive)
xlabel('Branch Number')
ylabel('% times active with a somatic calcium transient')
end

