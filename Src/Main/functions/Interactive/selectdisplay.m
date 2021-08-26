function selectdisplay(T,pol)

if(exist('pol','var')==0)
    pol = false;
else
    validateattributes(pol, {'logical'},{'scalar'});
end

if ~ismember('Polarity',T.Properties.VariableNames)
    pol = false;
end

for kk = 1:length(T.Centroid)
    patch(T.BoundaryFacets(kk),'facecolor',rand(1,3),'edgecolor','none',...
        'facealpha',0.3)
end
axis off equal
hold on

if(pol)
    quiver3(T.Centroid(:,1),T.Centroid(:,2),T.Centroid(:,3),...
            T.Polarity(:,1),T.Polarity(:,2),T.Polarity(:,3),'b');   
end

a = [];
h = clickA3DPoint(T);