function flipall(hObject,evt,T)

% flip all polarity vectors

T = evalin('base','T',T);
%disp(hObject.String)
if contains(hObject.String,'in')
    hObject.String='Direction: out';
else
    hObject.String='Direction: in';
end

T2 = T;
T.Polarity = -T.Polarity;

cla

selectdisplay(T,true)
assignin('base','T2',T2);
assignin('base','T',T);


end
