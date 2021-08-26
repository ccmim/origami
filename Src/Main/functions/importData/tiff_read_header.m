function info =tiff_read_header(filename)
% Function for reading the header of a TIFF (.tif) file
% 
% info  = tiff_read_header(filename);
%
% examples:
% 1,  info=tiff_read_header()
% 2,  info=tiff_read_header('volume.tif');

if(exist('filename','var')==0)
    [filename, pathname] = uigetfile('*.tif', 'Read tiff-file');
    filename = [pathname filename];
end

a = imfinfo(filename);

info.Filename=filename;
info.Format=a(1).Format;
info.CompressedData=a(1).Compression;

nimages = numel(a);
if nimages>1
    info.NumberOfDimensions=3;
else
    info.NumberOfDimensions=2;
end

Xres = 1./a(1).XResolution;
Yres = 1./a(1).YResolution;
imgd = a(1).ImageDescription;
Zres = str2double(extractBetween(imgd,'spacing=',newline));
 
info.PixelDimensions= [Xres, Yres, Zres];

if isempty(Xres|Yres|Zres)
    info.PixelDimensions= [1.0, 1.0, 1.0];
end
 
info.Dimensions=[a(1).Width,a(1).Height,nimages];
info.BitDepth=a(1).BitsPerSample;
 
 

