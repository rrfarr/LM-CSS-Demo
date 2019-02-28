function [PL, PH] = learn_cca_projections(HR_patches, LR_patches)
% This function will learn the canonical correlation analysis projection
% matrices to be able to project the low- and high- resolution vectors on a
% common sub-space.
% 
% Designed: Reuben Farrugia
% Date: 27/10/2015
%

% Determine the number of patches to be considered
P = size(HR_patches.img_patches{1},1);

% Derive the number of images
N = size(HR_patches.img_patches,1);

PL = cell(P,1);
PH = cell(P,1);

% Derive the low resolution patch and overlap size
LR_patch_size = LR_patches.patch_size;
HR_patch_size = HR_patches.patch_size;

for p = 1:P
    % Initialize the low resolution dictionary
    L = zeros(LR_patch_size*LR_patch_size,N);

    % Initialize the high resolution dictionary
    H = zeros(HR_patch_size*HR_patch_size,N);
 
    % Load the low- and high- resolution dictionaries
    for n = 1:N
        % Extract the pth low resolution patch from the nth image
        L(:,n) = double(reshape(LR_patches.img_patches{n}{p}, LR_patch_size*LR_patch_size,1));
        
        % Extract the pth high resolution patch from the nth image
        H(:,n) = double(reshape(HR_patches.img_patches{n}{p}, HR_patch_size*HR_patch_size,1));
    end
    
    %------------------------------
    % STANDARDIZATION
    %------------------------------
    % Standardize the low resolution dictionary
    [L, mu_L, sig_L] = standardize(L);
    
    % Standardize the high resolution dictionary
    H = standardize(H, mu_L, sig_L);
    
    % Compute the canonical correlation analysis
[   PH{p}, PL{p}] = canoncorr(H',L'); % Put it in the cell
end