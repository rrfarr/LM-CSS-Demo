function Ys = PP_SR(Xs, SR_config)
% This function computes sparse nearest neighbour with ridge regression.
% This method first derives the linear projection matrix using all entries
% in the dictionary and uses this projection to approximate the high
% resolution patch. This hallucinated patch is then used to find the
% k sparse support which can be used to represent the hallucinated patch.
% The final hallucinated patch is derived by the refined projection matrix
% which uses the support column vectors for prediction.
%
% Designed: Reuben Farrugia
% Date:     15/10/2015

% Derive the low resolution patch and overlap size
LR_patch_size = SR_config.SR_dictionary.LR_patches.patch_size;
LR_overlap    = SR_config.SR_dictionary.LR_patches.overlap;
HR_patch_size = SR_config.SR_dictionary.HR_patches.patch_size;
HR_overlap    = SR_config.SR_dictionary.HR_patches.overlap;

% Derive the low resolution traiming patches
lr_training_patches = SR_config.SR_dictionary.LR_patches.img_patches;
hr_training_patches = SR_config.SR_dictionary.HR_patches.img_patches;

% Decompose the low resolution test image into overlapping patches
xs = img2patch(Xs, LR_patch_size, LR_overlap);

% Derive the number of patches
P = size(xs,1);

% Derive the number of images
N = size(lr_training_patches,1);

% Initialize the output patch list
y = cell(size(xs));

for p = 1:P
    % Extract the pth patch and convert it to a vector
    xp = reshape(double(xs{p}), LR_patch_size*LR_patch_size,1);

    % Initialize the low resolution dictionary
    L = zeros(LR_patch_size*LR_patch_size,N);

    % Initialize the high resolution dictionary
    H = zeros(HR_patch_size*HR_patch_size,N);
 
    % Load the low- and high- resolution dictionaries
    for n = 1:N
        % Extract the pth low resolution patch from the nth image
        L(:,n) = double(reshape(lr_training_patches{n}{p}, LR_patch_size*LR_patch_size,1));
        
        % Extract the pth high resolution patch from the nth image
        H(:,n) = double(reshape(hr_training_patches{n}{p}, HR_patch_size*HR_patch_size,1));
    end
    
    % Compute the projection matrix using all elements in the dictionary
    w = optimal_weights_NE(xp, L);
    
    % Compute the super-resolution process using Phi_k
    yp = round(H * w);
    
    % Reshape the vector and put it in the patch list of the hallucinated
    % patches
    y{p} = reshape(yp, HR_patch_size, HR_patch_size);
end

% Derive the dimensions of a high resolution face image
dim = size(SR_config.SR_dictionary.HR_face{1});

if strcmp(SR_config.stitch_method,'Average')
    % Convert the set of patches to image using the averaging of
    % overlapping regions
    Ys = patch2img(y, dim, HR_patch_size, HR_overlap);
elseif strcmp(SR_config.stitch_method,'Quilting')
    % Convert the set of patches to image using the quilting method of
    % Efros and Freeman
    Ys = patch2imgQuilting(y,dim,HR_patch_size,HR_overlap);
end
