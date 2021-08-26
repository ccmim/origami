function finishButtonPushed(src,evt,T,name) 
answer = questdlg('Do you want to save data?',...
    'Options',...
    'Save and Continue','Go back',...
    'Save and Continue');

switch answer
    case 'Save and Continue'
        T = evalin('base','T',T);
        name2 = strcat(name,'.mat');
        uisave({'T'},name2);
        close

    case 'Go back to cleaning'
        
end
end

   