% =========================================================================
% ----
% ACME
% ----
% Zebrafish Inner Ear Project
%
% Call and run ACME from MATLAB
%
% Generate and pass commands to ACME precompiled binaries from MATLAB. In
% the last step, the '.mha' segmented output from ACME is imported into
% MATLAB for manually clearing false positives and noise.
%
% Input: file directory to '.mha' files for ACME. 
% Output: '.mat' file data table of objects and their properties: Volume, 
% Surface Area, Sphericity, Centroids and Bounding Boxes. 
%
% =========================================================================

% Set current directory to folder with ACME binaries

% Import file
[file,path] = uigetfile('*.mha','select file');

if(isempty(file))
    return 
end

% create output directory
out = char(strcat(path,{'\'},'results')); mkdir(out);
inm = char(strcat(path,{'\'},'intermediates')); mkdir(inm);

%set ACME paramters
acmepar = inputdlg({'Preprocess Denoising Filter','X Resample Factor',...
    'Y Resample Factor',...
    'Z Resample Factor [(X pixel dim/Z pixel dim)*X Resample factor]',...
    'Planarity Filter Radius','Tensor Voting Neighbourhood Size',...
    'Watershed Segmentation'},...
    'ACME Parameters',[1 75],{'0.3','2','2','0.39','0.7','1.0','2.0'});

% generate LOG file
fid = fopen(fullfile(path, 'ACMELogFile.txt'), 'a');
if fid == -1
    error('Cannot open log file.');
end

s = dir(fullfile(path, 'ACMELogFile.txt'));          % if new, write title
if s.bytes == 0
    fprintf(fid, '\n %s %s\n\r', datestr(now, 0), 'START LOG');
    fprintf(fid,'\n\r \n\r');
end

fclose(fid);
  
% Run ACME commands 

% define file directories
[~,q,r]=fileparts(file);     
a  = fullfile(path,file);
b  = char(strcat(inm,{'\'},q,{'_preprocess'},r));
b2 = char(strcat(inm,{'\'},q,{'_resampled'},r));
c  = char(strcat(inm,{'\'},q,{'_planarity'},r));
d  = char(strcat(inm,{'\'},q,{'_eigen'},r));
e  = char(strcat(inm,{'\'},q,{'_tv'},r));
f  = char(strcat(out,{'\'},q,{'_segmented'},r));
    
cmd = {};
% construct commands
cmd{1} = ['cellPreprocess' ' ' a ' ' b ' ' acmepar{1}];
cmd{2} = ['resample' ' ' b ' ' b2 ' ' ...
    acmepar{2} ' ' acmepar{3} ' ' acmepar{4}];
cmd{3} = ['multiscalePlateMeasureImageFilter' ' ' b2 ...
    ' ' c ' ' d ' ' acmepar{5}];
cmd{4} = ['membraneVotingField3D' ' ' c ' ' d ' ' e ' ' acmepar{6}];
cmd{5} = ['membraneSegmentation' ' ' b2 ' ' e ' ' f ' ' acmepar{7}];

% write to LOG file
fid = fopen(fullfile(path, 'ACMELogFile.txt'), 'a'); 
if fid == -1
    error('Cannot open log file.');
end
fprintf(fid,'\n\r \n\r');
fprintf(fid,'%s\n %s %s\n %s\n\r','------------',...
    datestr(now,'mmmm dd, yyyy'), file,'------------');
    
Waitstring = {'Denoising';'Resampling';'Applying Planarity Filter';...
    'Tensor Voting';'Watershed Segmentation'};

% run commands on each image file and write output to LOG
wb = waitbar(0,'ACME');
for k = 1:length(cmd)
    waitbar(k/length(cmd),wb,strcat('ACME:',Waitstring{k}));
    [~,cmdout] = system(cmd{k});
    fprintf(fid, '\n %s %s\n\r \n\r \t%s\n\r',...
        datestr(now,'HH:MM:SS'),cmd{k}, cmdout);
end
    
fprintf(fid,'\n\r \n\r');
fclose(fid);

%%
% import images
info = mha_read_header(f);
img  = mha_read_volume(info);
if exist('wb')
    waitbar(0.2,wb,'Segmented Result Imported');
else
    wb = waitbar(0.2,'Segmented Result Imported');
end

[~,name,~] = fileparts(info.Filename);

waitbar(0.2,wb,'Computing Object Properties');
[~,~,props] = imstats(img);

waitbar(0.4,wb,'Generating Surface Meshes');
fv = cell2table(surfmesh(props.VoxelList,wb)');
fv.Properties.VariableNames = {'BoundaryFacets'};

A = [props,fv];
waitbar(0.9,wb,'Generating Table');

if isfield(info,'PixelDimensions')
    PxlDim = [info.PixelDimensions(1);
        info.PixelDimensions(2);
        info.PixelDimensions(3)];
    T = resulttable(A,PxlDim);
else
    T = resulttable(A);
end
                
waitbar(1.0,wb,'Complete'); close(wb);
imshow3Dfull(img, [0 length(props.VoxelList)]);
pause(0.5);

%% exclude segmentation errors
a = [];H = T; T2 = [];
clearobjects(T,name)
