function [Nx,Nidx] = k_nearest_neighbors(x,lr_img_patch,k,K)

% Derive the number of neighbors available
N = size(lr_img_patch,1);

% Derive the number of patches
Np = size(lr_img_patch{1}{1},1) * size(lr_img_patch{1}{1},2);

% Initialize a matrix that will contain all the patches
lr_img_list = zeros(Np,N);

% Initialize a distance matrix
d = zeros(N,1);

for n = 1:N
    % Put the current patch in the list
    lr_img_list(:,n) = reshape(lr_img_patch{n}{k},Np,1);
    
    % Compute the distance between the training and testing
    d(n,1) = norm(lr_img_list(:,n) - reshape(x,Np,1),2);
end

% Sort based on the smallest euclidean distance
[~, idx_neigh] = sort(d,'ascend');

% Select the first K neighbors
Nx = lr_img_list(:,idx_neigh(1:K));

% Return the indices used
Nidx = idx_neigh(1:K);