function plotbyproperty2(T)

%--------------------------------------------------------------------------
% Interactively plot objects by selected property and with selected color
% map. Color maps used are from ColorBrewer (http://colorbrewer2.org/).
% Check website for advice on colourblind friendly colour schemes.
%--------------------------------------------------------------------------

figure('Name','Plot by property','NumberTitle','off');

c1 = uicontrol('Style','popupmenu','Position',[50 20 100 30]);
c1.String = {'Volume [µm^3]','Skewness','Sphericity','Surface Area [µm^2]',...
    'Longitudinal Spread', 'Transverse Spread','Mean Curvature [µm^-^1]'};
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
    
t = [T.Volume_um, T.Skewness, T.Sphericity, T.SurfaceArea_um,...
    T.LongitudinalSpread, T.TransversalSpread,T.MeanCurvature];

BoundaryFacets = T.BoundaryFacets;

set(c2,'Value',35);
plotby(T,T.Volume_um,'Volume [µm^3]','YlOrRd');

c3 = uicontrol('String','Export','Style','pushbutton',...
    'Position',[270 35 100 30]);
c3.Callback = @savefig;

set([c1,c2,txt,txt2,c3],'Visible','on');

    function selection(src,event)
        mapval = get(c2,'Value');
        mapstr = get(c2,'String');
        scheme = mapstr{mapval};
        val = c1.Value;
        prop = t(:,val);
        str = c1.String;
        name = str{val};
        plotby(T,prop,name,scheme);
    end

    function setmap(src,event)
        mapval = c2.Value;
        mapstr = c2.String;
        scheme = mapstr{mapval};
        val = get(c1,'Value');
        prop = t(:,val);
        str = get(c1,'String');
        name = str{val};
        plotby(T,prop,name,scheme);
    end

    function savefig(src,event)
        fig = gcf;
        fig.InvertHardcopy = 'off';
        filter = {'*.tif';'*.png';'*.jpg';'*.fig';'*.*'};
        [file,path] = uiputfile(filter);
        
        if ischar(file)
            set([c1,c2,txt,txt2,c3],'Visible','off');
            export_fig(fullfile(path,file), gcf,...
                '-r300','-nocrop');
            set([c1,c2,txt,txt2,c3],'Visible','on');
        end
        
    end


end