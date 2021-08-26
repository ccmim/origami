function TOutput = AddGeometricDescriptors(T, varargin)

% Function to generate oriented shape features from triangular meshes for
% each cell and polarity assigned in previous sections based on the paper:
% Pozo, J. M., Villa-Uriol, M. C., & Frangi, A. F. (2011). "Efficient 3D
% Geometric and Zernike moments computation from unstructured surface
% meshes". IEEE Transactions on Pattern Analysis and Machine Intelligence,
% 33(3), 471-484.

[n,m]=size(T);

if nargin>1
    PxlDim = varargin{1};
else
    prompt = {'X pixel resolution (µm/pxl)','Y pixel resolution (µm/pxl)',...
        'Z pixel resolution (µm/pxl)'};
    dlgtitle = 'Pixel Resolution';
    dims = [1 35];
    definput = {'1','1','1'};
    PxlDim = cell2mat(cellfun(@(x) str2num(x),...
        inputdlg(prompt,dlgtitle,dims,definput),'UniformOutput', false));
end

if ismember('Polarity',T.Properties.VariableNames)
    
    for(i=1:n)
        Ti=T(i,:);
        mu=Ti.Polarity;
        mesh=Ti.BoundaryFacets;
        mesh.vertices = mesh.vertices.*repmat(PxlDim',...
           size(mesh.vertices,1),1);
        geometricDescriptors=ExtractGeometricDescriptors(mesh,mu);
        descriptorNames=char(fieldnames(geometricDescriptors));
        nD=size(descriptorNames,1);
        for(j=1:nD)
            descriptor=getfield(geometricDescriptors,descriptorNames(j,:));
            Ti=setfield(Ti,descriptorNames(j,:),descriptor);
        end
        TOutput(i,:)=Ti;
    end
    
else
    errordlg('Assign polarity before computing shape metrics','Error');
end

end