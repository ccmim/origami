function [img,info,T,props,PxlDim] = imgprocess(filename,cmp)

% Import image ('.mha' or '.tif') file and generate data table for each
% segmented object

wb = waitbar(0,'Import File');

if cmp==1
    info = mha_read_header(filename);
    img  = mha_read_volume(info);
else
    info = tiff_read_header(filename);
    for I = 1:info.Dimensions(3)
        img(:,:,I) = imread(filename,I);         % import image into matrix
    end
end

waitbar(0.2,wb,'File Imported');
prompt = {'X pixel resolution (µm/pxl)','Y pixel resolution (µm/pxl)',...
    'Z pixel resolution (µm/pxl)'};
dlgtitle = 'Pixel Resolution';
dims = [1 35];

if isfield(info,'PixelDimensions')
    definput = {num2str(info.PixelDimensions(1)),...
        num2str(info.PixelDimensions(2)),...
        num2str(info.PixelDimensions(3))};
else
    definput = {'1','1','1'};
end

PxlDim = cell2mat(cellfun(@(x) str2num(x),...
    inputdlg(prompt,dlgtitle,dims,definput),'UniformOutput', false));

waitbar(0.2,wb,'Computing Object Properties');
[~,~,props] = imstats(img);

% remove largest two cells - background
bigc = maxk(props.Volume,3);
props(props.Volume > min(bigc),:)=[];

waitbar(0.4,wb,'Generating Surface Meshes');

% for j = 1:size(props,1)
%     voxl = props.VoxelList{j};
%     umvoxl{j} = voxl.*repmat(PxlDim',size(voxl,1),1);
% end

fv = cell2table(surfmesh(props.VoxelList,wb)');
fv.Properties.VariableNames = {'BoundaryFacets'};

A = [props,fv];

waitbar(0.9,wb,'Generating Table');
T = resulttable(A,PxlDim);

waitbar(1.0,wb,'Complete'); close(wb);
imshow3Dfull(img, [0 length(props.VoxelList)]);
pause(0.5);
