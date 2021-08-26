function polarityvector(T,name,poldir)

%------------------------------
% interactively assess polarity
%------------------------------

H = T;
T2 =[];
a = [];

figure('Name',name,'NumberTitle','off');

%name = evalin('base','name',name):

c1 = uicontrol('String',strcat('Direction: ',poldir),'Position',[50 20 100 30]);
c1.Callback = {@flipall,T};

c2 = uicontrol('String','Flip Selection','Position',[150 20 100 30]);
c2.Callback = {@flipButtonPushed,T,a};

c3 = uicontrol('String','Undo','Position',[250 20 100 30]);
c3.Callback = {@revertButtonPushed,T,T2,H,true};

c4 = uicontrol('String','Finish','Position',[350 20 100 30]);
c4.Callback = {@finishButtonPushed,T,name};

selectdisplay(T,true)
end