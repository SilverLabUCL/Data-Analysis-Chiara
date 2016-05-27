function [ PointsInSegments, POIsIn2Segm, POIsInNoSegm, BranchesInfo, NodesInfo] = Put_Points_In_Dendrites5AndSoma( PlanesSoma, PathExp, OffsetRadius, FrameSize )
%determines which POIs (imaged during an experiment) are in which branch of
%a dendritic tree.

%compared to Put_Points_In_Vaa3d_Dendrites2, uses TREES toolbox to "extract"
%topology information and standardize branch IDs

%neuron can be traced in vaa3d, saved as a swc format (correct format, so
%need to use plugin sort_neuron in vaa3d), then the tracing is imported in
%TREES toolbox and the topology information is extracted. Then the imaged
%POIs are attributed to each segment/branch of the neuron.

% compared to "Put_Points_In_Dendrites5", this version is for L2/3 neurons where I could image the
% soma at the same time. So neurons are usually traced with neuTube instead
% of Vaa3d, and there is a small extra function " [ POIsSoma ] =
% POIsInSoma( tree, PointPlane, PlanesSoma ) " that finds POI in the soma
% (assuming that soma is where root is) but need to give as input:
% PlanesSoma: planes where soma is


%% default inputs
if nargin < 4
    FrameSize=511;
end

if nargin <3
    OffsetRadius=3;
end

if nargin<2
    PathExp=pwd;
end

%% use TREES toolbox to load tree and to extract topology information
%load tree
start_trees
SwcFiles = dir('*.swc'); % finds swc files in the current folder
if length(SwcFiles) == 1
    load_tree(SwcFiles.name) % loads swc file in the current folder
else
    load_tree
end
%if Z-stack images are loaded into vaa3d in 16-bit format instead of 8-bit,
%y axis is reverted: in this case, correct y coordinates:
trees{1,1}.Y=FrameSize-trees{1,1}.Y;
%sort tree, relabel nodes and identify branches
close all
SortedTree = sort_treeWithSoma(trees{1,1});
%% save figures
% ImageHandle = gcf;
% for fig = 1:ImageHandle
%     saveas(fig,[PathExp '\SimilarBranchesDetected' trees{1,1}.name ' ' num2str(fig) '.fig'])
% end
% dissect tree: get info on branches
[BranchesInfo, NodesInfo]=dissect_tree(SortedTree);

%plot
figure; plot_tree(SortedTree,NodesInfo(:,1)); shine; colorbar
figure; plot_tree(SortedTree,NodesInfo(:,1)); shine; colorbar;colormap(lines)

%% generate a structure: SegmentCoor {SegmentID} nodes(X Coor, Y Coor, Z Coor, radius). Also convert coordinates to same system, round Z coordinates, add offsetradius.

SegmentCoor=GenerateSegmentCoor(SortedTree, NodesInfo, OffsetRadius, FrameSize);
n_segments=length(SegmentCoor);

%% get POIs coordinates: load PointPlane

PathPointsCoor=[PathExp '\images.mat'];
load(PathPointsCoor,'PointPlane')

%correct coordinates of PointPlane
PointPlaneCorr=PointPlane;
for pl=1:length(PointPlane)
    PointPlaneCorr{1,pl}(:,3)=FrameSize - PointPlane{1,pl}(:,3);
end
%% determine which POIs are in which branch

%for each node compute distance with all POIs and find POIs closer than radius
[ PointsInSegmentsC ] = POIsInSegments_Circles(PointPlaneCorr,SegmentCoor);

%for each node draw a polygon with subsequent node (if it is on the same plane) and look for POIs in that polygon
[ PointsInSegmentsP ] = POIsInSegments_Polygons(PointPlaneCorr,SegmentCoor);

%% find POIs in soma

[ POIsSoma ] = POIsInSoma( SortedTree, PointPlaneCorr, PlanesSoma );

%% merge POIs found in polygons and found in circles

[ PointsInSegments, POIsIn2Segm, POIsInNoSegm, SegmentsPerPOI ] = MergePOIsCirclesPolygonSoma( PointsInSegmentsC, PointsInSegmentsP, POIsSoma, n_segments, PointPlaneCorr );

%% plot

figure;
ZPlanesNumber=size(PointPlaneCorr,2);
%plot all POIs in black
for pl=1:ZPlanesNumber
    subplot(2,ceil(ZPlanesNumber/2),pl)
    plot(PointPlaneCorr{pl}(:,2),PointPlaneCorr{pl}(:,3),'k*','MarkerSize',2)
    text(PointPlaneCorr{pl}(:,2),PointPlaneCorr{pl}(:,3), num2str(PointPlaneCorr{pl}(:,1)),'FontSize',6,'Color','black')
    hold all
    title(['Plane ' num2str(pl)])
    xlim([1 FrameSize]), ylim([1 FrameSize])
end

%plot segment and POIs in each segment
ColorMat=lines(n_segments); %set colormap for segments and POIs in segments
for seg=1:n_segments
    
    PlanesSegment=unique(SegmentCoor{1,seg}(:,3)); %planes where segment is
    
    for pl=1:length(PlanesSegment)
        
        subplot(2,ceil(ZPlanesNumber/2),PlanesSegment(pl))
        
        %plot segments
        CoorInPlane=find(SegmentCoor{1,seg}(:,3)==PlanesSegment(pl)); %find coordinates of segment in plane pl
        plot(SegmentCoor{1,seg}(CoorInPlane,1),SegmentCoor{1,seg}(CoorInPlane,2),'-','color', ColorMat(seg,:),'LineWidth',1.5)
        %text(SegmentCoor{1,seg}(CoorInPlane(1),1), FrameSize-SegmentCoor{1,seg}(CoorInPlane(1),2), num2str(seg),'FontSize',15,'Color',ColorMat(seg,:),'FontWeight','bold')
        hold all
        clear CoorInPlane
        
        %plot POIs in segments
        POIsIndexes= PointsInSegments{1,seg}; %get POIs in segment seg
        for p=1:length(POIsIndexes)
            POIRow=find(PointPlaneCorr{PlanesSegment(pl)}(:,1)==POIsIndexes(p));
            if isempty(POIRow)==0 %if POI p is in plane pl
                plot(PointPlaneCorr{PlanesSegment(pl)}(POIRow,2), PointPlaneCorr{PlanesSegment(pl)}(POIRow,3),'o','color', ColorMat(seg,:),'MarkerSize',6)
                %text(PointPlane{PlanesSegment(pl)}(POIRow,2), FrameSize-PointPlane{PlanesSegment(pl)}(POIRow,3), num2str(PointPlane{PlanesSegment(pl)}(POIRow,1)),'FontSize',6,'Color',ColorMat(seg,:))
                if isempty(find(POIsIn2Segm==POIsIndexes(p), 1))==0
                    text(PointPlaneCorr{PlanesSegment(pl)}(POIRow,2), PointPlaneCorr{PlanesSegment(pl)}(POIRow,3), num2str(PointPlaneCorr{PlanesSegment(pl)}(POIRow,1)),'FontSize',10,'Color','red')
                end
                
                hold all
            end
        end
    end
end
% plot soma 
for pl=1:length(PlanesSoma)
    
    subplot(2,ceil(ZPlanesNumber/2),PlanesSoma(pl))
    % plot soma
    PloTCircle(SortedTree.X(1), SortedTree.Y(1) , SortedTree.D(1)/2);
    hold all
    % plot POIs in soma
    for poi = 1: length(POIsSoma)
    POIs = find(PointPlaneCorr{PlanesSoma(pl)}(:,1) == POIsSoma(poi));
    plot(PointPlaneCorr{PlanesSoma(pl)}(POIs,2), PointPlaneCorr{PlanesSoma(pl)}(POIs,3),'bo','MarkerSize',6)
    text(PointPlaneCorr{PlanesSoma(pl)}(POIs,2), PointPlaneCorr{PlanesSoma(pl)}(POIs,3), num2str(PointPlaneCorr{PlanesSoma(pl)}(POIs,1)),'FontSize',6,'Color','black')
    end
end

%% save

Date=date;
%save figures
saveas(gcf,[PathExp '\PutPointsInDendrites5AndSoma' trees{1,1}.name '.fig'])
saveas(gcf-1,[PathExp '\DissectTree2' trees{1,1}.name '.fig'])
saveas(gcf-2,[PathExp '\DissectTree1' trees{1,1}.name '.fig'])

%save data
save(['PutPointsInDendrites5AndSoma' Date trees{1,1}.name '.mat'])

end

