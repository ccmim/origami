function selectAcell(T)

% Select and view properties for individual objects.
% 
% Input: Table of object properties
% Output: GUI with (1) 3D plot of selectable cells 
%                  (2) table of stats for selected cell
%                  (3) 3D rendering of single selected cell with polarity
%                      vector
%
% Selections are denoted by red centroid colour. The stats and the single
% cell view image can be exported.
%
% Author: Tania Mendonca
% Date: 20/10/2018

% Define figure with panels
f = figure('Name','Select Cell','NumberTitle','off');
p1 = uipanel(f,'Title','Select a cell',...
    'Position',[0.01 0.01 .53 0.99],'units','normalized');
p2 = uipanel(f,'Title','cell stats',...
    'Position',[0.55 0.75 .44 0.25],'units','normalized');
p3 = uipanel(f,'Title','single cell view',...
    'Position',[0.55 0.01 .44 0.73],'units','normalized');

% text placeholders
tbox1 = uicontrol('Style','text','String','No selection made',...
    'parent',p2,'units','normalized','Position',[0.25 0 0.5 0.5]);
tbox2 = uicontrol('Style','text','String','No selection made',...
    'parent',p3,'units','normalized','Position',[0.25 0 0.5 0.5]);

% function for selecting cells
selectsingleprops(T,p1,p2,p3)

%--------------------------------------------------------------------------
function selectsingleprops(T,p1,p2,p3)

% plot all the cells
p1.Clipping = 'on';
ax1 = axes('Parent',p1,'Position',[0.1 0.1 0.8 0.8]);

for kk = 1:size(T,1)
    patch(T.BoundaryFacets(kk),'facecolor',rand(1,3),'edgecolor','none',...
        'facealpha',0.3)
end
axis off equal
hold on

% function for selectable points
h = clicksinglePoint(T,p1,p2,p3,ax1);
end

%--------------------------------------------------------------------------
function h = clicksinglePoint(T,p1,p2,p3,ax1)

pointCloud = T.Centroid';
if size(pointCloud, 1)~=3
    error('Input point cloud must be a 3*N matrix.');
end

h = gcf;

% plot the centroids
plot3(pointCloud(1,:), pointCloud(2,:), pointCloud(3,:),...
    'k.','MarkerSize',20); 
hold on; % so we can highlight clicked points without clearing the figure
    
% set the callback, pass pointCloud to the callback function
set(h, 'WindowButtonDownFcn', {@callbackClicksinglePoint,T,p1,p2,p3});

end

%--------------------------------------------------------------------------
function callbackClicksinglePoint(src, eventData,T,p1,p2,p3)

pointCloud = T.Centroid';

% keep the figure positions after update
point = get(gca, 'CurrentPoint'); % mouse click position
camPos = get(gca, 'CameraPosition'); % camera position
camTgt = get(gca, 'CameraTarget'); % where the camera is pointing to

camDir = camPos - camTgt; % camera direction
camUpVect = get(gca, 'CameraUpVector'); % camera 'up' vector

% build an orthonormal frame based on the viewing direction and the 
% up vector (the "view frame")
zAxis = camDir/norm(camDir);    
upAxis = camUpVect/norm(camUpVect); 
xAxis = cross(upAxis, zAxis);
yAxis = cross(zAxis, xAxis);

rot = [xAxis; yAxis; zAxis]; % view rotation 

% the point cloud represented in the view frame
rotatedPointCloud = rot * pointCloud; 

% the clicked point represented in the view frame
rotatedPointFront = rot * point' ;

% find the nearest neighbour to the clicked point 
pointCloudIndex = dsearchn(rotatedPointCloud(1:2,:)', ... 
    rotatedPointFront(1:2));

h = findobj(gcf,'Tag','pt'); % try to find the old point
selectedPoint = pointCloud(:, pointCloudIndex); 

if isempty(h) % if it's the first click (i.e. no previous point to delete)
    
    % highlight the selected point
    h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
        selectedPoint(3,:), 'r.', 'MarkerSize', 20); 
    set(h,'Tag','pt'); % set its Tag property for later use 

else % if it is not the first click
    delete(h); % delete the previously selected point

        % highlight the newly selected point
        h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
            selectedPoint(3,:), 'r.', 'MarkerSize', 20);  
        set(h,'Tag','pt');  % set its Tag property for later us
end

% get table of stats
T = evalin('base','T',T);
t = T(pointCloudIndex,:);   % get stats for the selected cell
% reshape table for display
g = varfun(@(h) isstruct(h),t,'OutputFormat','uniform'); t(:,g) =[];
k = varfun(@(h) size(h,2)>1,t,'OutputFormat','uniform'); t(:,k) =[];
tt = table2cell(t);
l = cellfun(@(h) ischar(h)|isnumeric(h),tt); tt = tt(:,l)';
rn = t.Properties.VariableNames(:,l)';tt = [rn,tt];

% clear any previous objects from panel 2
delete(get(p2,'Children'));
% display table
uit = uitable(p2,'Data',tt,'Units','normalized',...
    'Position',[0.02 0.1 .95 .85]);
uit.RowName = ([]); uit.ColumnName = ([]);

% control button to export stats file
c1 = uicontrol('String','Export','Style','pushbutton',...
    'parent',p2,'units','normalized','Position',[0.7 0 0.2 0.25]);
c1.Callback = {@savexcel,t};

% clear any previous objects from panel 3
delete(get(p3,'Children'));
% plot mesh for the single cell
p3.Clipping = 'on';
ax2 = axes('Parent',p3,'Position',[0.1 0.1 0.8 0.8]);
patch(T.BoundaryFacets(pointCloudIndex),...
    'facecolor',rand(1,3),'edgecolor','none','facealpha',0.3);
hold on;
% plot the polarity vector for orientation (if data is in the table)
if ismember('Polarity',T.Properties.VariableNames)
    quiver3(T.Centroid(pointCloudIndex,1),...
        T.Centroid(pointCloudIndex,2),T.Centroid(pointCloudIndex,3),...
        T.Polarity(pointCloudIndex,1),...
        T.Polarity(pointCloudIndex,2),T.Polarity(pointCloudIndex,3),'k',...
        'AutoScale','on','AutoScaleFactor', 30);
end
axis equal off

% control button to export image of single cell
c2 = uicontrol('String','Export','Style','pushbutton',...
    'parent',p3,'units','normalized','Position',[0.7 0 0.2 0.1]);
c2.Callback = {@savefig,p3};

end

%--------------------------------------------------------------------------
function savexcel(src,event,t)
% function to save excel file of stats

filter = {'*.csv';'*.xlsx'};
[file,path] = uiputfile(filter,'Save Excel File');

if ischar(file)          % don't write if user dosen't define save location
    writetable(t,fullfile(path,file))
end

end

%--------------------------------------------------------------------------    
function savefig(src,event,p3)
% function to save single cell figure
        filter = {'*.tif';'*.png';'*.jpg';'*.fig';'*.*'};
        [file,path] = uiputfile(filter);
        fig = get(p3,'Children');
        if ischar(file)  % don't write if user dosen't define save location
            export_fig(fullfile(path,file),fig(2),'-r300');
        end
end

end