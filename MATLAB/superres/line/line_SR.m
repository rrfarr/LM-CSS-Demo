function Ys = line_SR(Xs, SR_config)
% This code is an interface to the LINE super resolution algorithm provided
% by the same authors.

% Derive the parameters for LINE
tau         = SR_config.tau;       % locality regularization
K           = SR_config.K_neighbours;
maxiter     = SR_config.maxiter;   % the maximum iteration number

% Derive the low resolution patch size
LR_patch_size = SR_config.SR_dictionary.LR_patches.patch_size;
LR_overlap    = SR_config.SR_dictionary.LR_patches.overlap;
HR_patch_size = SR_config.SR_dictionary.HR_patches.patch_size;
HR_overlap    = SR_config.SR_dictionary.HR_patches.overlap;

% Derive the low resolution traiming patches
lr_training_patches = SR_config.SR_dictionary.LR_patches.img_patches;
hr_training_patches = SR_config.SR_dictionary.HR_patches.img_patches;

% Derive the dimensions of a high resolution face image
res = size(SR_config.SR_dictionary.HR_face{1});

% Decompose the low resolution test image into overlapping patches
xs = img2patch(Xs, LR_patch_size, LR_overlap);

% Upsample the image to the required resolution
Xb = imresize(Xs,res,'bicubic');

% Convert the bi-cubic interpolated image to patches
xb = img2patch(Xb,  HR_patch_size, HR_overlap);

% Derive the number of patches
N = size(xs,1);

% Initialize the output patch list
y = cell(size(xs));

for j = 1:N
    %% Training the patch model LR
    % Extract the jth patch
    xj = double(xs{j}); % This is the low resolution patch
    
    % Derive the corresponding bi-cubic interpolated patch
    bj = double(xb{j});
    
    % This is a 1 dimensional representation of  the low resolution patch
    % to be hallucinated
    im_l_patch = reshape(xj, size(xj,1)*size(xj,2),1);
    
    % Derive the bicubic interpolated patch
    im_b_patch = reshape(bj, size(bj,1)*size(bj,2),1);
    
    % Derive the matrix of the corresponding high res patches
    XHP = Reshape3D(hr_training_patches,j);    % reshape each patch of HR face image to one column
    
    % Derive the matrix of the corresponding low resolution patches
    XLP = Reshape3D(lr_training_patches,j);
    
    % Compute the LINE to recover the optimal high resolution patch using
    % LINE
    [~, neighborhood, w] = LINE(im_l_patch, im_b_patch, XLP, XHP, tau, K, maxiter); 

    yj =  round(XHP(:,neighborhood)*w);
    
    % Round the patch
    yj = round(yj);
    
    % Put the reshaped patch in the list of patches of high res
    y{j} = reshape(yj, HR_patch_size, HR_patch_size);
end

if strcmp(SR_config.stitch_method,'Average')
    % Convert the set of patches to image using the averaging of
    % overlapping regions
    Ys = patch2img(y, res, HR_patch_size, HR_overlap);
end

function X = Reshape3D(img_patch,idx)

% Derive the number of training images
Nimgs = size(img_patch,1);

% Derive the number of pixelss within a patch
Npel = size(img_patch{1}{1},1) * size(img_patch{1}{1},2);

% Initialize the image patch matrix
X = zeros(Npel,Nimgs);

for n = 1:Nimgs
    % Derive the current patch
    xjs = img_patch{n}{idx};
    
    % Reshape the patch
    X(:,n) = reshape(xjs,size(xjs,1)*size(xjs,2),1);
end
