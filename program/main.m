%
% convert an image set into HDR, then tone mapping it.
%
% input:
%   folder: the (relative) path containing the image set.
%   lambda: smoothness factor for gsolve.
%   [srow scol]: the dimension of the resized image for sampling in gsolve.
%   prefix: output LDR's prefix
%
function main(folder, alpha_, white_, lambda, prefix, srow, scol)

    %%
    % handling default parameters
    if( ~exist('folder') )
	folder = '../image/original/restroom2'; % no tailing slash!
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
    if( ~exist('alpha_') )
	alpha_ = 0.18;
    end
    if( ~exist('white_') )
	white_ = 3;
    end
    if( ~exist('prefix') )
	tokens = strsplit('/', folder);
	prefix = char(tokens(end));
    end
    if( ~exist('shift_bits') )
    shift_bits = 7;
    end

    disp('loading images with different exposures.');
    [g_images, images, exposures] = readImages(folder);
    [row, col, channel, number] = size(images);
    ln_t = log(exposures);

    disp('image alignment.');
    for i = 1:number-1
    shift_ret = zeros(1,2);
    shift = zeros(1,2);
    %figure; imshow(g_images(:,:,i+1));
    [shift] = alignment(g_images(:,:,i), g_images(:,:,i+1), shift_bits, shift_ret);
    disp([i,shift(1),shift(2)]);
    
    images(:,:,:,i+1) = imtranslate(images(:,:,:,i+1),[shift(1), shift(2)],'FillValues',0);
    g_images(:,:,i+1) = imtranslate(g_images(:,:,i+1),[shift(1), shift(2)],'FillValues',0); 
    %figure; imshow(g_images(:,:,i+1));
    %images(:,:,2,i+1) = imtranslate(images(:,:,2,i+1),[shift(1), shift(2)],'FillValues',0);
    %images(:,:,3,i+1) = imtranslate(images(:,:,3,i+1),[shift(1), shift(2)],'FillValues',0);
    %figure; imshow(images(:,:,:,2));
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
    write_rgbe(imgHDR, [prefix '.hdr']);

    imgTMO = tmoReinhard02(imgHDR, 'global', alpha_, 1e-6, white_);
    write_rgbe(imgTMO, [prefix '_tone_mapped.hdr']);
    imwrite(imgTMO, [prefix '_tone_mapped.png']);

    disp('done!');
    %exit();
end
