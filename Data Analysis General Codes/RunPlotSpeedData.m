
Files = dir;

for i = 3:length(Files)
    
    Path = [pwd '\' Files(i).name] ;
    cd(Path)
    load('pointTraces.mat', 'DataGreenCh')
    n_trials = size(DataGreenCh,1);
    
    SpeedFile = [Path '\SpeedData.mat'];
    
    if exist(SpeedFile,'file') == 2
        load(SpeedFile)
        [ speedD, timeD ] = PlotSpeedData( Speed,n_trials );
    end
    
    %close
    cd ..
end
