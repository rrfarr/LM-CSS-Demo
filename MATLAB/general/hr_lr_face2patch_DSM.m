function  [HR_patches, LR_patches] = hr_lr_face2patch_DSM(train_imgs_HR,dx,dx_ref,s)
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

% Derive the number of points per image
S = 4*s*(s+1) + 1;

% Initialize the patch arrays
lr_img_patches = cell(S*Nimgs,1);
hr_img_patches = cell(S*Nimgs,1);

% Derive the scale
scale = dx/dx_ref;

% Determine the step size to be used
step_size = ceil(1/scale);

% Derive the corresponding Hr patch size
HR_patches.patch_size = round(1/scale * LR_patches.patch_size);
HR_patches.overlap    = round(1/scale * LR_patches.overlap);

k = 1;
for n = 1:Nimgs
    % Extract the high resolution image
    H = train_imgs_HR{n};
    
    for s1 = -s*step_size:step_size:s*step_size
        for s2 = -s*step_size:step_size:s*step_size
            % Translate the image by [i, j]
            Hs = double(translate(H, s1, s2));
            
            % Derive the indices that need to be arranged
            Hs = filter_img(Hs,s1,s2); % border pels are marked by -1

            % Derive the patches of the high resolution
            hr_img_patches{k} = img2patch(Hs, HR_patches.patch_size, HR_patches.overlap);

            % Derive the low resolution counterpart
            L = imresize(uint8(Hs),scale);

            % Convert the image to patches
            lr_img_patches{k} = img2patch(L, LR_patches.patch_size, LR_patches.overlap);

            % Derive the patches that need to be prunend
            idx_prune = test_patch(hr_img_patches{k});
            % Prune these patches from the set
            hr_img_patches{k} = prune(hr_img_patches{k}, idx_prune);
            lr_img_patches{k} = prune(lr_img_patches{k}, idx_prune);
            
            k = k + 1;
        end
    end
end

% Put the high and low resolution patches in respective structures
LR_patches.img_patches = lr_img_patches;
HR_patches.img_patches = hr_img_patches;

function J = translate(I, i, j)
% Create the geometric translator
htranslate=vision.GeometricTranslator;
htranslate.OutputSize='Same as input image';
htranslate.Offset=[i j];

% Translate the image
J = step(htranslate,I);

function Y = filter_img(X,i,j)

% Derive the sign of i
x_sign = sign(i);
% Derive the sign of j
y_sign = sign(j);

x_mag  = abs(i);
y_mag  = abs(j);

Y = X;

if x_sign == -1
    idx_x = size(X,2) - x_mag + 1:size(X,2);
elseif x_sign == 1
    idx_x = 1:x_mag;
else 
    idx_x = [];
end

Y(:,idx_x) = -1;

if y_sign == -1
    idx_y = size(X,1) - y_mag + 1:size(X,1);
elseif y_sign == 1
    idx_y = 1:y_mag;
else 
    idx_y = [];
end

Y(idx_y,:) = -1;

function Y = prune(X, idx_prune)

Y = X;

N = size(idx_prune,2);

for n = 1:N
    Y{idx_prune(n)} = [];
end

function idx_prune = test_patch(HR_patch)

% Derive the number of patches
N = size(HR_patch,1);

idx_prune = [];
i = 1;
for n = 1:N
    if sum(sum(find(HR_patch{n} == -1))) > 0
        idx_prune(i) = n;
        i = i + 1;
    end
end

