function  [alpha,tnorm2]=TriAngle2(p1,p2,p3,p4,planenorm)

test=sum(planenorm.*p4-planenorm.*p3);



%Computes angle between two triangles
v21=p1-p2;
v31=p3-p1;

tnorm1(1)=v21(2)*v31(3)-v21(3)*v31(2);%normali ai triangoli
tnorm1(2)=v21(3)*v31(1)-v21(1)*v31(3);
tnorm1(3)=v21(1)*v31(2)-v21(2)*v31(1);
tnorm1=tnorm1./norm(tnorm1);



v41=p4-p1;
tnorm2(1)=v21(2)*v41(3)-v21(3)*v41(2);%normali ai triangoli
tnorm2(2)=v21(3)*v41(1)-v21(1)*v41(3);
tnorm2(3)=v21(1)*v41(2)-v21(2)*v41(1);
tnorm2=tnorm2./norm(tnorm2);
alpha=tnorm1*tnorm2';%coseno dell'angolo
%il coseno considera l'angolo fra i sempipiani e non i traigoli, ci dice
%che i piani sono a 180 se alpha=-1 sono concordi se alpha=1, a 90°

alpha=acos(alpha);%trova l'angolo

%Se p4 sta sopra il piano l'angolo è quello giusto altrimenti va maggiorato
%di 2*(180-alpha);

if test<0%p4 sta sotto maggioriamo
   alpha=alpha+2*(pi-alpha);
end

%         fs=100;
%          cc2=(p1+p2+p3)/3;
%        quiver3(cc2(1),cc2(2),cc2(3),tnorm1(1)/fs,tnorm1(2)/fs,tnorm1(3)/fs,'m');
%        cc2=(p1+p2+p4)/3;
%               quiver3(cc2(1),cc2(2),cc2(3),tnorm2(1)/fs,tnorm2(2)/fs,tnorm2(3)/fs,'m');

%vediamo se dobbiamo cambiare l'orientazione del secondo triangolo
%per come le abbiamo calcolate ora tnorm1 t tnorm2 non rispettano
%l'orientamento
testor=sum(planenorm.*tnorm1);
if testor>0 
    tnorm2=-tnorm2;
end



end