% =========================================================================
% --------------------------------------
% Select a cell - display its properties
% --------------------------------------
% Zebrafish Inner Ear Project
%
% Select and view properties for individual objects.
% 
% Input: '.obj'+'.xlsx' or '.mat' (output from Pipeline.m)
% Output: GUI with (1) 3D plot of selectable cells 
%                  (2) table of stats for selected cell
%                  (3) 3D rendering of single selected cell with polarity
%                      vector
%
% Selections are denoted by red centroid colour. The stats and the single
% cell view image can be exported.
%
% Author: Tania Mendonca
% Date: 20/10/2018
% =========================================================================
% Import File
[filename,pathname] = uigetfile({'*.obj';'*.mat'},...
'Select file to import');
wb = waitbar(0, 'Importing File');

filename = [pathname filename];
[~,name,ext] = fileparts(filename);

% check if file is .obj or .mat
exstrng = {'.obj';'.mat'};                       
cmp = find(strcmp(exstrng,ext));

if cmp==1                                         % if '.obj'
    waitbar(0.2,wb,'Importing Meshes');
    [centroids, splitfv] = objimport(filename);
    [~, name, ~] = fileparts(filename);
    waitbar(0.4,wb,'Meshes Imported');
    
    [fname, pname] = uigetfile('*.xlsx', 'Get Data Table');
    if fname==0
        errordlg('No data table selected','File Error'); 
        close(wb);
        return
    else
    
    waitbar(0.7,wb,'Reading Data Table');
    T = readtable([pname fname]);    % read data table output from arivis 
    warning off MATLAB:table:ModifiedAndSavedVarnames
    if length(splitfv)~=size(T,1)    % check if excel file matches the mesh file
        errordlg('Data Table and Object file do not match','File Error');
        close(wb); 
        return
    end
    
    % match the meshes to their properties in the excel file
    c01 = cell2mat(centroids);
    c02 = [T.X_CenterOfMass_Geometry___m_,...
        T.Y_CenterOfMass_Geometry___m_,...
        T.Z_CenterOfMass_Geometry___m_];
    
    cmatch = knnsearch(c01,c02); % closest point in c1 to c2

    for j = 1:size(T,1)
        T.BoundaryFacets(j,:) = splitfv(cmatch(j));
    end
    
    T.Centroid = c02;
    end
    
elseif cmp==2                                     % if '.mat' 
    waitbar(0.7,wb,'Reading Data Table');
    load(filename); 
else                     
    errordlg('File type not recognised. Pipeline exited');
    close(wb);
    return
end

waitbar(0.9,wb,'Generating Plot');
close(wb);

selectAcell(T)