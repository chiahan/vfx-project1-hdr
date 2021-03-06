% 
% This function takes two exposure images, and determines how much to move 
% the second exposure (img2) in x and y to align it with the first exposure
% (img1)
%
% input
%  g_img: 3 dimensional matrices, represneting the whole gray_image set.
%  [row, col, i] for i = 1:number of images.
%  shift_bits: the maximum number of bits in the final offsets
%  shift_ret: the result value of x and y by which img2 shifted
%
% output
%  shift_ret: the result value of x and y by which img2 shifted
%
% note
%  We assume the input images have the same dimension, channel number and 
%  color space, with EXIF metadata.
%
% ref
%  Fast, Robust Image Registration for Compositing High Dynamic Range Photographs from Handheld Exposures
%
function [shift_ret] = alignment(g_img1, g_img2, shift_bits, shift_ret)   
    
    cur_shift = zeros(1,2);
    h_1 = size(g_img1(),1);
    w_1 = size(g_img1(),2);
    h_2 = size(g_img2(),1);
    w_2 = size(g_img2(),2);
    
    tb1 = zeros(h_1, w_1);
    tb2 = zeros(h_2, w_2);
    eb1 = zeros(h_1, w_1);
    eb2 = zeros(h_2, w_2);
    
    if shift_bits > 0
        sml_img1 = imresize(g_img1, 0.5);
        sml_img2 = imresize(g_img2, 0.5);
        cur_shift = alignment(sml_img1, sml_img2, shift_bits-1, cur_shift);
        cur_shift(1) = cur_shift(1) * 2;
        cur_shift(2) = cur_shift(2) * 2;
    else
        cur_shift(1) = 0;
        cur_shift(2) = 0; 
    end
    
    %ComputeBitmaps(g_img1, &tb1, &eb1);
    %ComputeBitmaps(g_img2, &tb2, &eb2);
    threshold_1 = median(reshape(g_img1(:,:),[],1));
    threshold_2 = median(reshape(g_img2(:,:),[],1));
    for i = 1:h_1
        for j = 1:w_1
            if g_img1(i,j) < threshold_1
                tb1(i,j)=0;
            else
                tb1(i,j)=1;
            end
            if (g_img1(i,j)>=threshold_1-4) && (g_img1(i,j)<=threshold_1+4)
                eb1(i,j)=0;
            else
                eb1(i,j)=1;
            end
            if g_img2(i,j) < threshold_2
                tb2(i,j)=0;
            else
                tb2(i,j)=1;
            end
            if (g_img2(i,j)>=threshold_2-4) && (g_img2(i,j)<=threshold_2+4)
                eb2(i,j)=0;
            else
                eb2(i,j)=1;
            end
        end
    end

    min_err = w_1 * h_1;
    for i = -1: 1: 1  
        for j = -1: 1: 1
            xs = cur_shift(1) + i;
            ys = cur_shift(2) + j;
            shifted_tb2 = imtranslate(tb2,[xs, ys],'FillValues',0);
            shifted_eb2 = imtranslate(eb2,[xs, ys],'FillValues',0);
            diff_b = xor(tb1, shifted_tb2);
            diff_b = and(diff_b, eb1);
            diff_b = and(diff_b, shifted_eb2);
            err = sum( diff_b(:) );
            if err < min_err
                shift_ret(1) = xs;
                shift_ret(2) = ys;
                min_err = err;
            end
          
        end
    end    
end
