% =========================================================================
%     ???????               ???                                      ??? 
%   ???????????            ???                                      ???  
%  ???     ????? ????????  ????   ???????  ??????   ?????????????   ???? 
% ????      ???????????????????  ???????? ???????? ??????????????? ????? 
% ????      ???? ???? ???  ???? ???? ????  ???????  ???? ???? ????  ???? 
% ?????     ???  ????      ???? ???? ???? ????????  ???? ???? ????  ???? 
%  ???????????   ?????     ???????????????????????? ????????? ????? ?????
%    ???????    ?????     ?????  ???????? ???????? ????? ??? ????? ????? 
%                                ??? ????                                
%                               ????????                                 
%                                ??????                                  
%
% =========================================================================
% Pipeline for computing cell shape indices from folding epithelia.
% Pipeline accepts output from segmentation sotware - '.mha' or '.tif'
% files (from ACME) or '.obj' files (from arivis). The pipeline also
% accepts '.mat' files - saved output from object clearing step in the ACME
% (single file) workflow.
% 
% Pipeline was developed for cropped image sub-regions.
%
% Pipeline Steps: (1) Clear objects - user interaction: delete false
%                 positives and noise. (2) Set polarity vectors - user
%                 interaction: apply correction step if needed. (3) Compute
%                 skewness - user interaction: none (4) Classify cells -
%                 user interaction: labels are set as 'Group 1' or 'Group
%                 2'. Default label is 'Group 2'. (5) Export results. (6)
%                 Plot objects by property.
%
% Output is a excel file ('.xslx' or '.csv') containing the following
% variables: Volume, Surface Area, Sphericity, Skewness, Longitudinal
% Extent and Transversal Extent, Polarity and Mean Curvature at apical
% surface. Pipeline also prompts user at regular intervals to
% save intermediate results as '.mat' files. These can be reimported into
% the pipeline at a later time.
%
% Click |Run| to run the entire pipeline or |Run and Advance| to run
% specific sections.
%
% Publication: 'Origami: Single-cell oriented 3D shape dynamics of folding
% epithelia from fluorescence microscopy images'
%
% Author: Tania Mendonca
% University of Sheffield
% Date: 20/10/2018
%
% Copyright © 2021, University of Sheffield & University of Leeds
% GNU General Public License
% =========================================================================

clear all; close all;

% Import File
[filename,pathname] = uigetfile({'*.mha';'*.tif';'*.obj';'*.mat'},...
    'Select file to import');
filename = [pathname filename];
[~,name,ext] = fileparts(filename);

exstrng = {'.mha';'.tif';'.obj';'.mat'};
cmp = find(strcmp(exstrng,ext));


if cmp<=2                                         % if '.mha' or '.tif' 
    [img,info,T,~,PxlDim] = imgprocess(filename,cmp);
elseif cmp==3                                     % if '.obj'
    T = objprocess(filename); 
elseif cmp==4                                     % if '.mat' 
    load(filename); 
    if ~exist('T')&& exist('A')
        [T, PxlDim] = resulttable(A);
    end
else                     
    error('File type not recognised. Pipeline exited');
    return
end
    
 
a = [];H = T; T2 = [];

% exclude false positives
clearobjects(T,name);
uiwait

%% compute polarity vectors
wb = waitbar(0.3,'Computing Polarity Vectors');

poldir = questdlg('Polarity Vector Direction', ...
'Assign Apico-Basal Polarity', ...
'in','out','in');

[V,MeanCurv] = CrustNormals(T.Centroid,poldir);
T.Polarity = V;
T.MeanCurvature = MeanCurv;

a = [];H = T; T2 = [];
polarityvector(T,name, poldir);                          % assess polarity vectors
uiwait

%% compute geometric descriptors (volume, longitudinal and tranverse spread, skewness, shear)
if exist('wb')
    waitbar(0.7,wb,'Computing Geometric Descriptors');
else
    wb = waitbar(0.7,'Computing Geometric Descriptors');
end

if exist('PxlDim')
    T = AddGeometricDescriptors(T,PxlDim);  
else
    T = AddGeometricDescriptors(T);
end

%% group objects
T = removeboundarycells(T);                      % exclude objects cut off at 
h = msgbox('Boundary Cells Excluded'); waitfor(h); % the boundaries of the ROI

classify = questdlg('Classify cells by curvature?', ...
'Classify cells', ...
'yes','no','yes');

if contains(classify,'yes')
   
    if exist('wb')
        waitbar(0.9,wb,'Setting Groups');
    else
        wb = waitbar(0.9,'Setting Groups');
    end
    
    E = T;                                           % Backup table as variable 'E'
    T.Group = cell(size(T,1),1);
    T = SetGroup(T);                            % isolate cells from structure
    
    a = [];H = T; T2 = [];
    groupobjects(T,name);                          % manually set cell groups
    uiwait

end

%% Export excel file
t = T; t.BoundaryFacets = [];
filter = {'*.xlsx';'*.csv'};
[file,path] = uiputfile(filter,'Save Excel File',name);

if file~=0
    writetable(t,fullfile(path,file));
end

%% visualise
% Select and view individual cells
if exist('wb')
    waitbar(1.0,wb,'Visualise cell properties');
else
    wb = waitbar(1.0,'Visualise cell properties');
end
close(wb);
selectAcell(T);uiwait

% Generate plots by property
plotbyproperty2(T);                              


