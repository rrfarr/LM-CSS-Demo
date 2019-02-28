function [y, c_actual, c_rr] = eigentransformation_patch(x, l, h, model, model_str)

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
    
    % Derive the mean patch
    M_l = mean(Lv,2);    
    
    % Derive the difference vector L
    L = Lv - repmat(M_l,[1,M]);
    
    % Compute the covariance matrix
    C = L'*L;
    
    % Derive the eigen values and eigenvectors of the covariance matrix
    [Evector,Evalue] = eig(C);

    % Derive the eigenvectors and eigenvalues that cover 99% of the variance
    [V,D] = eigenvector_selection(Evector,diag(Evalue),0.99999);
    
    % Derive the Eigenfaces
    E = L * V * diag(1./sqrt(D));

    % Derive the projection parameters
    w = E'*(xj - M_l);

    % Derive the weights
    c = V * diag(1./sqrt(D))* w;
    
    % Put this as the projection weights on LR
    c_actual{j} = c; 
    
    if nargin > 3
        % Improve the projection weight correlation
        c = weight_alignment(c,model{j},model_str);
        
        % Put this as enhanced projection weight using ridge regression
        c_rr{j} = c;
    end
    
    % Derive the mean of the high resolution patches
    M_h = mean(Hv,2);
    
    % Derive the difference vector H at high resolution
    H = Hv - repmat(M_h,[1,M]);
    
    % Reconstruct the high resolution image
    yj = round(H * c + M_h);

    % Put the reshaped patch in the list of patches of high res
    y{j} = reshape(yj, patch_size_hr, patch_size_hr);
end

function Y = weight_alignment(X,model,model_str)
if strcmp(model_str,'RR')
    % Derive the beta parameters
    beta = model.beta;
    % Compute the weight alignment
    Y = (X' * beta)';
end