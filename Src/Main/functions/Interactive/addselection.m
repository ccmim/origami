function addselection(src,event,T,a,c1)
        a = evalin('base','a',a);
        T = evalin('base','T',T);
        T2 = T;
        val = get(c1,'Value');
        namestr = {'Group 1','Group 2'};
        gname = namestr{val};
        T.Group(a) = {gname};

        assignin('base','T2',T2);
        assignin('base','T',T);
        a = [];
        assignin('base','a',a);
        selectdisplay(T)
end