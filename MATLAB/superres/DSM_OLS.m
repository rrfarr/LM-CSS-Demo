function IH = DSM_OLS(xl,SR_config)

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
ys = salep_v2_patch(xs, lr_training_patches, hr_training_patches);

if strcmp(SR_config.stitch_method,'Average')
    % Convert the set of patches to image using the averaging of
    % overlapping regions
    Ys = patch2img(ys, dim, HR_patch_size, HR_overlap);
end

% Compute the reprojection
IH = uint8(Ys); %reprojection(Ys_star, xl);

function y = salep_v2_patch(x, LR_patches, HR_patches)
% This method will derive the orthonormal proejections that can be used to
% project the low resolution face image onto a low-dimensional patch
% sub-space and the high resolution face image onto the high-dimensional
% subspace. These subspaces are then aligned using leat squares
% optimization to preserve the global structure of the manifolds. Then high
% resolution patch is then approximated from the approximated projected
% low-dimensional subspace to the high-dimensional subspace directly.
% 
% Designed: Reuben Farrugia
% Date: 06/05/2015
%

% Define the number of patches to consider
K = 1000;

% Derive the number of patches
N = size(x,1);

% Initialize the output patch list
y = cell(size(x));

for j = 1:N
    
    %% Training the patch model LR
    % Extract the jth patch
    xj = double(x{j});
    
    % Derive the dimensions of xj which give the patch size
    patch_size_lr = size(xj,1);
    
    patch_size_hr = size(HR_patches{1}{1},1);
    
    % Convert the input patch to a vector
    xj = reshape(xj, patch_size_lr*patch_size_lr,1);
    
    % Initialize the low resolution vector
    Lv = [];

    % Initialize the high resolution vector
    Hv = [];
    
    % Re-set the number of patches to be considered
    M = size(LR_patches,1);
    
    k = 1;
    for i = 1:M
        if ~isempty(HR_patches{i}{j}) && ~isempty(LR_patches{i}{j})
            % Derive the low res patch
            Lv(:,k) = double(reshape(LR_patches{i}{j}, patch_size_lr*patch_size_lr,1));

            % Derive the high res patch
            Hv(:,k) = double(reshape(HR_patches{i}{j}, patch_size_hr*patch_size_hr,1));
        
            k = k + 1;
        end        % Derive the low res patch
    end
    % -----------------------------------------------------
    %  Derive the orthonormal projections to project the 
    %  low resolution patch on the low dimensional subspace
    % -----------------------------------------------------
    % Derive the mean patch
    M_l = mean(Lv,2);    
    
    % Compute the variance of the low and high dimensions
    S_l = std(Lv,0,2); S_l(S_l ==0) = 1;

    % Derive the mean patch
    M_h = mean(Hv,2);    
    
    S_h = std(Hv,0,2); S_h(S_h ==0) = 1;
    
    % Derive the new size of L and H
    M = size(Lv,2);
    
    % The low resolution vectors are standardized [0 mean unit variance]
    L = (Lv - repmat(M_l,[1,M]))./ repmat(S_l,[1,M]);

    % The high resolution vectors are standardized [0 mean unit variance]
    H = (Hv - repmat(M_h,[1,M]))./ repmat(S_h,[1,M]);
    
    % Standardize the low resolution patch xj
    xj = (xj - M_l)./S_l;
    
    % Derive the K-nearest neighbours indices
    indx_neigh = k_nearest_neigh(L,xj,K);

    % Choose the K closest neighbours to find optimal weights
    L = L(:,indx_neigh);
    H = H(:,indx_neigh);

    % Derive the optimal weights in terms of Least Squares
    Phi_OLS = H * L'* pinv(L * L');

    % approximate the solution
    yj = round(S_h.*(Phi_OLS * xj) + M_h);
    
    % Put the reshaped patch in the list of patches of high res
    y{j} = reshape(yj, patch_size_hr, patch_size_hr);
end

function indx = k_nearest_neigh(L,x,K)

% Derive the dimensions of L
M = size(L,2);

% Compute the distance between x and L
d = mean((repmat(x,[1,M]) - L).^2,1);

% Derive the index
[~, indx] = sort(d,'ascend');

% Derive the K nearest neighbour index
indx = indx(1:K);




