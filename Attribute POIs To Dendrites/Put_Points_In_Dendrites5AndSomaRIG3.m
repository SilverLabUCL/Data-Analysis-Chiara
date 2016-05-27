function [ PointsInSegments, POIsIn2Segm, POIsInNoSegm, BranchesInfo, NodesInfo] = Put_Points_In_Dendrites5AndSomaRIG3( PathExp, OffsetRadius, FrameSize )
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

% version RIG3: on rig3 I take big Z stacks with small Zsteps (because
% system is faster), so easy to miss POIs because they are in the wrong
% plane. So here attribute POIs to dendrites without considering Z
% coordinates. Also changed slightly final plot to account for many planes
% imaged.
% NB WORKS ONLY IF FEW POIs AND 1-2 CELLS MAX IMAGED. LOOK AT Z PROJ,
% CANNOT HAVE ANY OVERLAPPING REGIONS IN Z

% in tracing, soma has to be marked as a different branch type (with neutube)

%% default inputs
if nargin < 3
    FrameSize=512;
end

if nargin <2
    OffsetRadius=2;
end

if nargin<1
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

% break apical dendrite in 2 equal parts: proximal and distal
[BranchesInfo, NodesInfo]=dissect_tree(SortedTree);
nnProx = find(NodesInfo(:,1) == 2 & NodesInfo(:,2)<0.5); % nodes in first half of apical dendrite
SortedTree.R(nnProx) = 3; % change type of proximal nodes
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

PointsPlaneNoZ = cell2mat(PointPlaneCorr');

%% determine which POIs are in which branch

%for each node compute distance with all POIs and find POIs closer than radius
[ PointsInSegmentsC ] = POIsInSegments_CirclesRIG3(PointsPlaneNoZ,SegmentCoor);

%for each node draw a polygon with subsequent node (if it is on the same plane) and look for POIs in that polygon
[ PointsInSegmentsP ] = POIsInSegments_PolygonsRIG3(PointsPlaneNoZ,SegmentCoor);

% merge POIs found in polygons and found in circles
[ PointsInSegments, POIsIn2Segm, POIsInNoSegm, SegmentsPerPOI ] = MergePOIsCirclesPolygonSoma( PointsInSegmentsC, PointsInSegmentsP, PointsInSegmentsC{1}', n_segments, PointPlaneCorr );
%% plot

figure;
%plot all POIs in black
plot(PointsPlaneNoZ(:,2),PointsPlaneNoZ(:,3),'k*','MarkerSize',2)
text(PointsPlaneNoZ(:,2),PointsPlaneNoZ(:,3), num2str(PointsPlaneNoZ(:,1)),'FontSize',6,'Color','black')
hold all
title('Z Projection')
xlim([1 FrameSize]), ylim([1 FrameSize])

%plot segment and POIs in each segment
ColorMat=jet(n_segments); %set colormap for segments and POIs in segments
for seg=1:n_segments
    
    %plot segments
    plot(SegmentCoor{1,seg}(:,1),SegmentCoor{1,seg}(:,2),'-','color', ColorMat(seg,:),'LineWidth',1.5)
    hold all
    
    %plot POIs in segments
    POIsInS= PointsInSegments{1,seg}; %get POIs in segment seg
    for p = 1:length(POIsInS)
        POIIndex = find(PointsPlaneNoZ(:,1) == POIsInS(p));
        plot(PointsPlaneNoZ(POIIndex,2), PointsPlaneNoZ(POIIndex,3),'o','color', ColorMat(seg,:),'MarkerSize',6)
        if isempty(find(POIsIn2Segm==POIsInS(p), 1))==0
            text(PointsPlaneNoZ(POIIndex,2), PointsPlaneNoZ(POIIndex,3), num2str(POIsInS(p)),'FontSize',10,'Color','red')
        end
        hold all
    end
end

% plot soma
PloTCircle(SortedTree.X(1), SortedTree.Y(1), SortedTree.D(1)/2);

%% save

Date=date;
%save figures
saveas(gcf,[PathExp '\PutPointsInDendrites5AndSoma' trees{1,1}.name '.fig'])
saveas(gcf-1,[PathExp '\DissectTree2' trees{1,1}.name '.fig'])
saveas(gcf-2,[PathExp '\DissectTree1' trees{1,1}.name '.fig'])

%save data
save(['PutPointsInDendrites5AndSoma' Date trees{1,1}.name '.mat'])

end

