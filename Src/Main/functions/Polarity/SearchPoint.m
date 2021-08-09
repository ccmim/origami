function [sp,sr]=SearchPoint(p1,p2,p3)
%Gets a point outside a given edge of triangle that forms an equilater
%triangle.
%P1,P2,P3 are all Nx3 arrays
%This is the orientation for points
%    p1
%   / | \
% p3  |  SP
%   \ | /
%    p2

%NOTA
%perchè il search point sia all'esterno del triangolo
%p1 p2 devono essere il punto del lato in cui generare il search p
v21=p1-p2;
v31=p3-p1;

n1=[v21(:,2).*v31(:,3)-v21(:,3).*v31(:,2),...
    v21(:,3).*v31(:,1)-v21(:,1).*v31(:,3),...
    v21(:,1).*v31(:,2)-v21(:,2).*v31(:,1)];%normale ai triangoli



v31=n1;

cosdir=[v21(:,2).*v31(:,3)-v21(:,3).*v31(:,2),...
    v21(:,3).*v31(:,1)-v21(:,1).*v31(:,3),...
    v21(:,1).*v31(:,2)-v21(:,2).*v31(:,1)];%coseni direttori retta
cosdir=cosdir/norm(cosdir);
pm=(p1+p2)*.5;
lenge=norm(p1-p2);

% r=max([lenge,norm(p1-p3),norm(p3-p2)]);

% sp=pm+(cosdir)*(sqrt(r^2-.25*lenge^2));%Search point
sp=pm+(cosdir)*(lenge*.866);%Search point


%search radius più è grande più saranno i triangoli scandagliati

% sr=(lenge+norm(p1-p3)+norm(p2-p2))/3;
% sr=r;
sr=lenge;
% sr=max([lenge,norm(p1-p3),norm(p3-p2)]);
end