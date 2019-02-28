function Ys = neighbor_embedding_SR(Xs, SR_config)
% This function computes the neighbor embedding process to hallucinate a
% high resolution face image IH from the low resolution image LR

% Derive the low resolution patch and overlap size
LR_patch_size = SR_config.SR_dictionary.LR_patches.patch_size;
LR_overlap    = SR_config.SR_dictionary.LR_patches.overlap;
HR_patch_size = SR_config.SR_dictionary.HR_patches.patch_size;
HR_overlap    = SR_config.SR_dictionary.HR_patches.overlap;

% Derive the low resolution traiming patches
lr_training_patches = SR_config.SR_dictionary.LR_patches.img_patches;
hr_training_patches = SR_config.SR_dictionary.HR_patches.img_patches;

% Derive the number of neighbors
K = SR_config.K_neighbours;

% Decompose the low resolution test image into overlapping patches
xs = img2patch(Xs, LR_patch_size, LR_overlap);

% Derive the number of patches
N = size(xs,1);

% Initialize the output patch list
y = cell(size(xs));

for j = 1:N
    %% Training the patch model LR
    % Extract the jth patch
    xj = double(xs{j});
    
    % Derive the K nearest neighbors of xj
    [Nxj, Nidx] = k_nearest_neighbors(xj,lr_training_patches,j,K);
    
    % Derive the weights using the constrained least squares
    %wq = sum1_LS(xj, Nxj);
    wq = optimal_weights_NE(xj, Nxj);
    
    % Initialize the jth high resolution patch
    yj = zeros(HR_patch_size,HR_patch_size);

    % Use these weights to approximate y
    for n = 1:size(Nidx,1)
        % Extract the high resolution patch to be considered
        ypj = double(hr_training_patches{Nidx(n)}{j});
        
        % Compute the weighted summation
        yj = yj + wq(n)*ypj;
    end
    % Round the patch
    yj = round(yj);
    
    % Put the reshaped patch in the list of patches of high res
    y{j} = reshape(yj, HR_patch_size, HR_patch_size);
end

% Derive the dimensions of a high resolution face image
dim = size(SR_config.SR_dictionary.HR_face{1});

if strcmp(SR_config.stitch_method,'Average')
    % Convert the set of patches to image using the averaging of
    % overlapping regions
    Ys = patch2img(y, dim, HR_patch_size, HR_overlap);
end