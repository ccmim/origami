function clearobjects(T,name)

% interactively delete objects 

figure('Name','Clear Objects','NumberTitle','off');

H = T;
T2 =[];
a = [];
%name = evalin('base','name',name):

c1 = uicontrol('String','Delete Selections','Position',[50 20 100 30]);
c1.Callback = {@deleteButtonPushed,T,a};

c2 = uicontrol('String','Undo','Position',[150 20 100 30]);
c2.Callback = {@revertButtonPushed,T,T2,H};

c3 = uicontrol('String','Finish','Position',[250 20 100 30]);
c3.Callback = {@finishButtonPushed,T,name};

selectdisplay(T)

end