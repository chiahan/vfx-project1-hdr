%
% read in several images with different exposures.
%
% input
%  folder: folder name containing images.
%  extension: file extension. default to 'jpg'.
%
% output
%  images: 4 dimensional matrices, representing the whole image set.
%	[row, col, channel, i] for i = 1:number of images.
%  exposureTimes: (number, 1) matrices, representing image's exposure time in second.
%
% note
%  We assume the input images have the same dimension, channel number and color space,
%  with EXIF metadata.
%
function [g_images, images, exposureTimes] = readImages(folder, extension)
    images = [];
    exposureTimes = [];
    g_images = [];
    
    if( ~exist('extension') )
	extension = 'jpg';
    end

    files = dir([folder, '/*.', extension]);

    % grab images info to initialize images and exposureTimes.
    filename = [folder, '/', files(1).name];
    info = imfinfo(filename);
    number = length(files);
    images = zeros(info.Height, info.Width, info.NumberOfSamples, number, 'uint8');
    g_images = zeros(info.Height, info.Width, number, 'uint8');
    exposureTimes = zeros(number, 1);

    for i = 1:number
	filename = [folder, '/', files(i).name];
	img = imread(filename);
	images(:,:,:,i) = img;
    g_images(:,:,i) = rgb2gray(img);
    %figure; imshow(images(:,:,:,i));
    %cmap = colormap('gray');
    %imwrite(g_images(:,:,i),cmap, ['test',i,'.jpg'], 'jpeg');
    
    
	exif = exifread(filename);
	exposureTimes(i) = exif.ExposureTime;
    end
end
