%
% alignment images, convert an image set into HDR, then tone mapping it.
%
% input:
%   folder: the (relative) path containing the image set.
%   type_: 'global' or 'local' tone mapping
%   phi: used by local tone mapping
%   epsilon: used by local tone mapping (find the max gaussian scale)
%   lambda: smoothness factor for gsolve.
%   prefix: output LDR file's prefix name
%   [srow scol]: the dimension of the resized image for sampling in gsolve.
%   shift_bits: the maximum number of bits in the final offsets in
%   alignment.
%
function main(folder, type_, alpha_, delta_, white_, phi, epsilon, lambda, prefix, srow, scol, shift_bits)

    %%
    % handling default parameters
    if( ~exist('folder') )
	folder = '../image/original/new_library'; % no tailing slash!
    end
    if( ~exist('lambda') )
	lambda = 10;
    end
    if( ~exist('srow') )
	srow = 10;
    end
    if( ~exist('scol') )
	scol = 20;
    end
    if( ~exist('type_') )
	type_ = 'local';
    end
    if( ~exist('alpha_') )
	alpha_ = 0.3;
    end
    if( ~exist('delta_') )
    delta_ = 1e-6;
    end
    if( ~exist('white_') )
	white_ = 100;
    end
    if( ~exist('phi') )
	phi = 8.0;
    end
    if( ~exist('epsilon') )
	epsilon = 0.05;
    end
    if( ~exist('prefix') )
	tokens = strsplit('/', folder);
	prefix = char(tokens(end));
    end
    if( ~exist('shift_bits') )
    shift_bits = 4;
    end

    disp('loading images with different exposures.');
    [g_images, images, exposures] = readImages(folder);
    [row, col, channel, number] = size(images);
    ln_t = log(exposures);
    disp(ln_t);
    
    disp('image alignment.');
    for i = 1:number-1
    shift_ret = zeros(1,2);
    shift = zeros(1,2);
    [shift] = alignment(g_images(:,:,i), g_images(:,:,i+1), shift_bits, shift_ret);
    disp([i,shift(1),shift(2)]);
    
    images(:,:,:,i+1) = imtranslate(images(:,:,:,i+1),[shift(1), shift(2)],'FillValues',0);
    g_images(:,:,i+1) = imtranslate(g_images(:,:,i+1),[shift(1), shift(2)],'FillValues',0); 
    end

    disp('shrinking the images to get the reasonable number of sample pixels (by srow*scol).');
    simages = zeros(srow, scol, channel, number);
    for i = 1:number
	simages(:,:,:,i) = round(imresize(images(:,:,:,i), [srow scol], 'bilinear'));
    end

    disp('calculating camera response function by gsolve.');
    g = zeros(256, 3);
    lnE = zeros(srow*scol, 3);
    w = weightingFunction('debevec97');
    w = w/max(w);

    for channel = 1:3
	rsimages = reshape(simages(:,:,channel,:), srow*scol, number);
    [g(:,channel), lnE(:,channel)] = gsolve(rsimages, ln_t, lambda, w);
    end

    disp('constructing HDR radiance map.');
    imgHDR = hdrDebevec(images, g, ln_t, w);
    hdrwrite(imgHDR, [prefix '.hdr']);
    
    %hdr = hdrread('new_library.hdr');
    %rgb = tonemap(hdr);
    %imwrite(rgb,'0407library_tm_matlab.png')
    %figure;imshow(rgb);
    
    imgTMO = tmoReinhard02(imgHDR, type_, alpha_, delta_, white_, phi, epsilon);
    %imgTMO = tmoReinhard02(hdr, type_, alpha_, delta_, white_, phi, epsilon);
    write_rgbe(imgTMO, [prefix '_tone_mapped.hdr']);
    imwrite(imgTMO, [prefix '_tone_mapped.png']);

    disp('done!');
    %exit();
end
