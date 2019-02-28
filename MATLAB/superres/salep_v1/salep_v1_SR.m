function IH = salep_v1_SR(xl,SR_config)

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
ys = salep_v1_patch(xs, lr_training_patches, hr_training_patches);

if strcmp(SR_config.stitch_method,'Average')
    % Convert the set of patches to image using the averaging of
    % overlapping regions
    Ys = patch2img(ys, dim, HR_patch_size, HR_overlap);
end

% Compute the reprojection
IH = uint8(Ys); %reprojection(Ys_star, xl);

function y = salep_v1_patch(x, l, h)
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

for j = 1:N
    
    %% Training the patch model LR
    % Extract the jth patch
    xj = double(x{j});
    
    % Derive the dimensions of xj which give the patch size
    patch_size_lr = size(xj,1);
    
    patch_size_hr = size(h{1}{1},1);
    
    % Convert the input patch to a vector
    xj = reshape(xj, patch_size_lr*patch_size_lr,1);
    
    % Initialize the low resolution vector
    Lv = zeros(patch_size_lr*patch_size_lr,M);

    % Initialize the high resolution vector
    Hv = zeros(patch_size_hr*patch_size_hr,M);
    
    for i = 1:M
        % Derive the low res patch
        lij = double(reshape(l{i}{j}, patch_size_lr*patch_size_lr,1));
        
        hij = double(reshape(h{i}{j}, patch_size_hr*patch_size_hr,1));
        % Derive the high res patch
        % Put this patch as vector for low reslution patches
        Lv(:,i) = lij;
        % Derive the high resolution patch vector
        Hv(:,i) = hij;
    end
    % -----------------------------------------------------
    %  Derive the orthonormal projections to project the 
    %  low resolution patch on the low dimensional subspace
    % -----------------------------------------------------
    % Derive the mean patch
    M_l = mean(Lv,2);    
    
    % Derive the difference vector L
    L = Lv - repmat(M_l,[1,M]);

    % Derive the mean patch
    M_h = mean(Hv,2);    
    
    % Derive the difference vector L
    H = Hv - repmat(M_h,[1,M]);

%    % Compute the covariance matrix
%    C_l = L'*L;
    
%    % Derive the eigen values and eigenvectors of the covariance matrix
%    [Evector_l,Evalue_l] = eig(C_l);

%    % Derive the eigenvectors and eigenvalues that cover 99% of the variance
%    [V_l,D_l] = eigenvector_selection(Evector_l,diag(Evalue_l),0.999999);
    
%    % Derive the Eigenfaces
%    E_l = L * V_l * diag(1./sqrt(D_l));

    [U, S, V] = svd(L);
    
    beta =  H * L' *pinv(L * L');

%     % -----------------------------------------------------
%     %  Derive the orthonormal projections to project the 
%     %  high resolution patch on the high dimensional subspace
%     % -----------------------------------------------------
%      % Derive the mean patch
%     M_h = mean(Hv,2);    
%     
%     % Derive the difference vector L
%     H = Hv - repmat(M_h,[1,M]);
%     
%     % Compute the covariance matrix
%     C_h = H'*H;
%     
%     % Derive the eigen values and eigenvectors of the covariance matrix
%     [Evector_h,Evalue_h] = eig(C_h);
% 
%     % Derive the eigenvectors and eigenvalues that cover 99% of the variance
%     [V_h,D_h] = eigenvector_selection(Evector_h,diag(Evalue_h));
%     
%     % Derive the Eigenfaces
%     E_h = H * V_h * diag(1./sqrt(D_h));
%    
%     % Project the low res training patches on the low-dimensional subspace
%     w_l = E_l' * L;
% 
%     % Project the high res training patches on high-dimensional subspace
%     w_h = E_h' * H;
%     
%     % Compute the low- to high- dimensional transformation
%     phi = w_h * w_l' / (w_l * w_l');
% 
%     % Transform the low resolution patch onto the high dimensional
%     % sub-space
%     w_h_ = phi*E_l'*(xj - M_l);

    yj = round(beta * (xj - M_l) + M_h);
    
    % Put the reshaped patch in the list of patches of high res
    y{j} = reshape(yj, patch_size_hr, patch_size_hr);
end



