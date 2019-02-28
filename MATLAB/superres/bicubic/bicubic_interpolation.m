function HR = bicubic_interpolation(LR,dim)
% This function computes the bicubic interpolation of the low resolution
% image LR to the the high resolution image of dimensions dim [H,W]
HR = imresize(LR,dim,'bicubic');
