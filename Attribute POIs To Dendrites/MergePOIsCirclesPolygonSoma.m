function [ PointsInSegments, POIsIn2Segm, POIsInNoSegm, SegmentsPerPOI ] = MergePOIsCirclesPolygonSoma( PointsInSegmentsC, PointsInSegmentsP, POIsSoma, n_segments, PointPlane )

PointsInSegments=cell(1,n_segments);

for seg=1:n_segments
    
    if seg == 1
        PointsInSegments{1,seg} = [PointsInSegmentsC{1,seg}; PointsInSegmentsP{1,seg}; POIsSoma'];
    else
        PointsInSegments{1,seg} = [PointsInSegmentsC{1,seg}; PointsInSegmentsP{1,seg}];
    end
    
    %eliminate POIs that appear twice in the same segment
    POIsN=size(PointsInSegments{1,seg},1); %number of POIs in this segment
    for P=1:POIsN
        if P <= POIsN %because POIsN changes size as I eliminate double elements
            
            F=find(PointsInSegments{1,seg}==PointsInSegments{1,seg}(P,1));
            
            if length(F) > 1
                PointsInSegments{1,seg}(F(2:end))=[];
                POIsN=size(PointsInSegments{1,seg},1);
            end
            clear F
        end
    end
end

% remove POIs that are in soma from other segments
for seg = 2:n_segments
    Zz = ismember(PointsInSegments{1,seg}, PointsInSegments{1,1});
    PointsInSegments{1,seg}=PointsInSegments{1,seg}(find(Zz==0));
end

%check if there are POIs in more than one segment and POIs in no segment
PointPlaneMat=cell2mat(PointPlane');
MaxPoiIndex=max(PointPlaneMat(:,1)); %total number of POIs
SegmentsPerPOI=cell(1,MaxPoiIndex);
POIsIn2Segm=[];
POIsInNoSegm=[];
counter2=1; %counter of elements in POIsInNoSegm
counter3=1; %counter of elements in POIsIn2Segm

for P=1:MaxPoiIndex
    
    counter=0;
    
    for seg=1:n_segments
        if isempty(find(PointsInSegments{1,seg}==P))==0
            counter=counter+1;
            SegmentsPerPOI{1,P}(counter)=seg;
        end
    end
    
    if counter>1
        fprintf('%s\n',['Warning!! The POI ' num2str(P) ' is in multiple segments: ' num2str(SegmentsPerPOI{1,P}) ])
        POIsIn2Segm(counter3)=P;
        counter3=counter3+1;
    end
    
    %list of POIs that are in no segment
    if counter==0
        POIsInNoSegm(counter2)=P;
        counter2=counter2+1;
    end
end

if isempty(POIsInNoSegm)==0
    fprintf('%s\n',['The following POIs are not in any segment: ' num2str(POIsInNoSegm)])
end

end

