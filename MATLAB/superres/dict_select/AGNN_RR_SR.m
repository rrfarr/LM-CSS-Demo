function Ys = AGNN_RR_SR(Xs, SR_config)
% The AGNN_RR_SR super-resolution method tries to find the closest
% neighbours by exploiting the geometric structure of the manifold modelled
% by the A_star graph. The resulting neighbourhood of samples will be used
% to infer the high resolution patch using Ridge Regression.
%
% Designed: Reuben Farrugia
% Date:     18/9/2015

% Configuration
lambda = 1E-6;

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
    
    % Extract the A_star graph modelling the manifold
    A_star = SR_config.sub_dict_data{p}.A_star;
    
    % Initialize the affinity vector
    a = zeros(N,1);
    
    % Compute the affinity between the input sample and the dictionary L
    for i=1:N
        a(i)=exp(- norm(xp-L(:,i))/(N*SR_config.AGNNparam.sigmaDist) );
    end
    % Initialize the diffused matrix equal to the affinity 
    a_star = a;
    
    % Diffuse the affinities
    for k=1:SR_config.AGNNparam.Kappa;
        a_star=A_star*a_star;
    end

    % Sort the affinities in descending order
    [a_star_sort, ind_sort]=sort(a_star, 'descend');

    % Determine the number of neighbours to be selected
    K = max(SR_config.AGNNparam.minP, find(a_star_sort < max(a_star_sort)*SR_config.AGNNparam.Tau,1,'first' ));
    
    % Choose the low resolution sub-dictionary
    Lsub = L(:,ind_sort(1:K));
    
    % Choose the high resolution sub-dictionary
    Hsub = H(:,ind_sort(1:K));
    
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
