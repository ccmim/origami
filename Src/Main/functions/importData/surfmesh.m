function fv = surfmesh(VoxelList,wb)

% SURFMESH
% ------------
%  Generate surface mesh for each segmented object in regionprops3 output
%  table. Script uses voxel list to generate alphashapes and then
%  boundary facets. 
%  
% SYNTAX
%      FV = SURFMESH(REGIONPROPS3 TABLE)  
%
%  INPUT: 
%  REGIONPROPS3 TABLE: Table of stats for each segmented object. 
%
%  OUTPUTS: 
%  FV: Structure containing faces and vertices of surface mesh
%  
%  Author: Tania Mendonca
%==========================================================================
% wb = waitbar(0,'Generating Surface Meshes');
n = length(VoxelList);
shp = {};fv = {};

for j = 1:n
    waitbar(0.4+(j/(n*0.5)),wb)
    shp{j} = alphaShape(VoxelList{j}(:,1),VoxelList{j}(:,2),...
        VoxelList{j}(:,3));
    [abf, abv] = boundaryFacets(shp{j});
    fv{j}.faces = abf;
    fv{j}.vertices = abv;
end

% close(wb)

end