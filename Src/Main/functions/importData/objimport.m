function [centroids,splitfv] = objimport(filedr)

% OBJIMPORT
% ------------
% 
% Import '.obj' files into MATLAB. Here all the objects are included in one
% mesh object. Split the mesh into distinct sub-regions (no connectivity)
% and find centroid of each sub-divided mesh.
% 
% SYNTAX
%      [CENTROIDS, SPLIT MESH] = OBJIMPORT(FILE DIRECTORY)   
%
%  INPUT: 
%  FILE DIRECTORY
% 
%  OUTPUTS: 
%  CENTROIDS: Centre of mass for each cell (split mesh). x*n 
%  matrix. x is the number of cells or segmented regions and n is the
%  number of image dimensions. - double
%  SPLIT MESH:  faces and vertices for each mesh object
% 
%  Author: Tania Mendonca
% =========================================================================


% Read .obj file exported from arivis
[vertices, faces] = readobjFaster(filedr);

% split the mesh into separate meshes (for each cell)
splitfv = splitFV(faces, vertices);

centroids = arrayfun(@(x) mean(x.vertices,1),splitfv,...
    'UniformOutput',false);
