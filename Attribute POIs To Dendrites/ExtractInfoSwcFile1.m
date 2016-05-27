function [SegmentCoor, SegmentType]= ExtractInfoSwcFile1(SegmentsInfo)
%extract information on segments traced with Vaa3d from swc file, imported
%in matrix SegmentsInfo
%SegmentsInfo columns: n,type,x,y,z,radius,parent

%outputs:
%SegmentCoor{Segment Number} (x,y,z,radius)

IndexEndSegments=find(SegmentsInfo(:,7)==-1); %find where each segment ends

if IndexEndSegments(1)==1 %if it starts by -1
    IndexEndSegments(1)=0;
    IndexEndSegments=[IndexEndSegments; size(SegmentsInfo,1)];
else
    IndexEndSegments=[0; IndexEndSegments];
end
n_segments=length(IndexEndSegments)- 1;
SegmentCoor=cell(1, n_segments );
SegmentType=cell(1, n_segments );
 
for s=1: (n_segments)
    
    %segments coordinates
    SegmentCoor{s} (:, 1:4) = SegmentsInfo( IndexEndSegments(s)+1 : (IndexEndSegments(s + 1) ) , 3:6);  
    
    %segment type
    if SegmentsInfo( IndexEndSegments(s)+1, 2) == 0
        SegmentType{s}= 'Undefined';
    elseif SegmentsInfo( IndexEndSegments(s)+1, 2) == 1
        SegmentType{s}= 'Soma';
    elseif SegmentsInfo( IndexEndSegments(s)+1, 2) == 2
        SegmentType{s}= 'Axon';
    elseif SegmentsInfo( IndexEndSegments(s)+1, 2) == 3
        SegmentType{s}= 'Dendrite';
    elseif SegmentsInfo( IndexEndSegments(s)+1, 2) == 4
        SegmentType{s}= 'Apical dendrite';
    else
        SegmentType{s}= 'Else';
    end

end


end