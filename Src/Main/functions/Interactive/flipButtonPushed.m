function flipButtonPushed(src,evt,T,a)

    a = evalin('base','a',a);
    T = evalin('base','T',T);
if isempty(a)
    warndlg('No Selections Made');
else
    T2 = T;
    T.Polarity(a,:) = -T.Polarity(a,:);
    cla
    selectdisplay(T,true)  
    assignin('base','T2',T2);
    assignin('base','T',T);
    assignin('base','a',[]);
end