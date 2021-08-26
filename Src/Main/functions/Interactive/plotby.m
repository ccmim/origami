function h = plotby(T,prop,name,scheme)
        
n = size(T,1);
cmap = brewermap(64,scheme);                                       % define colormap
cl = round(1+(size(cmap,1)-1)...                  % mapped time range
    *(prop-min(prop))/(max(prop)-min(prop)));
 

cla
set(gcf,'color',[0.5 0.5 0.5])

for i = 1:n
    h = patch(T.BoundaryFacets(i),...
        'facecolor',cmap(cl(i),:),'edgecolor','none',...
        'facealpha',0.5);
end

%ax = gca; box on; ax.BoxStyle = 'full';
hold on
caxis([ min(prop) , max(prop)]);              % set colorbar limits
colorbar;                                     % display colorbar
colormap(cmap);                               % correct colormap on colorbar
d = colorbar;

% if contains(inputname(2),'.')
%     w = split(inputname(2),'.');
%     d.Label.String = w{2};
% else
    d.Label.String = name;
    d.FontWeight = 'Bold';
    d.Label.FontWeight = 'Bold';
    d.Label.FontSize = 12;
% end

% ax = gca;
% set(ax,'Projection','perspective','View',[45, 25]);
cameratoolbar('Show');
axis equal tight off

