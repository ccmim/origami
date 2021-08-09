% =========================================================================
% -------------------
% Generate Synthetic Epithelia (Part II): Convolve and add noise
% -------------------
%
% Script to generate synthetic images of membrane-labelled epithelia with
% parameters to control curvature of epithelium and folding extent
%
% Publication: 'Origami: Single-cell oriented 3D shape dynamics of folding
% epithelia from fluorescence microscopy images'
%
% Author: Tania Mendonca
% University of Sheffield
%
% Copyright © 2021, University of Sheffield & University of Leeds
% GNU General Public License
% =========================================================================
%% import simulated PSF file (generated using PSF Generator in Fiji (ImageJ))

infoPSF = tiff_read_header('PSF_Defocus.tif');
for PSF = 1:infoPSF.Dimensions(3)
    psf(:,:,PSF) = imread('PSF_Defocus.tif',PSF);        % import psf image 
end

% import simulated raw image
[filename,pathname] = uigetfile({'*.mat'},...
    'Select file to import');

[~,name] = fileparts(filename);

load(filename);

%% Convolve and corrupt

A = convnfft(I, psf, 'same');

% Add noise
s = [1.0,0.7,0.4];
l = [0.01,0.04,0.07];

for n = 3
    
    A2 = rescale(A,0,s(n));
    A3 = imnoise(A2,'gaussian',0,l(n)^2);
    A4 = imnoise(A3,'poisson');
    
    
    % Write as .tif
    B = uint8(rescale(A4,0,255));
    
    t = Tiff(strcat(name,'noise',num2str(n),'.tif'),'w');
    tagstruct.ImageLength = size(B,1);
    tagstruct.ImageWidth = size(B,2);
    tagstruct.SampleFormat = 1; % uint
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 8;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
   
    for ii=1:size(B,3)
        setTag(t,tagstruct);
        write(t,B(:,:,ii));
        writeDirectory(t);
    end
    
    close(t)
    
end

clearvars -except psf