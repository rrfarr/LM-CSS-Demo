function Ys = BPAD_RR_SR(Xs, SR_config)
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

% Load the regularization parameter
delta = SR_config.param.delta;
Smin   = SR_config.param.Smin;
tau    = SR_config.param.tau;
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
    
    %------------------------------
    % STANDARDIZATION
    %------------------------------
    % Standardize the low resolution dictionary
    [L, mu_L, sig_L] = standardize(L);
    
    % Standardize the high resolution dictionary
    H = standardize(H, mu_L, sig_L);
    
    % Standardize the input patch
    [xp_s, mu_X, sig_X] = standardize(xp);
    
    % Compute the projection matrix using all elements in the dictionary
    Phi_tilda = H * L' / (L * L' + lambda*eye(size(L,1)));
    
    % Hallucinate the low resolution patch
    yp_s_tilda = Phi_tilda * xp_s;
    
    % Derive the indexes using sparse coding
    idx_SC = sparselab_BP(H,yp_s_tilda,delta,tau,Smin);
    
    % Derive the low resolution sub_dictionary
    L_kappa = L(:,idx_SC);
    % Derive the coupled high resolution sub_dictionary
    H_kappa = H(:,idx_SC);

    % Compute the projection matrix using the sub-dictionary
    Phi_kappa = H_kappa * L_kappa' / (L_kappa * L_kappa' + lambda*eye(size(L_kappa,1)));
    
    % Compute the super-resolution process using Phi_k
    yp = round((Phi_kappa * xp_s) * sig_X + mu_X);
    
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

function [idx,sols] = sparselab_BP(H, yp_s, delta,tau,Smin)
% Normalize the column vectors
A = H./repmat(sqrt(sum(H.^2,1)),[size(H,1),1]);
% Normalize the test point
y = yp_s/norm(yp_s,2);

N = size(A,2);
% Invoke the sparselab implementation of OMP
%sols = SolveBP(A,y,N,20,delta);
evalc('sols = SolveBP(A,y,N,20,delta)');

% Derive the total energy
energy = sum(abs(sols));

% Derive the index
[~,idx_sort] = sort(abs(sols),'descend');

cum_energy = 0;
for i = 1:size(idx_sort,1)
    % Accumulate the energy
    cum_energy = cum_energy + abs(sols(idx_sort(i)));
    
    % Derive the energy ratio
    ratio = cum_energy / energy;
    
    if ratio >= tau && i >= Smin
        idx = idx_sort(1:i);
        break;
    end
end

