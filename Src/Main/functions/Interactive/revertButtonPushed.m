function revertButtonPushed(src,evt,T,T2,H,pol)

if(exist('pol','var')==0)
    pol = false;
else
    validateattributes(pol, {'logical'},{'scalar'});
end

if (ismember('Polarity',T.Properties.VariableNames)==0)
    pol = false;
end

    T2 = evalin('base','T2',T2);
    T = evalin('base','T',T);
    H = evalin('base','H',H);
    
if isempty(T2)
    T = H;
    cla
    selectdisplay(T,pol);
    assignin('base','T',T);
else
    T = T2;
    T2 = [];
    cla
    selectdisplay(T,pol)  
    assignin('base','T2',T2);
    assignin('base','T',T);
end
end
