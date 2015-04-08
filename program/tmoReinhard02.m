%
% Tone Mapping Operator, by Reinhard 02 paper.
%
% input:
%   img: 3 channel HDR img
%   type_: 'global'(default) or 'local'.
%   alpha_: scalar constant to specify a high key or low key. (0.18)
%   delta: scalar constant to prevent log(0). (1e-6)
%   white_: scalar constant, the smallest luminance to be mapped to 1. (1.5)
%   phi: (local) scalar constant. (8.0)
%   epsilon: (local) scalar constant to tell the terminating threshold. (0.05)
%
% output:
%   tone-mapped image (LDR)
%
function imgOut = tmoReinhard02(img, type_, alpha_, delta, white_, phi, epsilon )
    imgOut = zeros(size(img));
    Lw = 0.27 * img(:,:,1) + 0.67 * img(:,:,2) + 0.06 * img(:,:,3);
    
	LwMean = exp(mean(mean(log(delta + Lw))));
	Lm = (alpha_ / LwMean) * Lw;
    Lm(isnan(Lm))=0;
    switch type_
	case 'global'
	    disp('global');
	    Ld = (Lm .* (1 + Lm / (white_ * white_))) ./ (1 + Lm);
        Ld(isnan(Ld))=0;
	case 'local'
	    disp('local');
        Lblur_s = zeros(size(Lw,1), size(Lw,2), 9);
        for i = 0:8
            s = 1.6^i;
            g = fspecial('gaussian', floor(6*s+1), s);
            Lblur_s(:,:,i+1) = imfilter(Lm,g);
            %figure;imshow(Lblur_s(:,:,i+1));
        end
        for i = 1:size(Lw,1)
            for j = 1:size(Lw,2)
                smax = 1;
                for k = 0:7
                    s = 1.6^k;
                    denominator = (((2^phi)*alpha_)/s*s) + Lblur_s(i,j,k+1);
                    if denominator == 0
                        Vsij = 0;
                    else
                        Vsij = (Lblur_s(i,j,k+1)-Lblur_s(i,j,k+2)) / denominator;
                    end
                    if abs(Vsij) < epsilon
                        smax = k+1;
                    end
                    if (1+Lblur_s(i,j,smax)) == 0
                        Ld(i,j) = 0;
                    else
                        Ld(i,j) = (Lm(i,j) / (1+Lblur_s(i,j,smax))); 
                    end
                end
            end
       end
    end
    %figure(1); imshow(img);
    %rgb = tonemap(img, 'AdjustLightness', [0.0001, 1], 'AdjustSaturation', 2);
    %figure(2); imshow(rgb);
    
    for channel = 1:3
        Cw = img(:,:,channel) ./ Lw;
        Cw(isnan(Cw))=0;
        imgOut(:,:,channel) = Cw .* double(Ld);
    end
    imgOut(isnan(imgOut))=0;

end
