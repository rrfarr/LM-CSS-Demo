function Ys = sparseNEoM_RR_SR(Xs, SR_config)
% Compute nearest neighbour selection using Iterated Graph Laplacian
% which gives a rank of the closest neighbours. The optimal number of
% neighbours are derived using a greedy iterative method which exploits
% the neighbour ranking.
%
% Designed: Reuben Farrugia
% Date:     25/9/2015

% Extract the lagrange multipliers
lambda1 = SR_config.param.lambda1; % Regression regularization
lambda2 = SR_config.param.lambda2; % Model regularization

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
    
    % Determine the configuration parameters
    beta  = SR_config.param.beta;
    m     = SR_config.param.m;
    Kmin  = SR_config.param.Kmin;
    A     = SR_config.param.G{p};
    mu    = SR_config.param.mu{p};
    tau   = SR_config.param.tau;
    
    % Derive the index of the closest neighbours to xp 
    idx = KNN_on_Manifold_2(xp, L, A, mu, beta, m, size(A,1));
    
    % Find the optimal number of neighbours
    idx = sparse_neighbour_embedding(L,H,idx,Kmin,lambda1, lambda2,tau);
    
    % Choose the low resolution sub-dictionary
    Lsub = L(:,idx);
    
    % Choose the high resolution sub-dictionary
    Hsub = H(:,idx);
    
    % Derive the optimal weights using ridge regression
    Phi_k = Hsub * Lsub' / (Lsub * Lsub' + lambda1 * eye(size(Lsub,1)));
    
    % Compute the super-resolution process using Phi_k
    yp = round(Phi_k * xp);
    
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

function    idx_opt = sparse_neighbour_embedding(L,H,idx,Kmin,lambda1, lambda2,tau)

% Derive the projection matrix using the entire dictionary. This will be
% used as an approximation
Phi_tilda = H * L' / (L * L' + lambda1 * eye(size(L,1)));

for k = Kmin:size(L,2)
    % Determine the first k entries in L
    Lkappa = L(:,idx(1:k));
    
    % Determine the first k entries from the dicitonary
    Hkappa = H(:,idx(1:k));
    
    % Derive the projection matrix using the closest k neighbors
    Phi_kappa = (Hkappa * Lkappa' + lambda2 * Phi_tilda) / (Lkappa * Lkappa' + lambda2 * eye(size(Lkappa,1)));

    % Compute the MSE between Phi_kappa and Phi_tilda
    e = mean2((Phi_kappa - Phi_tilda).^2);
    
    if e < tau
        % Return the indeces of the selected neighbours
        idx_opt = idx(1:k);
        
        return;
    end
end


