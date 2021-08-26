% =========================================================================
% -------------------
% Generate Synthetic Epithelia (Part I): Generate raw image volumes
% -------------------
%
% Script to generate synthetic images of membrane-labelled epithelia with
% parameters to control curvature of epithelium and folding extent
%
% Publication: 'Origami: Single-cell oriented 3D shape dynamics of folding
% epithelia from fluorescence microscopy images'
%
% Author: Tania Mendonca
% University of Sheffield
%
% Copyright © 2021, University of Sheffield & University of Leeds
% GNU General Public License
% =========================================================================
%% Initiate cell centres

% surface mesh
x = -4:0.4:4;
y = -4:0.4:4;
[X,Y] = meshgrid(x,y);

crv = 5; %[5; 20; 80];                          %curvature of membrane
pk = 5; %[5; 10; 15];                           %peak height

Z = sqrt(abs(crv+X.^2+Y.^2))- pk*(X/5 - X.^3 - Y.^5).*exp(-X.^2-5*Y.^2);

f = [X(:),Y(:)];

% generate cell centroids
r = initiateCells(324,0.3);
g = knnsearch(f,r,'K',1);
e = Z(:); e = e(g,:);
   
c = [round(((r(:,1)+3.5).*100)+25),...
    ((r(:,2)+3.5).*100)+25,...
    round((e+4).*100)];

%% generate image volume
xm = -4:0.01:4;                             %fine grid
ym = -4:0.01:4;

[Xm, Ym] = meshgrid(xm,ym);
Zm = interp2(X,Y,Z,Xm,Ym);

p = [Xm(:), Ym(:), Zm(:)];                   

% points in epithelium volume on fine grid
for j = 1:100
    p2 = [Xm(:), Ym(:), Zm(:)+(j*0.01)];
    p22 = [Xm(:), Ym(:), Zm(:)-(j*0.01)];
    p = [p; p2; p22];
end

% rescale grid to pixels - 0.2um/pxl  
P = [round(((p(:,1)+4).*100)+1),...
    round((p(:,2)+4).*100)+1,...
    round(((p(:,3)+4).*100))+1];

% define cells using voronoi diagram
[vov, voc] = voronoin(c(:,1:2));
vov2 = round(vov);
gg1 = vov2<0;gg2 = vov2>750& vov2<inf;
vov2(gg1) = 0; vov2(gg2) = 750;

n = knnsearch(P(:,1:2),vov2(:,1:2),'K',1);
vov2(:,3) = P(n,3);

[vx, vy, vz] = surfnorm(Xm,Ym, Zm);
VN = [vx(:), vy(:), vz(:)];
vn = VN(n,:);

clear p p2 p22 VN vx vy vz

%% define membranes for each cell

A = false(length(P), 1);

for l = 1:size(voc,1)
    
    %if length(voc{l})>=4
    
    m = vov2(voc{l},:);
    mvn = vn(voc{l},:);
    
    if isfinite(m)
        
        mup1 = round(m + (mvn.*14));
        mup2 = round(m + (mvn.*13));
        mdn1 = round(m - (mvn.*14));
        mdn2 = round(m - (mvn.*13));
        
        pd = mean(pdist(m));
        t{1} = alphaShape([mup1;mup2]);
        if isfinite(t{1}.Alpha)
            t{1}.Alpha = 2*mean(pdist(mup1));
            a{1} = inShape(t{1},P);
            g(l,1) = isempty(find(a{1})); 
        end
        
        
        t{2} = alphaShape([mdn1;mdn2]);
        if isfinite(t{2}.Alpha)
            t{2}.Alpha = 2*mean(pdist(mdn1));
            a{2} = inShape(t{2},P);
            g(l,2) = isempty(find(a{1})); 
        end
        
        A = A|a{1}|a{2};
        
        
        for j = 1:length(voc{l})
            if j == length(voc{l})
                mem = [mup1(j,:);mup1(1,:);mdn1(1,:);mdn1(j,:)];
                mm = mem-mean(mem);[~,~,W]=svd(mm,0);
                nmm=W(:,end);
                mem2 = round(mem + (nmm.*1)');
                t{2+j} = alphaShape([mem;mem2]);
                %if length(t{2+j}.Points) >= 8
                    if isfinite(t{2+j}.Alpha)
                        t{2+j}.Alpha = 2*mean(pdist(mem));
                        a{2+j} = inShape(t{2+j},P);
                        A = A|a{2+j};
                    end
                %end
            else
                mem = [mup1(j,:);mup1(j+1,:);mdn1(j+1,:);mdn1(j,:)];
                mm = mem-mean(mem);[~,~,W]=svd(mm,0);
                nmm=W(:,end);
                mem2 = round(mem + (nmm.*1)');
                t{2+j} = alphaShape([mem;mem2]);
                    if isfinite(t{2+j}.Alpha)
                        t{2+j}.Alpha = 2*mean(pdist(mem));
                        a{2+j} = inShape(t{2+j},P);
                        A = A|a{2+j};
                    end
            end
            
           % A = A|a{2+j};
        end
        
    end
    a = {}; t = {};
end
%end


%% populate image
B = double(A);
I = zeros(800,800,800);

for j = 1:length(P)
    I(P(j,2),P(j,1),P(j,3)) = B(j);
end

% save as .mat file
uisave({'I'},'Similuated_Image');