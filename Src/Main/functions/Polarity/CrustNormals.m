function [V,MeanCurv] = CrustNormals(Centroids,varargin)

% Assign apico-basal polarity to segmented cells

% INPUT: Centroids - nx3 list of centroids for cells
% varargin - direction of polarity vector as character input; either 'in'
% or 'out'

% OUTPUT:
% V - nx3 list of polarity vectors
% MeanCurv - Mean curvature at apical surface of each cell


if ischar(varargin{1})
    poldir = varargin{1};
end

warning('off','all')

% Create mesh using Crust algorithm [Amenta et al 1998]
[F, V] = crust(Centroids);

% remove duplicates and unreferenced vertices
[Vnew, Fnew]=cleanpatch(V, F); 

%% Manifold extraction (w/ initial mesh refinement)

% refine mesh
[R,C,~] = circumradius(Vnew,Fnew);
Ifact = IntersectionFactor(Fnew,C,R);
tkeep = Walking(Vnew,Fnew,Ifact);
Fnew3 = Fnew(tkeep,:);

% detect and fill under-segmented regions
[boundaries] = detect_mesh_holes_and_boundary(Fnew3);
[T_out] = fill_mesh_holes(Vnew, Fnew3, boundaries, 'opened');

nholes = length(boundaries)-1;
if nholes>0
    warndlg(strcat(num2str(nholes),' holes detected in mesh. Beware of errors!'),...
    'Warning');
end

F3 = ManifoldExtraction(T_out,Vnew);

% flip vertice order to right hand rule
if isempty('poldir')
    Fnew3 = unifyMeshNormals(F3,Vnew,'alignTo','in');
else
    Fnew3 = unifyMeshNormals(F3,Vnew,'alignTo',poldir);
end
%Fnew3 = unifyMeshNormals(F3,Vnew,'alignTo','in');

% Define normal vectors
DT3 = triangulation(Fnew3,Vnew);
VN3 = vertexNormal(DT3);

%% Manifold extraction (w/o initial mesh refinement)

F2 = ManifoldExtraction(Fnew,Vnew);

% flip vertice order to right hand rule
if isempty(poldir)
    Fnew2 = unifyMeshNormals(F2,Vnew,'alignTo','in');
else
    Fnew2 = unifyMeshNormals(F2,Vnew,'alignTo',poldir);
end

% Define normal vectors
DT2 = triangulation(Fnew2,Vnew);
VN2 = vertexNormal(DT2);

%% Define normals

a = VN3(:,1) == 0;
V = zeros(size(Centroids)); 
V(1:length(VN3),:) = VN3;

p = Vnew(a,:);
pn = knnsearch(Vnew(~a,:),p,'K',7);
pp = knnsearch(Vnew,Vnew(~a,:),'K',1);
d = pp(pn);

f = find(a);

for jj = 1:size(f,1)
   vmean = mean(VN3(d(jj,:),:),1); 
   ang(jj) = atan2d(norm(cross(VN2(f(jj),:),vmean)),dot(VN2(f(jj),:),vmean));
   
   if ang>60
       V(f(jj),:) = -VN2(f(jj),:);
   else
       V(f(jj),:) = VN2(f(jj),:);
   end
end

%check and compute normals for any stray points
f2 = find(V(:,1)==0);

while ~isnan(f2)
    Idx = knnsearch(Centroids,Centroids(f2,:),'K',8);
    l = size(f2,1);
    for j = 1:l
        V(f2(j),:) = mean(V(Idx(j,2:8),:));
    end
    f2 = find(V(:,1)==0);
end

V = V./vecnorm(V,1,2);

if length(DT3.ConnectivityList)>length(DT3.Points)
    DT = DT3;
else
    DT = DT2;
end
    

%%
b = knnsearch(Vnew,Centroids);

%DTnew = triangulation(Fnew,Vnew);
MeanCurv = Curv(DT,V)';

MeanCurv = MeanCurv(b,:);
V = V(b,:);