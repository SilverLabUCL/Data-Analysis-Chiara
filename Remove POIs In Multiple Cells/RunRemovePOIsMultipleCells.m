
% data to analyse, experiments with more than one cell
% folders{1} = 'C:\Data Analysis\Veronica\18 November 2014';
% folders{2} = 'C:\Data Analysis\Veronica\19 November 2014';
% folders{3} = 'C:\Data Analysis\Veronica\20 November 2014';
% folders{4} = 'C:\Data Analysis\Veronica\21 November 2014';
% folders{5} = 'C:\Data Analysis\Veronica\26 November 2014';
% folders{6} = 'C:\Data Analysis\Veronica\27 November 2014';
% folders{7} = 'C:\Data Analysis\Veronica\28 November 2014';
% folders{8} = 'C:\Data Analysis\Veronica\14 October 2014';
% 
% folders{9} = 'C:\Data Analysis\Theodora\28 May 2015';
% folders{10} = 'C:\Data Analysis\Theodora\01 June 2015 Region 1';
% folders{11} = 'C:\Data Analysis\Theodora\02 June 2015';
% folders{12} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 1';
% folders{13} = 'C:\Data Analysis\Theodora\03 June 2015 Region 1 and 2\Region 2';
% folders{14} = 'C:\Data Analysis\Theodora\04 June 2015';
% folders{15} = 'C:\Data Analysis\Theodora\05 June 2015';
% folders{16} = 'C:\Data Analysis\Theodora\09 June 2015 Region 1 Anaesth';
% folders{17} = 'C:\Data Analysis\Theodora\11 June 2015';
% folders{18} = 'C:\Data Analysis\Theodora\16 June 2015';
% 
% folders{19} = 'C:\Data Analysis\Robinson\17 June 2015';
% folders{20} = 'C:\Data Analysis\Robinson\18 June 2015';
% folders{21} = 'C:\Data Analysis\Robinson\22 June 2015';
% folders{22} = 'C:\Data Analysis\Robinson\23 June 2015';
% folders{23} = 'C:\Data Analysis\Robinson\24 June 2015';
% folders{24} = 'C:\Data Analysis\Robinson\26 June 2015';
% folders{25} = 'C:\Data Analysis\Robinson\02 July 2015';
% folders{26} = 'C:\Data Analysis\Robinson\07 July 2015';
% folders{27} = 'C:\Data Analysis\Robinson\08 July 2015';
% folders{28} = 'C:\Data Analysis\Robinson\11 July 2015';
% 
% folder{29} = 'C:\Data Analysis\Karina\14 January 2016';
% folder{30} = 'C:\Data Analysis\Karina\15 January 2016';
% 
% folder{31} = 'C:\Data Analysis\Tina\03 February 2015';

% folders{1} = 'C:\Data Analysis\Karina\09 February 2016';
% folders{2} = 'C:\Data Analysis\Bonnie\09 February 2016';
% folders{3} = 'C:\Data Analysis\Karina\18 January 2016';

folders{1} = '2016-March-01';
folders{2} = '2016-March-02';
folders{3} = '2016-March-11 Bonnie';
folders{4} = '2016-March-11 Clyde';

for f = 1: length(folders)
    
   disp(['I am now working on experiment ' folders{f}])
   
   cd(folders{f})
   RemovePOIsMultipleCells;
   cd ..
end
