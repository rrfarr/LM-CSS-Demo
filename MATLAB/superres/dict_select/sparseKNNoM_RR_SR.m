function Ys = sparseKNNoM_RR_SR(Xs, SR_config)
% Compute nearest neighbour selection using Iterated Graph Laplacian
% which gives a rank of the closest neighbours. The optimal number of
% neighbours are derived using a greedy iterative method which exploits
% the neighbour ranking.
%
% Designed: Reuben Farrugia
% Date:     25/9/2015

% Configuration
lambda = SR_config.param.lambda;

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
    Kmax  = SR_config.param.Kmax;
    A     = SR_config.param.A{p};
    mu    = SR_config.param.mu{p};
    tau   = SR_config.param.tau;
    
    % Compute KNN on the manifold
    idx = KNN_on_Manifold_2(xp, L, A, mu, beta, m, size(A,1));
    
    % Find the optimal number of neighbours
    idx = sparse_neighbour_selection(xp,L,H,idx,Kmin,Kmax,lambda,tau);
    
    % Choose the low resolution sub-dictionary
    Lsub = L(:,idx);
    
    % Choose the high resolution sub-dictionary
    Hsub = H(:,idx);
    
    % Derive the optimal weights using ridge regression
    Phi_k = Hsub * Lsub' / (Lsub * Lsub' + lambda * eye(size(Lsub,1)));
    
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

function    idx = sparse_neighbour_selection(xp,L,H,idx,Kmin,Kmax,lambda, tau)

% Derive the projection matrix using the entire dictionary
Phi_tilda = H * L' / (L * L' + lambda * eye(size(L,1)));

% Approximate the high-resolution patch using the whole dictionary
y_tilda = round(Phi_tilda * xp);

% Derive the list of Ks to consider
K_list = Kmin:10:Kmax;

for k = K_list
    % Choose the low resolution sub-dictionary using the closest k
    % neighbors
    Lsub = L(:,idx(1:k));
    
    % Choose the high resolution sub-dictionary using the closest k
    % neighbors
    Hsub = H(:,idx(1:k));
    
    % Derive the projection matrix using the closest k neighbors
    Phi_k = Hsub * Lsub' / (Lsub * Lsub' + lambda * eye(size(Lsub,1)));
    
    % Derive the approximated yp
    y_k = Phi_k * xp;
    
    % Determine the error using the fist k neighbors
    e = mean2((y_tilda - y_k).^2);
    
    if e < tau
        % Derive the optimal neighbours
        Kopt = k;
        
        % Return the indeces of the selected neighbours
        idx = idx(1:Kopt);
        
        return;
    end
    
end


