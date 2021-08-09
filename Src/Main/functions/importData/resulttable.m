function [T,PxlDim] = resulttable(A,varargin)

% Generate cell-specific result table 

if nargin>1
    PxlDim = varargin{1};
else
    prompt = {'X pixel resolution (µm/pxl)','Y pixel resolution (µm/pxl)',...
        'Z pixel resolution (µm/pxl)'};
    dlgtitle = 'Pixel Resolution';
    dims = [1 35];
    definput = {'1','1','1'};
    PxlDim = cell2mat(cellfun(@(x) str2num(x),...
        inputdlg(prompt,dlgtitle,dims,definput),'UniformOutput', false));
end

for j = 1:size(A,1)
    verts = A.BoundaryFacets(j).vertices;
    umverts = verts.*repmat(PxlDim',size(verts,1),1);
    Volume_um(j,1) = meshVolume(umverts,A.BoundaryFacets(j).faces);
    SurfaceArea_um(j,1) = meshSurfaceArea(umverts,A.BoundaryFacets(j).faces);
end

%Volume_um = A.Volume.*prod(PxlDim); 

%SurfaceArea_um = A.SurfaceArea.*(PxlDim(1))^2;
s1 = (6*Volume_um).^(2/3);
s2 = pi^(1/3);
Sphericity = (s2*s1)./SurfaceArea_um;

%Cent = A.Centroid.*repmat(PxlDim',size(A,1),1);

T = table(A.BoundaryFacets,A.Centroid,A.BoundingBox,...
Volume_um,SurfaceArea_um,Sphericity,...
'VariableNames',{'BoundaryFacets','Centroid','BoundingBox'...
'Volume_um','SurfaceArea_um','Sphericity'});

