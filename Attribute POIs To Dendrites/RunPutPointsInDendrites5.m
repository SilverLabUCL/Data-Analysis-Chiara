
Files = dir;

FilesToExclude = 0; % number of folders with only images at the end of the stack

FilesToAnalyse = 3:( length(Files) - FilesToExclude ); 

for i=1:length(FilesToAnalyse)
    
   Path = [pwd '\' Files(FilesToAnalyse(i)).name] ;
   cd(Path) 
   %Put_Points_In_Dendrites5AndSoma(3:7);
   %Put_Points_In_Dendrites5;
   DeltaFoFPOIsDendrites5;
   %Put_Points_In_Dendrites5AndSomaRIG3;
   close all
   cd ..
end