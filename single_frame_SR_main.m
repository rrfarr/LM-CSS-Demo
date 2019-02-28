function single_frame_SR_main()
% The single_frame_SR_main() function is the main function through
% which a number of face super resolution algorithm can be evaluated. This
% function is the main function. This method generates a number of datasets
% that can be used to train various learning methods adopted in various
% stages of the respective algorithms. The purpose of this function is to
% be able to evaluate a number of face super-resolution methods found in
% literature and proposed methods on equal grounds.
%
% The single_frame_SR_main_v01_01 does not take any input or output and is
% controled using the configuration parameters specified at the beginning
% of this file. The current list of algorithms considered up till now are
%
% BC - Bicubic Interpolation
% NE - Neighbour-Embedding
% ET - EigenTransformation
% EP - EigenPatches
% LINE - The LINE algorithm
% OLS - Ordinary Least Squares
% 
% K-means OLS - K-means dictionary selection and OLS regression
% K-means_LBP OLS - K-means dictionary selection using LBP features and OLS
%                   regression
%                 # Method 1: Clustering using LBP vectors discriminated
%                 using Euclidean distance. Regression optimization
%                 function Phi = ||H - Phi L ||_2
% AGNN: Adaptive Geometry Driven Nearest Neighbor Search
% RoM_RR: This method computes KNN on the Manifold and then uses ridge
% regression for hallucination (based on Zhou 2004 Ranking on Data
% Manifolds Paper.
%
% IGL_RoM_RR: This method computes the KNN on the Manifold and then uses
% ridge regression for hallucination (based on hou 2011 Iterative Graph
% Laplacian for Ranking on Manifolds)
%
% sparseNN_RR: This method computes super resolution using the nearest
% neighbour method to find the closest neighbours K and computes linear
% ridge regression to hallucinate each patch. The low resolution patch are
% first hallucinated using all patches in the dictionary and used to find
% the K closest neighbours on the high resolution dicionary. 
% 
% KSS_RR: This method computers super resolution using a set of k sparse
% support column vectors that are optimal to reconstruct the high
% resolution patch. The optimality is achieved using sparse coding and
% solved using the Orthogonal Matching Pursuit greedy optimization
% algorithm.
%
% LM_CSS: This method employs basis pursuit to derive the atomic
% decomposition of the dictionary which best represent the test sample to
% he hallucinated. The final patch is then hallucinated using ridge
% regression.
%
% CCA_BP_RR: This method employs CCA to derive a common sub-space on which
% the optimal support will be searched. Basis pursuit was used to derive
% the optimal support and the high resolution patch is hallucinated using
% ridge regression.
%
% PP: Position Patch (Ma 2009)
% SPP: Sparse Position Patch (Jung 2011)

% Designed:: Reuben Farrugia
% Date: 25/2/2015
% Latest update: 27/10/2015

clc; close all; clear all;

%--------------------------------------------------------------
% RESET RANDOM NUMBERS
%--------------------------------------------------------------
s = RandStream('mrg32k3a');
RandStream.setGlobalStream(s);

%--------------------------------------------------------------
% ADD LIBRARIES
%--------------------------------------------------------------
addpath('MATLAB/parsing/');
addpath('MATLAB/general/');
addpath('MATLAB/reports/');
addpath('MATLAB/register/');
addpath('MATLAB/superres/');
addpath('MATLAB/superres/bicubic/');
addpath('MATLAB/qoe/');
addpath('MATLAB/preprocessing/');
addpath('MATLAB/superres/eigentransformation/');
addpath('MATLAB/superres/neighbor_embedding/');
addpath('MATLAB/superres/line/utilities/');
addpath('MATLAB/superres/line/');
addpath('MATLAB/superres/eigenpatches/');
addpath('MATLAB/superres/regress/');
addpath('MATLAB/superres/dict_select/');
%addpath('MATLAB/dict_select/');
%addpath('MATLAB/nearest_neighbors/');
addpath('MATLAB/superres/nearest_neighbors/');
addpath('MATLAB/SparseLab2.1-Core/Solvers/');

%--------------------------------------------------------------
% CONFIGURATION
%--------------------------------------------------------------
%SR_method     = 'BPAD_RR';          % SR Method
SR_method = 'LM_CSS';
resolutions   = [8,10,15,20];         % Resolutions considered
stitch_method = 'Average';         % Specify the way how patches are stiched (Average, Quilting)
dx_ref = 40;                        % Specify the reference distance between the eyes

% Put configuration data in a structure in_config
in_config.resolutions = resolutions;
in_config.stitch_method = stitch_method;
in_config.dx_ref = dx_ref;

% Configure the super-resolution method
if strcmp(SR_method,'NE') || strcmp(SR_method,'LINE')
    in_config.K_neighbours = 150;
elseif strcmp(SR_method,'kmeans_OLS')
    in_config.K = 1;
    in_config.clustering_dict = 'L'; % This can be either L or H
elseif strcmp(SR_method, 'sparseNN_RR')
    % Specify the number of neighbours K to be considered
    in_config.param.K = 150; % Found to provide good results in terms of
                             % quality and texture consistency
    % Specify the regularization parameter for ridge regression 
    in_config.param.lambda = 1E-6;  % Typical value found in literature
elseif strcmp(SR_method, 'KSS_RR')
    % Specify the number of neighbours K to be considered
    in_config.param.K = 150; % Found to provide good results in terms of
                             % quality and texture consistency
    % Specify the regularization parameter for ridge regression 
    in_config.param.lambda = 1E-6;  % Typical value found in literature
%elseif strcmp(SR_method, 'BPAD_RR')
elseif strcmp(SR_method, 'LM_CSS')
    % Specify the number of neighbours K to be considered
    in_config.param.Smin = 50; % To ensure there are enough points to 
                               % compute regression
    % Specify the regularization parameter for ridge regression 
    in_config.param.lambda = 1E-6;  % Typical value found in literature
    in_config.param.tau    = 0.14;  % Error threshold used by Basis Pursuit
    in_config.param.delta  = 0.01;
elseif strcmp(SR_method,'BPAD_RR_V2')
    % Specify the number of neighbours K to be considered
    in_config.param.Smin = 50; % To ensure there are enough points to 
                               % compute regression
    % Specify the regularization parameter for ridge regression 
    in_config.param.lambda = 1E-6;  % Typical value found in literature
    in_config.param.tau    = 0.14;  % Error threshold used by Basis Pursuit
    in_config.param.delta  = 0.01;  % Noise parameter needed by Basis Pursuit
    in_config.param.Kinit  = 150;   % Initial number of neighbours selected
elseif strcmp(SR_method,'CCA_BP_RR')
    % Specify the number of neighbours K to be considered
    in_config.param.Smin = 50; % To ensure there are enough points to 
                               % compute regression
    % Specify the regularization parameter for ridge regression 
    in_config.param.lambda = 1E-6;  % Typical value found in literature
    in_config.param.tau    = 0.12;  % Error threshold used by Basis Pursuit
    in_config.param.delta  = 0.01;
elseif strcmp(SR_method,'PP')
    in_config.param = [];
elseif strcmp(SR_method,'SPP')
    in_config.param = [];
elseif strcmp(SR_method,'CSSMRR')
    % Specify the regularization parameter for ridge regression 
    in_config.param.lambda = 1E-6;  % Typical value found in literature
    in_config.param.delta  = 0.01;
    % Specify the number of neighbours K to be considered
    in_config.param.K = 400; % Found to provide good results in terms of
end

% Derive the configuration information specified for the SE_method
config = configuration(SR_method, in_config,1);

if ~exist('DATASET/','dir')
    error('Download the Dataset (Only the first time) using the following url: https://drive.google.com/open?id=1SiysnOT6B1D46quA5du89618GDmIPqe3');
end
%--------------------------------------------------------------
% DATASET SELECTION AND ALIGNMENT
%--------------------------------------------------------------
% Load the sets to be considered in this experiment
SETS = dataset_selection(config);

% Report information about the sets being used
datasets_report(SETS);

% Align the face images in the sets and store them in a dataset
[SETS, config] = align_faces(SETS, config);

%--------------------------------------------------------------
 %--------------------------------------------------------------
% Evaluate the performance of the algorithms
face_superresolution_mother_function(SETS,config);