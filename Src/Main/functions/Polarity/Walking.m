function tkeep=Walking(p,t,Ifact)

%Buils a manifolds surface from the survivors triangles
% Adapted from MyCrustOpen, Giaccari Luigi


% building the etmap (edge map)

numt = size(t,1);
vect = 1:numt;                                                             % Triangle indices
e = [t(:,[1,2]); t(:,[2,3]); t(:,[3,1])];                                  % Edges - not unique
[e,j,j] = unique(sort(e,2),'rows');                                        % Unique edges
te = [j(vect), j(vect+numt), j(vect+2*numt)];
nume = size(e,1);
e2t  = zeros(nume,2,'int32');

clear vect j
ne=size(e,1);
np=size(p,1);


count=zeros(ne,1,'int32');%numero di triangoli candidati per edge
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







tkeep=false(numt,1);%all'inizio nessun trinagolo selezionato


%Start the front

%we pick all triangles which are linked to a dual edge, the must be flat , not
%self-intersecant and more they need to have low intersection factor

% [q]=Quality3(p,t);%triangle quality
pchecked=false(np,1);


%building the queue to store edges on front that need to be studied
efront=zeros(nume*2,1,'int32');%exstimate length of the queue

iterf=1;%efront iterator
nf=0;%numbers of edges on front

% figure(4)
% hold on
% axis equal
% title('Ifactor')
% trisurf(t,p(:,1),p(:,2),p(:,3),Ifact);
% colorbar


%we choose The 1%triangles with lowest Ifact
[is,index]=sort(Ifact);

%start the front with good Ifact triangles
for i=1:numt
  

        %triangles on boundary
        t1=index(i);
        if Ifact(t1)>-0.8
            break
        end

        if not(any(pchecked(t(t1,:))))  && Ifact(t1)<-0.8 
            tkeep(t1)=true;%primo triangolo selezionato
            pchecked(t(t1,:))=true;
            efront(nf+1:nf+3)=te(t1,1:3);
            e2t(te(t1,1:3),1)=t1;
            nf=nf+3;
        end
    
end


% figure(10)
% axis equal
% hold on
% trisurf(t(tkeep,:),p(:,1),p(:,2),p(:,3));

clear pchecked is index
if nf==0
    error('Front do not start please send a report to the author')
end

while iterf<=nf


    k=efront(iterf);%id edge on front

    if e2t(k,2)>0 || e2t(k,1)<1 || count(k)<2 %edge is no more on front or it has no candidates triangles

        iterf=iterf+1;
        continue %skip
    end
  
    %candidate triangles
    idtcandidate=etmap{k,1};
    idtcandidate(idtcandidate==e2t(k,1))=[];%remove the triangle we come from

    if isempty(idtcandidate)
        iterf=iterf+1;
        continue%skip
    end

  
    %Get Search point and Search radius
    
    ttemp=t(e2t(k,1),:);
    etemp=e(k,:);
    pt=ttemp(ttemp~=etemp(1) & ttemp~=etemp(2));%opposite point to the edge we are studying
     [sp,sr]=SearchPoint(p(e(k,1),:),p(e(k,2),:),p(pt,:));


   dist=0;
    idp=0;
    for c=1:length(idtcandidate)
        ttemp=t(idtcandidate(c),:);
        etemp=e(k,:);
        idp=ttemp(ttemp~=etemp(1) & ttemp~=etemp(2));
        dist(c)=sum((sp-p(idp,:)).^2);%dopo provare a eliminare i punti fuori dal search radius

    end

    ind=dist>sr*sr;
    idtcandidate(ind)=[];
    if isempty(idtcandidate)
        iterf=iterf+1;
        continue
    else
        dist(ind)=[];
    end


%     [dist,id]=sort(L(idtcandidate));%sort per cominciare dal più probabile
%       [dist,id]=sort(dist);%sort per cominciare dal più probabile
      [dist,id]=sort(Ifact(idtcandidate));%sort per cominciare dal più probabile
    idtcandidate=idtcandidate(id);

    %Now we analyze candidate triangles
    
    
    %% Check conformity
    for c=1:length(idtcandidate)

        idt=idtcandidate(c);
        conformity=true;%initilize to true


        %loop trough all edges of the triangle
        for ii=1:3
            e1=te(idt,ii);

            if e2t(e1,2)>0 && e1~=k
                %edge with two trianlgle
                conformity=false;
                break
            elseif e2t(e1,1)>0
                
                %the edge has only one triangle let's see if we can add
                %this one
                
                %get points from the triangles
                t1=e2t(e1,1);t2=idt;
                ttemp=t(t1,:);
                etemp=e(e1,:);
                pt1=ttemp(ttemp~=etemp(1) & ttemp~=etemp(2));%terzo id punto
                ttemp=t(t2,:);
                pt2=ttemp(ttemp~=etemp(1) & ttemp~=etemp(2));%terzo id punto

                [alpha]=TriAngle(p(e(e1,1),:),p(e(e1,2),:),p(pt1,:),p(pt2,:));%angle between triangles
                if alpha>.5
                    conformity=false;%the angle between the traingles was to small
                    break
                end
            end


        end


        if conformity
            break %exit loop if a good triangle has been found
        end


    end

    %Did we found a good triangle?
    if conformity





        %update connectivity data for new triangle
        
        idt=idtcandidate(c);%id of new triangle
        
        tkeep(idt)=true;%keep ot

        %update e2t
        e2t(k,2)=idt;
        %update e2t for the others edges 
        for j=1:3
            ide=te(idt,j);
           
            if e2t(ide,1)<1% %Is it the first triangle for the current edge?
                efront(nf+1)=ide;
                nf=nf+1;
                e2t(ide,1)=idt;
            else                     %no, it is the second one
                efront(nf+1)=ide;
                nf=nf+1;
                e2t(ide,2)=idt;
            end
        end
    end



    iterf=iterf+1;%increase queue iterator






end





%fprintf('\tFinal size of the queue is %4.0f edges were %4.0f \n',nf,nume)
%




end