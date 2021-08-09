function callbackClickA3DPoint(src, eventData, pointCloud,a,b)
% CALLBACKCLICK3DPOINT mouse click callback function for CLICKA3DPOINT
%
%   The transformation between the viewing frame and the point cloud frame
%   is calculated using the camera viewing direction and the 'up' vector.
%   Then, the point cloud is transformed into the viewing frame. Finally,
%   the z coordinate in this frame is ignored and the x and y coordinates
%   of all the points are compared with the mouse click location and the 
%   closest point is selected.
%
%   Modified: Tania Mendonca - Oct 25, 2018
%   Original: Babak Taati - May 4, 2005
%   revised Oct 31, 2007
%   revised Jun 3, 2008
%   revised May 19, 2009

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

    assignin('base','a',pointCloudIndex);
else % if it is not the first click
% 
%     delete(h); % delete the previously selected point
%   
    a = evalin('base','a');
    b = pointCloudIndex;
    c = find(a==b);
    if isempty(c)
        % highlight the newly selected point
        h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
            selectedPoint(3,:), 'r.', 'MarkerSize', 20);  
        set(h,'Tag','pt');  % set its Tag property for later us
        a = [a;b];
    else
        h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
        selectedPoint(3,:), 'k.', 'MarkerSize', 20);  
%     set(h,'Tag','pt');  % set its Tag property for later use
        a(c) = [];
    end
%     assignin('base','b',b);
    assignin('base','a',a);

end

% fprintf('you clicked on point number %d\n', a);

