function [Avertex,Acorner,up,vp]=VorA(FV,V)
%% Summary
%Author: Itzik Ben Shabat
%Last Update: July 2014
% 
% summary: VorA calculates the voronoi areas at each vertex
% INPUT:
% FV - triangle mesh in face vertex structure
% V - vertex normals
% OUTPUT -
% Avertex - [NvX1] voronoi area at each vertex
% Acorner - [NfX3] slice of the voronoi area at each face corner
%% Code

% Get edge vectors
e0=FV.vertices(FV.faces(:,3),:)-FV.vertices(FV.faces(:,2),:);
e1=FV.vertices(FV.faces(:,1),:)-FV.vertices(FV.faces(:,3),:);
e2=FV.vertices(FV.faces(:,2),:)-FV.vertices(FV.faces(:,1),:);

% Unit edge vectors
e0_norm=e0./vecnorm(e0,1,2);
e1_norm=e1./vecnorm(e1,1,2);
e2_norm=e2./vecnorm(e2,1,2);

%edge lengths
de0=sqrt(e0(:,1).^2+e0(:,2).^2+e0(:,3).^2);
de1=sqrt(e1(:,1).^2+e1(:,2).^2+e1(:,3).^2);
de2=sqrt(e2(:,1).^2+e2(:,2).^2+e2(:,3).^2);
l2=[de0.^2 de1.^2 de2.^2];

%using ew to calulate the cot of the angles for the voronoi area
%calculation. ew is the triangle barycenter
ew=[l2(:,1).*(l2(:,2)+l2(:,3)-l2(:,1)) l2(:,2).*(l2(:,3)+l2(:,1)-l2(:,2)) l2(:,3).*(l2(:,1)+l2(:,2)-l2(:,3))];
s=(de0+de1+de2)/2;

%Af - face area vector
Af=sqrt(s.*(s-de0).*(s-de1).*(s-de2));%herons formula for triangle area

%calculate weights
Acorner=zeros(size(FV.faces,1),3);
Avertex=zeros(size(FV.vertices,1),1);

% Calculate voronoi area
up=zeros([size(FV.vertices,1) 3]);
vp=zeros([size(FV.vertices,1) 3]);
for i=1:size(FV.faces,1)
    %Calculate areas for weights according to Meyer et al. [2002]
    %check if the tringle is obtuse, right or acute
    
    if ew(i,1)<=0
        Acorner(i,2)=-0.25*l2(i,3)*Af(i)/(e0(i,:)*e2(i,:)');
        Acorner(i,3)=-0.25*l2(i,2)*Af(i)/(e0(i,:)*e1(i,:)');
        Acorner(i,1)=Af(i)-Acorner(i,2)-Acorner(i,3);
    elseif ew(i,2)<=0
        Acorner(i,3)=-0.25*l2(i,1)*Af(i)/(e1(i,:)*e0(i,:)');
        Acorner(i,1)=-0.25*l2(i,3)*Af(i)/(e1(i,:)*e2(i,:)');
        Acorner(i,2)=Af(i)-Acorner(i,1)-Acorner(i,3);
    elseif ew(i,3)<=0
        Acorner(i,1)=-0.25*l2(i,2)*Af(i)/(e2(i,:)*e1(i,:)');
        Acorner(i,2)=-0.25*l2(i,1)*Af(i)/(e2(i,:)*e0(i,:)');
        Acorner(i,3)=Af(i)-Acorner(i,1)-Acorner(i,2);
    else
        ewscale=0.5*Af(i)/(ew(i,1)+ew(i,2)+ew(i,3));
        Acorner(i,1)=ewscale*(ew(i,2)+ew(i,3));
        Acorner(i,2)=ewscale*(ew(i,1)+ew(i,3));
        Acorner(i,3)=ewscale*(ew(i,2)+ew(i,1));
    end
    Avertex(FV.faces(i,1))=Avertex(FV.faces(i,1))+Acorner(i,1);
    Avertex(FV.faces(i,2))=Avertex(FV.faces(i,2))+Acorner(i,2);
    Avertex(FV.faces(i,3))=Avertex(FV.faces(i,3))+Acorner(i,3);
    
    %Calculate initial coordinate system
    up(FV.faces(i,1),:)=e2_norm(i,:);
    up(FV.faces(i,2),:)=e0_norm(i,:);
    up(FV.faces(i,3),:)=e1_norm(i,:);
end

%Calculate initial vertex coordinate system
for i=1:size(FV.vertices,1)
    up(i,:)=cross(up(i,:),V(i,:));
    up(i,:)=up(i,:)/norm(up(i,:));
    vp(i,:)=cross(V(i,:),up(i,:));
end

end