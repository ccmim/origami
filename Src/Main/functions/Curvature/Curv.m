function MeanCurvature = Curv(DT,V)

% Classify cells by curvature

FN = faceNormal(DT);
FV.faces = DT.ConnectivityList;
FV.vertices = DT.Points;

% Get voronoi area
[Avertex,Acorner,up,vp]=VorA(FV,V);

% Get Curvature values at mesh
[~,VertexSFM,~]=CalcCurvature(FV,V,FN,Avertex,Acorner,up,vp);
[PrincipalCurvatures,~,~]=getPrincipalCurvatures(FV,...
    VertexSFM,up,vp);
MeanCurvature = (PrincipalCurvatures(1,:)+PrincipalCurvatures(2,:))./2;
