function  [HR_patches, LR_patches] = hr_lr_face2patch(train_imgs_HR,dx,dx_ref)
% This function receives a list of high resolution images and the
% resolution of the low resolution images and returns two structures the
% high resolution patches and low resolution patches with additional
% information about the patches
%
% Designed: Reuben Farrugia
% Date: 28/2/2015
%

% Idenitify the patch size for this application
if dx > 4
    LR_patches.patch_size = 5;
    LR_patches.overlap = 2;
else
    LR_patches.patch_size = 3;
    LR_patches.overlap = 1;
end

% Derive the number of training images available
Nimgs = size(train_imgs_HR,1);

% Initialize the patch arrays
lr_img_patches = cell(Nimgs,1);
hr_img_patches = cell(Nimgs,1);

% Derive the scale
scale = dx/dx_ref;

% Derive the corresponding Hr patch size
HR_patches.patch_size = round(1/scale * LR_patches.patch_size);
HR_patches.overlap    = round(1/scale * LR_patches.overlap);

for n = 1:Nimgs
    % Extract the high resolution image
    H = train_imgs_HR{n};
    
    % Derive the low resolution counterpart
    L = imresize(H,scale);
    
    % Convert the image to patches
    lr_img_patches{n} = img2patch(L, LR_patches.patch_size, LR_patches.overlap);
    hr_img_patches{n} = img2patch(H, HR_patches.patch_size, HR_patches.overlap);
end

% Put the high and low resolution patches in respective structures
LR_patches.img_patches = lr_img_patches;
HR_patches.img_patches = hr_img_patches;