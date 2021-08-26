% =========================================================================
% --------------------
% PLOT BY PROPERTY GUI
% --------------------
% Zebrafish Inner Ear Project
%
% Generate plots based on object metrics. 
% 
% Input: '.obj'+'.xlsx' or '.mat' 
% Output: plot 
%
% Author: Tania Mendonca
% Date: 20/10/2018
% =========================================================================

% Import File
[filename,pathname] = uigetfile({'*.obj';'*.mat'},...
'Select file to import');
wb = waitbar(0, 'Importing File');

filename = [pathname filename];
[~,name,ext] = fileparts(filename);

exstrng = {'.obj';'.mat'};
cmp = find(strcmp(exstrng,ext));

if cmp==1                                         % if '.obj'
    waitbar(0.2,wb,'Importing Meshes');
    [centroids, splitfv] = objimport(filename);
    [~, name, ~] = fileparts(filename);
    waitbar(0.4,wb,'Meshes Imported');
    
    [fname, pname] = uigetfile('*.xlsx', 'Get Data Table');
    if fname==0
        errordlg('No data table selected','File Error'); 
        close(wb);
        return
    else
    
    waitbar(0.7,wb,'Reading Data Table');
    T = readtable([pname fname]); % read data table output from arivis 
    warning off MATLAB:table:ModifiedAndSavedVarnames
    if length(splitfv)~=size(T,1)
        errordlg('Data Table and Object file do not match','File Error');
        close(wb); 
        return
    end
    
    c01 = cell2mat(centroids);
    c02 = [T.X_CenterOfMass_Geometry___m_,...
        T.Y_CenterOfMass_Geometry___m_,...
        T.Z_CenterOfMass_Geometry___m_];
    
    cmatch = knnsearch(c01,c02); % closest point in c1 to c2

    for j = 1:size(T,1)
        T.BoundaryFacets(j,:) = splitfv(cmatch(j));
    end
    end
    
elseif cmp==2                                     % if '.mat' 
    waitbar(0.7,wb,'Reading Data Table');
    load(filename); 
else                     
    errordlg('File type not recognised. Pipeline exited');
    close(wb);
    return
end

waitbar(0.9,wb,'Generating Plot');
close(wb);
pplot(T)

%--------------------------------------------------------------------------
function pplot(T)
figure('Name','Plot by property','NumberTitle','off');

g = varfun(@(h) isnumeric(h),T,'OutputFormat','uniform');
t = T(:,g);
k = varfun(@(h) size(h,2)>1,t,'OutputFormat','uniform');
t(:,k) =[]; 

c1 = uicontrol('Style','popupmenu','Position',[50 20 100 30]);
c1.String = t.Properties.VariableNames;
c1.Callback = @selection;


c2 = uicontrol('Style','popupmenu','Position',[160 20 100 30]);
c2.String = brewermap('list');
c2.Callback = @setmap;


txt = uicontrol('Style','text',...
        'Position',[50 50 100 15],...
        'String','Property');
txt2 = uicontrol('Style','text',...
        'Position',[160 50 100 15],...
        'String','Colour Map');
    
BoundaryFacets = T.BoundaryFacets;

set(c2,'Value',35);set(c1,'Value',1);
plotby(T,t{:,1},t.Properties.VariableNames{1},'YlOrRd');

c3 = uicontrol('String','Export','Style','pushbutton',...
    'Position',[270 35 100 30]);
c3.Callback = @savefig;

set([c1,c2,txt,txt2,c3],'Visible','on');

%--------------------------------------------------------------------------
    function selection(src,event)
        mapval = get(c2,'Value');
        mapstr = get(c2,'String');
        scheme = mapstr{mapval};
        val = c1.Value;
        str = c1.String;
        name = str{val};
        prop = t{:,val};
        plotby(T,prop,name,scheme);
    end
    
%--------------------------------------------------------------------------
    function setmap(src,event)
        mapval = c2.Value;
        mapstr = c2.String;
        scheme = mapstr{mapval};
        val = get(c1,'Value');
        str = get(c1,'String');
        name = str{val};
        prop = t{:,val};
        plotby(T,prop,name,scheme);
    end
    
%--------------------------------------------------------------------------
    function savefig(src,event)
        fig = gcf;
        fig.InvertHardcopy = 'off';
        filter = {'*.tif';'*.png';'*.jpg';'*.fig';'*.*'};
        [file,path] = uiputfile(filter);
        
        if ischar(file)
            set([c1,c2,txt,txt2,c3],'Visible','off');
            export_fig(fullfile(path,file), gcf, ...
                '-r300','-nocrop');
            set([c1,c2,txt,txt2,c3],'Visible','on');
        end
        
    end
end