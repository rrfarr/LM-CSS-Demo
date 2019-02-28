function Ys = kmeans_OLS_SR_1(Xs, SR_config)
% This function computes multilinear regression method. The kmeans
% clustering method is used for dictionary selection and the appropriate
% sub-dictionary is used for super-resolution
%
% Designed: Reuben Farrugia
% Date:     10/9/2015

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
    
    % Standardize the low resolution dictionary
    [L, mu_L, sig_L] = standardize(L);
    
    % Standardize the high resolution dictionary
    H = standardize(H, mu_L, sig_L);
    
    % Standardize the input patch
    [xp_s, mu_X, sig_X] = standardize(xp);
    
    % Derive the pre-computed centroids
    C = SR_config.sub_dict_data{p}.centroids;
    
    % Derive the indices of the clustered dictionaries
    idx = SR_config.sub_dict_data{p}.cluster_idx;
    
    % Get the closest centroid to xp_s
    k = get_cluster_idx(xp_s,C);
    
    % Choose the low resolution sub-dictionary
    Lsub = L(:,idx == k);
    
    % Choose the high resolution sub-dictionary
    Hsub = H(:,idx == k);
    
    % Derive the optimal weights using ordinary least squares regression
    Phi_k = Hsub * Lsub' * pinv(Lsub * Lsub');
    
    % Compute the super-resolution process using Phi_k
    yp = round((Phi_k * xp_s) * sig_X + mu_X);
    
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
end
