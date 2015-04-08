% input
%  images: 4 dimensional matrices, representing the whole image set.
%  [row, col, channel, i] for i = 1:number of images.
%  g: 2 dimensional matrices, [0~255, channel]
%  ln_t: [ln_e, i]for i = 1:number of images, representing image's log exposure time in second.
%  w: the weighting function value for pixel value z
% 
% output
%  imgHDR: 

function imgHDR = hdrDebevec(images, g, ln_t, w)
    [row, col, channel, number] = size(images);
    ln_E = zeros(row, col, 3);
    for channel = 1:3
	for y = 1:row
	    for x = 1:col
		total_lnE = 0;
		totalWeight = 0;
		for j = 1:number
		    tempZ = images(y, x, channel, j) + 1;
		    tempw = w(tempZ+1);
		    tempg = g(tempZ+1);
		    templn_t = ln_t(j);

		    total_lnE = total_lnE + tempw * (tempg - templn_t);
		    totalWeight = totalWeight + tempw;
		end
		ln_E(y, x, channel) = total_lnE / totalWeight;
	    end
	end
    end
    ln_E(isnan(ln_E))=0;
    imgHDR = exp(ln_E);

    % remove NAN or INF
    index = find(isnan(imgHDR) | isinf(imgHDR));
    imgHDR(index) = 0;
end
