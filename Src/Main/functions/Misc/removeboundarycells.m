function [e,d] = removeboundarycells(T)

%--------------------------------------------------------------------------
% Remove partial cells from the boundaries of the image volume
%--------------------------------------------------------------------------

% bf = {T.BoundaryFacets.vertices};

% bfmin = cell2mat(cellfun(@(h) min(h),bf,'un',0)');
% bfmax = cell2mat(cellfun(@(h) max(h),bf,'un',0)');
% 
% d = bfmin(:,1) == 1 | bfmin(:,2) == 1| bfmin(:,3) == 1|...
%     bfmax(:,1) == info.Dimensions(2) |...
%     bfmax(:,2) == info.Dimensions(1) |...
%     bfmax(:,3) == info.Dimensions(3);

bb = T.BoundingBox;

bb(:,4) = bb(:,1)+bb(:,4);
bb(:,5) = bb(:,2)+bb(:,5);
bb(:,6) = bb(:,3)+bb(:,6);

maxx = max(max(bb(:,1),bb(:,4)));
maxy = max(max(bb(:,2),bb(:,5)));
maxz = max(max(bb(:,3),bb(:,6)));
minx = min(min(bb(:,1),bb(:,4)));
miny = min(min(bb(:,2),bb(:,5)));
minz = min(min(bb(:,3),bb(:,6)));

d = bb(:,1) == minx | bb(:,2) == miny| bb(:,3) == minz|...
    bb(:,4) == maxx | bb(:,5) == maxy | bb(:,6) == maxz;

d2 = bb(:,1) == minx | bb(:,2) == miny| ...
    bb(:,4) == maxx | bb(:,5) == maxy;

g = ~d;
e = T(g,:);