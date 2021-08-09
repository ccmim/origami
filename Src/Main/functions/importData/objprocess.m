function T = objprocess(filename)

% import '.obj' output from arivis, split meshes to individual cells and
% link with data table /generate data table from meshes.

wb = waitbar(0,'Importing File');
[centroids, splitfv] = objimport(filename);
[~, name, ~] = fileparts(filename);
waitbar(0.3,wb,'Meshes Imported');

[fname, pname] = uigetfile('*.xlsx', 'Get Data Table');

if fname==0                      % if data table not present then compute metrics from meshes
    warndlg('Extracting Volume and Surface Area from meshes - does not account for shrinkage at cell edges','Warning');
    BoundaryFacets = splitfv;
    c2 = cell2mat(centroids);
    Volume = arrayfun(@(h) meshVolume(h.vertices,h.faces),splitfv);
    SurfaceArea = arrayfun(@(h) meshSurfaceArea(h.vertices,h.faces),...
        splitfv);
    
    s1 = (6*Volume).^(2/3);
    s2 = pi^(1/3);
    Sphericity = (s2*s1)./SurfaceArea;
else
    waitbar(0.7,wb,'Reading Data Table');

    A = readtable([pname fname]); % read data table output from arivis 
    warning off MATLAB:table:ModifiedAndSavedVarnames
    if length(splitfv)~=size(A,1)
        errordlg('Data Table and Object file do not match','File Error');
        return
    end
    
    c1 = cell2mat(centroids);
    c2 = [A.X_CenterOfMass_Geometry___m_,...
        A.Y_CenterOfMass_Geometry___m_,...
        A.Z_CenterOfMass_Geometry___m_];
    
    cmatch = knnsearch(c1,c2); % closest point in c1 to c2
    
    for j = 1:size(A,1)
        BoundaryFacets(j,:) = splitfv(cmatch(j));
    end

    Volume = A.Volume_Volume__m__;
    SurfaceArea = A.SurfaceArea__m__;
    Sphericity = A.Sphericity;

end

bf = {BoundaryFacets.vertices};
bfmin = cell2mat(cellfun(@(h) min(h),bf,'un',0)');
bfmax = cell2mat(cellfun(@(h) max(h),bf,'un',0)');
BoundingBox = [bfmin,(bfmax-bfmin)];

waitbar(0.9,wb,'Generating Table');
T = table(BoundaryFacets,c2,BoundingBox,...
Volume,SurfaceArea,Sphericity,...
'VariableNames',{'BoundaryFacets','Centroid','BoundingBox'...
'Volume_um','SurfaceArea_um','Sphericity'});

close(wb)
