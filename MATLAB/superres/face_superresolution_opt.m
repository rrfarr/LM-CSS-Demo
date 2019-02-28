function [IH, t_elapsed, stat] = face_superresolution_opt(LR, SR_config)
% This is a mother function which receives the low resolution image and the
% other information in the structure SR_config. This method will call the
% super-resolution algorithm based on the information included in the
% configuration file. This function also returns the time (in seconds)
% taken to hallucinate one single face image.
%
% Designed: Reuben Farrugia
% Data: 27/2/2015
%

% Derive the dimensions of the high resolution image
H_hr = SR_config.HR_img.H;
W_hr = SR_config.HR_img.H;

% Derive the cputime at which it strats processing the image
hall_start = tic;

stat = [];
% Compute the super-resolution algorithm
if strcmp(SR_config.SR_method,'BC')
    % Compute the bi-cubic interpolation
    IH = bicubic_interpolation(LR,[H_hr,W_hr]);
elseif strcmp(SR_config.SR_method,'ET')
    % Compute the eigentransformation super-resolution
    IH = eigentransformation_SR(LR,SR_config.SR_dictionary);
elseif strcmp(SR_config.SR_method,'NE')
    % Compute the neighbor embedding super-resolution
    IH = neighbor_embedding_SR(LR, SR_config);
elseif strcmp(SR_config.SR_method,'LINE')
    % Compute the LINE super-resolution of face images
    IH = line_SR(LR, SR_config);
elseif strcmp(SR_config.SR_method,'EP')
    % Compute the Eigen-Patch super-resolution of face images
    IH = eigenpatches_SR(LR,SR_config);
%elseif strcmp(SR_config.SR_method,'EP-RR')
%    [IH, stat] = eigenpatches_SR(LR, SR_config);
elseif strcmp(SR_config.SR_method,'OLS')
    % Compute the Ordinary Least Squares Regression
    IH = MVLM_SR(LR, SR_config,'OLS');
elseif strcmp(SR_config.SR_method,'kmeans_OLS')
    % Compute Multilinear OLS using the sub-dictionaries derived using
    % kmeans
    IH = kmeans_OLS_SR(LR,SR_config);
elseif strcmp(SR_config.SR_method,'kmeans_lbp_OLS_1')
    % Compute Multilinear Linear regression using the lbp texture features
    IH = kmeans_lbp_OLS_SR_1(LR,SR_config);
elseif strcmp(SR_config.SR_method, 'AGNN_RR')
    % Compute nearest neighbour selection using AGNN and super resolve
    % using ridge regression
    IH = AGNN_RR_SR(LR, SR_config);
elseif strcmp(SR_config.SR_method, 'RoM_RR')
    % Compute nearest neighbour selection using the extended AGNN and super
    % resolve using ridge regression
    IH = RoM_RR_SR(LR, SR_config);
elseif strcmp(SR_config.SR_method,'IGL_RoM_RR')
    % Compute nearest neighbour selection using the Iterated Graph
    % Laplacian approach to derive the K nearest neighbours on the manifold
    % and then use Ridge Regression to hallucinated the high resolution
    % patch
    IH = IGL_RoM_RR_SR_opt(LR, SR_config);
end

% Derive the elapsed time
t_elapsed = toc(hall_start);




