function F = ManifoldExtraction(F_in,V_in)
%Given vertices and faces, buils a manifold surface with the ball pivoting
%method. Originally from MyCrustOpen by Luigi Giaccari - Surface
%Reconstruction from scattered points cloud (open surfaces)
%(https://www.mathworks.com/matlabcentral/fileexchange/63731-surface-
%reconstruction-from-scattered-points-cloud-open-surfaces), MATLAB Central
%File Exchange. 
%Edits and 

%% building the edgemap

numt = size(F_in,1);
vect = 1:numt;                                         % Triangle indices
e = [F_in(:,[1,2]); F_in(:,[2,3]); F_in(:,[3,1])];     % Edges - not unique
[e,~,j] = unique(sort(e,2),'rows');                    % Unique edges
te = [j(vect), j(vect+numt), j(vect+2*numt)];
nume = size(e,1);
e2t  = zeros(nume,2,'int32');

clear vect j
ne=size(e,1);
np=size(V_in,1);


count=zeros(ne,1,'int32');                             %no faces per edge
etmapc=zeros(ne,4,'int32');
for i=1:numt
    
    i1=te(i,1);
    i2=te(i,2);
    i3=te(i,3);
    
    
    
    etmapc(i1,1+count(i1))=i;
    etmapc(i2,1+count(i2))=i;
    etmapc(i3,1+count(i3))=i;
    
    
    count(i1)=count(i1)+1;
    count(i2)=count(i2)+1;
    count(i3)=count(i3)+1;
end

etmap=cell(ne,1);
for i=1:ne

    etmap{i,1}=etmapc(i,1:count(i));

end
clear  etmapc

tkeep=false(numt,1);                          %initialize list of faces


%Start

%building the queue to store edges 
efront=zeros(nume,1,'int32');                 %estimate length of the queue

%Intilize the front


tnorm=Tnorm(V_in,F_in);                       %get face normals

%find the face with the last position (centres of all the faces)
[foo,t1]=max( (V_in(F_in(:,1),3)+V_in(F_in(:,2),3)+V_in(F_in(:,3),3))/3);

if tnorm(t1,3)<0
    tnorm(t1,:)=-tnorm(t1,:);                 %points up
end

% ray tracing to check if the triangle face points up.
% The other triangles can be found by knowing that if a
% triangle has the highest center of gravity surely contains the point
%higher. All traings containing this must be analyzed
%point


tkeep(t1)=true;                               %first selected triangle face
efront(1:3)=te(t1,1:3);
e2t(te(t1,1:3),1)=t1;
nf=3;                                         %interation no


while nf>0                                    %(why not for loop?)
    
    
    k=efront(nf);                             %ID edge in front

    if e2t(k,2)>0 || e2t(k,1)<1 || count(k)<2 %edge is no more on front or it has no candidates triangles

        nf=nf-1;
        continue                              %skip
    end
  
   
    %candidate triangles
    idtcandidate=etmap{k,1};
    
    
    t1=e2t(k,1);                              %triangle we come from
    
   
        
    %get data structure
%        p1
%       / | \
%  t1 p3  e1  p4 t2(idt)
%       \ | /  
%        p2
alphamin=inf;                                 %initiate
ttemp=F_in(t1,:);
etemp=e(k,:);
p1=etemp(1);
p2=etemp(2);
p3=ttemp(ttemp~=p1 & ttemp~=p2);              %third point ID


%plot for debug purpose
%          close all
%          figure(1)
%          axis equal
%          hold on
%          
%          fs=100;
%         
%          cc1=(p(t(t1,1),:)+p(t(t1,2),:)+p(t(t1,3),:))/3;
%          
%          trisurf(t(t1,:),p(:,1),p(:,2),p(:,3))
%          quiver3(cc1(1),cc1(2),cc1(3),tnorm(t1,1)/fs,tnorm(t1,2)/fs,tnorm(t1,3)/fs,'b');
%                 
       for i=1:length(idtcandidate)
               t2=idtcandidate(i);
               if t2==t1;continue;end;
                
               %debug
%                cc2=(p(t(t2,1),:)+p(t(t2,2),:)+p(t(t2,3),:))/3;
%          
%                 trisurf(t(t2,:),p(:,1),p(:,2),p(:,3))
%                 quiver3(cc2(1),cc2(2),cc2(3),tnorm(t2,1)/fs,tnorm(t2,2)/fs,tnorm(t2,3)/fs,'r');
%                
%                

               
                ttemp=F_in(t2,:);
                p4=ttemp(ttemp~=p1 & ttemp~=p2);%terzo id punto
        
   
                %calcola l'angolo fra i triangoli e prendi il minimo
              
                
                [alpha,tnorm2]=TriAngle2(V_in(p1,:),V_in(p2,:),V_in(p3,:),V_in(p4,:),tnorm(t1,:));
                
                if alpha<alphamin
                    
                    alphamin=alpha;
                    idt=t2;  
                    tnorm(t2,:)=tnorm2;%ripristina orientazione   
                     
                    %debug
%                      quiver3(cc2(1),cc2(2),cc2(3),tnorm(t2,1)/fs,tnorm(t2,2)/fs,tnorm(t2,3)/fs,'c');
                    
                end
                %in futuro considerare di scartare i trianoli con angoli troppi bassi che
                %possono essere degeneri
                
       end


   
   
    
    
   %update front according to idttriangle
          tkeep(idt)=true;
        for j=1:3
            ide=te(idt,j);
           
            if e2t(ide,1)<1% %Is it the first triangle for the current edge?
                efront(nf)=ide;
                nf=nf+1;
                e2t(ide,1)=idt;
            else                     %no, it is the second one
                efront(nf)=ide;
                nf=nf+1;
                e2t(ide,2)=idt;
            end
        end
        
     
        

         nf=nf-1;%per evitare di scappare avanti nella coda e trovare uno zero
end
F = F_in(tkeep,:);
end
