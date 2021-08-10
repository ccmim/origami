% =========================================================================
% ---------------------
% ACME BATCH PROCESSING
% ---------------------
% Zebrafish Inner Ear Project
%
% Call ACME precompiled binaries from MATLAB. 
% 
% Input: folder directory to multiple '.mha' files for ACME. 
% Output: '.mha' segmented results and intermediate results from ACME. 
%
% =========================================================================/Users/Tania/Google Drive (taniaviola.m@gmail.com)/Work/2017-18_PostDoc1_FrangiWhitfield/Papers/Cell_Shape/Scripts/Origami/ACME/ACME_batch_MacOS.m


% Set MATLAB path to directory with ACME binaries

% Import folder
F = uigetdir('Input Directory');
[path,folder] = fileparts(F);

% get filenames from folder
l = dir(F);
l2 = [l.bytes];                                       % remove empty files 
g = l2 == 0;                                          % (false positives)
h = l(~g);     
filenames = sort_nat({h.name});
i = length(filenames);

% create output directory
out = char(strcat(F,{'/'},'results')); mkdir(out);
inm = char(strcat(F,{'/'},'intermediates')); mkdir(inm);

% set parameters
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
%%
% start MATLAB parallel pool
% pool = parpool('local',4);
    
% Run ACME commands on all files 

for j = 1:length(filenames)
    
    % define file directories
    [~,q,r]=fileparts(filenames{j});     
    a  = char(strcat(  F,{'/'},q,r));
    b  = char(strcat(inm,{'/'},q,{'_preprocess'},r));
    b2 = char(strcat(inm,{'/'},q,{'_resampled'},r));
    c  = char(strcat(inm,{'/'},q,{'_planarity'},r));
    d  = char(strcat(inm,{'/'},q,{'_eigen'},r));
    e  = char(strcat(inm,{'/'},q,{'_tv'},r));
    f  = char(strcat(out,{'/'},q,{'_segmented'},r));
    
    cmd = {};
    % construct commands
    cmd{1} = ['./cellPreprocess' ' ' a ' ' b ' ' acmepar{1}];
    cmd{2} = ['./resample' ' ' b ' ' b2 ' ' ...
        acmepar{2} ' ' acmepar{3} ' ' acmepar{4}]; 
    cmd{3} = ['./multiscalePlateMeasureImageFilter' ' ' b2 ...
        ' ' c ' ' d ' ' acmepar{5}];
    cmd{4} = ['./membraneVotingField3D' ' ' c ' ' d ' ' e ' ' acmepar{6}];
    cmd{5} = ['./membraneSegmentation' ' ' b2 ' ' e ' ' f ' ' acmepar{7}]; 
    
    % write to LOG file
    fid = fopen(fullfile(path, 'ACMELogFile.txt'), 'a');
    if fid == -1
        error('Cannot open log file.');
    end
    fprintf(fid,'\n\r \n\r');
    fprintf(fid,'%s\n %s %s\n %s\n\r','------------',...
        datestr(now,'mmmm dd, yyyy'), filenames{j},'------------');
    
    % run commands on each image file and write output to LOG
    for k = 1:length(cmd)
        [~,cmdout] = system(cmd{k});
        fprintf(fid, '\n %s %s\n\r \n\r \t%s\n\r',...
            datestr(now,'HH:MM:SS'),cmd{k}, cmdout);
    end
    fprintf(fid,'\n\r \n\r');
    fclose(fid);
    
end
