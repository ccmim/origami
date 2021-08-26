function groupobjects(T,name)

%--------------------------------------------------------------------------
% Interactively group cells
%--------------------------------------------------------------------------


figure('Name','Group Objects','NumberTitle','off');

H = T;
T2 =[];
a = [];

c1 = uicontrol('Style','popupmenu','Position',[70 10 79 39]);
c1.String = {'<HTML><FONT COLOR="#ff00ff">Group 1</HTML>',...
    '<HTML><FONT COLOR="#00ffff">Group 2</HTML>'};
c1.HandleVisibility = 'on';

c2 = uicontrol('String','Add to Group','Position',[150 20 100 30]);
c2.Callback = {@addselection,T,a,c1};

c3 = uicontrol('String','Undo','Position',[350 20 100 30]);
c3.Callback = {@revertButtonPushed,T,T2,H};

c4 = uicontrol('String','Finish','Position',[450 20 100 30]);
c4.Callback = {@finishButtonPushed,T,name};

c5 = uicontrol('String','Swap Groups','Position',[250 20 100 30]);
c5.Callback = {@swapButtonPushed,T};

selectdisplay(T)

end