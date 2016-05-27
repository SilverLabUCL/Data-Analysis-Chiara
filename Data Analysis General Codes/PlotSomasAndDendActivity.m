
% plot eah dendrites superimpose with soma activity

n_segments = size(DeltaFoverF_Sm_Lin,1);

for s = 2:n_segments
   
    if sum(isnan(DeltaFoverF_Sm_Lin(s,:))) < length(DeltaFoverF_Sm_Lin(s,:))*0.5
        
       figure; 
       plot(Times_Lin(1,:)*1e-3,DeltaFoverF_Sm_Lin(1,:)./max(DeltaFoverF_Sm_Lin(1,:)),'b')
       hold on
       plot(Times_Lin(s,:)*1e-3,DeltaFoverF_Sm_Lin(s,:)./max(DeltaFoverF_Sm_Lin(s,:)),'r')
       title([ 'Branch ' num2str(s)])
       xlabel('Time, s')
       axis tight, box off
    end
    
end

