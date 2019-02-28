function IH = MVLM_SR(xl,SR_config,method)

xl = double(xl);

% Derive the low resolution patch and overlap size
LR_patch_size = SR_config.SR_dictionary.LR_patches.patch_size;
LR_overlap    = SR_config.SR_dictionary.LR_patches.overlap;
HR_patch_size = SR_config.SR_dictionary.HR_patches.patch_size;
HR_overlap    = SR_config.SR_dictionary.HR_patches.overlap;

% Derive the low resolution traiming patches
lr_training_patches = SR_config.SR_dictionary.LR_patches.img_patches;
hr_training_patches = SR_config.SR_dictionary.HR_patches.img_patches;

% Derive the dimensions of a high resolution face image
dim = size(SR_config.SR_dictionary.HR_face{1});

% Derive the shifted image Xs
Xs = image_shift(xl,0,0);

% Decompose the low resolution shifted image into overlapping
% patches
xs = img2patch(Xs, LR_patch_size, LR_overlap);
        
% Derive the weights using the eigentransformation
ys = OLS_patch(xs, lr_training_patches, hr_training_patches, SR_config.dx, method);

if strcmp(SR_config.stitch_method,'Average')
    % Convert the set of patches to image using the averaging of
    % overlapping regions
    Ys = patch2img(ys, dim, HR_patch_size, HR_overlap);
end

% Compute the reprojection
IH = uint8(Ys); %reprojection(Ys_star, xl);

function y = OLS_patch(x, l, h,dx, method)
% This method will derive the orthonormal proejections that can be used to
% project the low resolution face image onto a low-dimensional patch
% sub-space and the high resolution face image onto the high-dimensional
% subspace. These subspaces are then aligned using least squares
% optimization to preserve the global structure of the manifolds. Then high
% resolution patch is then approximated from the approximated projected
% low-dimensional subspace to the high-dimensional subspace directly.
% 
% Designed: Reuben Farrugia
% Date: 06/05/2015
%
% Derive the number of images
M = size(l,1);

% Derive the number of patches
N = size(x,1);

% Initialize the output patch list
y = cell(size(x));

if strcmp(method,'OLS')
    % Derive the filename of the model
    model_filename = sprintf('MATLAB/MODELS/OLS/dx_%0.2d.MAT',dx);
elseif strcmp(method,'RR')
    % Derive the filename of the model
    model_filename = sprintf('MATLAB/MODELS/RR/dx_%0.2d.MAT',dx);
elseif strcmp(method, 'LASSO')
    % Derive the filename of the model
    model_filename = sprintf('MATLAB/MODELS/LASSO/dx_%0.2d.MAT',dx);
elseif strcmp(method, 'NRR')
    model_filename = sprintf('MATLAB/MODELS/NRR/dx_%0.2d.MAT',dx);
end

% Load the model parameters
load(model_filename);

for j = 1:N
    
    %% Training the patch model LR
    % Extract the jth patch
    xj = double(x{j});
    
    % Derive the dimensions of xj which give the patch size
    patch_size_lr = size(xj,1);
    
    patch_size_hr = size(h{1}{1},1);
    
    % Convert the input patch to a vector
    xj = reshape(xj, patch_size_lr*patch_size_lr,1);
    
    % Derive the mean patch and standard deviation of the patch
    M_l =  model{j}.scale_param.M_l;    
    S_l =  model{j}.scale_param.S_l;    
    
    % Derive the mean patch and standard deviation of the patch
    M_h = model{j}.scale_param.M_h; 
    S_h = model{j}.scale_param.S_h; 
    
    % Standardize the input sample
    xj = (xj - M_l)./S_l;

    % Derive the model parameters
    Phi = model{j}.Phi;

    % Derive the predicted high resolution sample
    yj = round(S_h.*(Phi * xj) + M_h);

    % Put the reshaped patch in the list of patches of high res
    y{j} = reshape(yj, patch_size_hr, patch_size_hr);
end



