function [ PercTimesActive1,  PercTimesActive2] = PercAPsEachBranchDivideTwo( BranchesCoActivebAP, ImagedBranchesbAP )
% for each branch, measure how often it is active with a somatic AP.
% Usefule control to check if there are branches that are never active
% with the soma.

% divide in two parts, first half of experiment and second half

n_APs = length(BranchesCoActivebAP);
n_APsH = floor(n_APs/2);

BranchesActive1 = [];
BranchesImaged1 = [];
BranchesActive2 = [];
BranchesImaged2 = [];
for p = 1:n_APsH
    BranchesActive1 = [BranchesActive1 BranchesCoActivebAP{p}];
    BranchesImaged1 = [BranchesImaged1 ImagedBranchesbAP{p}];
    
    BranchesActive2 = [BranchesActive2 BranchesCoActivebAP{p+n_APsH}];
    BranchesImaged2 = [BranchesImaged2 ImagedBranchesbAP{p+n_APsH}];
end



n_branches = max([BranchesImaged1 BranchesImaged2]); % number of branches

PercTimesActive1 = NaN(1,n_branches);
PercTimesActive2 = NaN(1,n_branches);

for br = 1:n_branches
    
    if length(find( BranchesImaged1 == br )) > 10 % if branch has been imaged at least 5 times
        PercTimesActive1(br) = length(find( BranchesActive1 == br ))/length(find( BranchesImaged1 == br ))*100; 
    end
    
    if length(find( BranchesImaged2 == br )) > 10 % if branch has been imaged at least 5 times
        PercTimesActive2(br) = length(find( BranchesActive2 == br ))/length(find( BranchesImaged2 == br ))*100;
    end
end

figure;
bar(PercTimesActive1)
xlabel('Branch Number')
ylabel('% times active with a somatic calcium transient 1')

figure;
bar(PercTimesActive2)
xlabel('Branch Number')
ylabel('% times active with a somatic calcium transient 2')


end

