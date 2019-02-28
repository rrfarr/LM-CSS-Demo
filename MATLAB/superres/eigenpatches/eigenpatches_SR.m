function [IH, stat] = eigenpatches_SR(xl,SR_config)

xl = double(xl);

% Derive information from the configuration structure
search_range = SR_config.search_range;

% Derive the low resolution patch and overlap size
LR_patch_size = SR_config.SR_dictionary.LR_patches.patch_size;
LR_overlap    = SR_config.SR_dictionary.LR_patches.overlap;
HR_patch_size = SR_config.SR_dictionary.HR_patches.patch_size;
HR_overlap    = SR_config.SR_dictionary.HR_patches.overlap;

% Derive the low resolution traiming patches
lr_training_patches = SR_config.SR_dictionary.LR_patches.img_patches;
hr_training_patches = SR_config.SR_dictionary.HR_patches.img_patches;

% Initialize the temporary output cell
Ys = cell(2*search_range+1,2*search_range+1);

% Derive the dimensions of a high resolution face image
dim = size(SR_config.SR_dictionary.HR_face{1});

% Compute the Eigen-Patch Method
for sh = -search_range:search_range
    for sv = -search_range:search_range
        % Derive the shifted image Xs
        Xs = image_shift(xl,sh,sv);
        % Decompose the low resolution shifted image into overlapping
        % patches
        xs = img2patch(Xs, LR_patch_size, LR_overlap);
        
        if isfield(SR_config,'model')
            % Derive the weights using the eigentransformation
            [ys, c_lr_actual, c_rr] = eigentransformation_patch(xs, lr_training_patches, hr_training_patches, SR_config.model, SR_config.model_str);
            
            if isfield(SR_config,'IHR')
                c_hr_actual = eigentransformation_hr_patch(SR_config.IHR, hr_training_patches, SR_config);
                
                % Derive the correlation between low resolution and high
                % resolution
                [corr_direct,rmse_direct, norm_direct, norm_actual] = corr_cell(c_lr_actual, c_hr_actual);
                
                stat.corr_direct = corr_direct;
                stat.rmse_direct = rmse_direct;
                
                % Derive the correlation using ridge regression
                [corr_rr, rmse_rr, norm_rr]     = corr_cell(c_rr, c_hr_actual);
                
                stat.corr_rr = corr_rr;
                stat.rmse_rr = rmse_rr;
                stat.norm_direct = norm_direct;
                stat.norm_actual = norm_actual;
                stat.norm_rr = norm_rr;
            end
        else
            % Derive the weights using the eigentransformation
            ys = eigentransformation_patch(xs, lr_training_patches, hr_training_patches);
        end
        if strcmp(SR_config.stitch_method,'Average')
            % Convert the set of patches to image using the averaging of
            % overlapping regions
            Ys{sh+search_range+1,sv+search_range+1} = patch2img(ys, dim, HR_patch_size, HR_overlap);
        end        
    end
end

% Input Image Alignment
Ys_star = select_optimal_face(Ys,xl);

% Compute the reprojection
IH = uint8(Ys_star); %reprojection(Ys_star, xl);

function [C, rmse, normx, normy] = corr_cell(X,Y)

% Derive the number of images
N = size(X,2);

C_array = zeros(N,2);
mse_array = zeros(N,1);
norm_array_x = zeros(N,2);
norm_array_y = zeros(N,2);
for n = 1:N
    % Extract the x vector
    x = X{n};
    % Extract the y vector
    y = Y{n};
    
    % Compute the pearson correlation
    C_array(n,1) = corr(x,y,'type','Pearson');
    C_array(n,2) = corr(x,y,'type','Spearman');
    mse_array(n,1) = mean((x - y).^2);
    norm_array_x(n,1) = norm(x,1);
    norm_array_x(n,2) = norm(x,2);
    norm_array_y(n,1) = norm(y,1);
    norm_array_y(n,2) = norm(y,2);
end

C = mean(C_array);
rmse = sqrt(mean(mse_array));
normx = mean(norm_array_x);
normy = mean(norm_array_y);

function c_actual = eigentransformation_hr_patch(I, h, SR_config)

% Derive the number of images
M = size(h,1);

patch_size = SR_config.SR_dictionary.HR_patches.patch_size;
overlap    = SR_config.SR_dictionary.HR_patches.overlap;

% Convert the input image to patches
x = img2patch(I,patch_size,overlap);

% Derive the number of patches
N = size(x,1);

c_actual = cell(N,1);

for j = 1:N
    
    %% Training the patch model LR
    % Extract the jth patch
    xj = double(x{j});
    
    % Convert the input patch to a vector
    xj = reshape(xj, patch_size*patch_size,1);
    
    % Initialize the high resolution vector
    Hv = zeros(patch_size*patch_size,M);
    
    for i = 1:M
        % Derive the training high res patch
        hij = double(reshape(h{i}{j}, patch_size*patch_size,1));
        
        % Derive the high resolution patch vector
        Hv(:,i) = hij;
    end   
    % Derive the mean patch
    M_h = mean(Hv,2);    
    
    % Derive the difference vector L
    H = Hv - repmat(M_h,[1,M]);
    
    % Compute the covariance matrix
    C = H'*H;
    
    % Derive the eigen values and eigenvectors of the covariance matrix
    [Evector,Evalue] = eig(C);

    % Derive the eigenvectors and eigenvalues that cover 99% of the variance
    [V,D] = eigenvector_selection(Evector,diag(Evalue),0.99999);
    
    % Derive the Eigenfaces
    E = H * V * diag(1./sqrt(D));

    % Derive the projection parameters
    w = E'*(xj - M_h);

    % Derive the weights
    c = V * diag(1./sqrt(D))* w;

    % Put this as the projection weights on LR
    c_actual{j} = c; 
end