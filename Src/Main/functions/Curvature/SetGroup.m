function T = SetGroup(T)

% Group cells by curvature

MeanCurv = T.MeanCurvature;

%b = fitgmdist(MeanCurv(:),2,'Replicates',10);

try
    b = fitgmdist(MeanCurv(:),2,'Replicates',10);
catch
    w = warndlg('Classification by curvature failed. Manually set groups');
    uiwait(w);
end

if exist('b')
    i2 = cluster(b,MeanCurv(:));
    GA = find(i2==2); gv(1) = std(MeanCurv(GA));
    GB = find(i2==1); gv(2) = std(MeanCurv(GB));
    
    if find(max(gv))==1
        T.Group(GA) = {'Group 1'};
        T.Group(GB) = {'Group 2'};
    else
        T.Group(GB) = {'Group 1'};
        T.Group(GA) = {'Group 2'};
    end
    
else
    T.Group(:) = {'Group 2'};

end
