function [centreMass, centreBBox, props] = imstats(imgB)

% INSTATS
% ------------
%  Find coordinates of centre of mass and centre of bounding box for each
%  cell in the segmented image. Regionprops results are also included in
%  output.
%  
% SYNTAX
%      CENTRE OF MASS = CENTRE(IMGB)  
%      [CENTRE OF MASS, CENTRE OF BOUNDING BOX] = CENTRE(IMGB)   
%      [CENTRE OF MASS, CENTRE OF BOUNDING BOX, REGION PROPERTIES (3D)] = 
%                       CENTRE(IMGB)   
%
%  INPUT: 
%  IMGB: Binarised Image Volume (2D/3D) - logical
%
%  OUTPUTS: 
%  CENTRE OF MASS: Centre of mass for each cell (segmented region). x*n 
%  matrix. x is the number of cells or segmented regions and n is the
%  number of image dimensions. - double
%
%  CENTRE OF BOUNDING BOX: Centre of the smallest possible box that can be
%  defined around each cell (segmented region). x*n matrix. x is the number
%  of cells or segmented regions and n is the number of image dimensions. -
%  double
%
%  REGION PROPERTIES (2D/3D): A table of the statistical properties for 
%  each cell (segmented region) - table
%   
%==========================================================================

% Get region properties
stats = regionprops3(imgB,'all');

% remove NaNs and noise 
props = rmmissing(stats);

A = cellfun(@ndims,props.Image);                % remove any 2D selections
toDelete = A < 3;
props(toDelete,:) = [];

% Define vairables
centreMass = props.Centroid;

% find centre of bounding box for each cell
sx = cellfun(@median,props.SubarrayIdx(:,2));
sy = cellfun(@median,props.SubarrayIdx(:,1));
sz = cellfun(@median,props.SubarrayIdx(:,3));

centreBBox = [sx, sy, sz];

end