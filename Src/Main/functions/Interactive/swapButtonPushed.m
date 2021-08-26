function swapButtonPushed(src,event,T)

T = evalin('base','T',T);
T2 = T;

a = ismember(T.Group,'Group 2');
T.Group(a) = {'Group 1'};
T.Group(~a) = {'Group 2'};

assignin('base','T2',T2);
assignin('base','T',T);
a = [];
cla

selectdisplay(T)
end