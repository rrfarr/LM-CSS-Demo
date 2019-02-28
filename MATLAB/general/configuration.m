function config = configuration(SR_method, in_config,test_method)
% This function is used to configure the simulator based on the SR_method.
% The output of the config file will be used by the simulator.
%
% The config.set_filename is the filename of the .MAT file containining
% information about the datasets. There are different datasets that will be
% considered. More information will be provided in the
% dataset_selection_SR() method
%
% Designed: Reuben Farrugia
% Date: 25th February 2015
%

% Derive the directory where the set will be stored. A set will contain
% information about various datasets.
set_dir = 'SET_INFO/';
config.test_method = test_method;
% Ensure that the set_dir folder exists
if ~exist(set_dir,'dir')
    mkdir(set_dir);
end

if test_method == 1
    % Derive the filename that should contain the sets
    config.set_filename = [set_dir,'single_face_SR_SET.MAT'];
elseif test_method == 2
    config.set_filename = [set_dir,'SCFace_single_face_SR_SET.MAT'];
end
% Define the root dictionary of the dataset
config.root_dataset = '../../../../../DataSets/';

% Specify the super resolution method
config.SR_method = SR_method;

% Specify the resolutions to be considered in this experiement
config.resolutions = in_config.resolutions;

% Define the reference distance between the eyes
config.dx_ref = in_config.dx_ref;

% Define the stitching method to be used
config.stitch_method = in_config.stitch_method;

% .patch_data: contains data related to the patches
%              patch_based is a flag which specifies if the algorithm is a patch based
%              method or not.
%
% .algorithm:  contains information about the algorithm being used
%              learning_based is a flag indicating whether the method is a
%              learning based algorithm or not.


if strcmp(SR_method,'BC')
    config.patch_data.patch_based = 0;
    config.algorithm.learning_based = 0;
    config.dictionary_selection = 0;
    config.method_fullname = 'Bi-Cubic';
    config.wieght_enhancement = 0;
    config.neighbor_selection_preprocess = 0;
    config.graph_construction = [];
elseif strcmp(SR_method,'ET')
    config.patch_data.patch_based = 0;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.method_fullname = 'Eigentransformation';
    config.wieght_enhancement = 0;
    config.neighbor_selection_preprocess = 0;
    config.graph_construction = [];
elseif strcmp(SR_method,'NE')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.method_fullname = 'Neighbor-Embedding';
    config.K_neighbours = in_config.K_neighbours;
    config.neighbor_selection_preprocess = 0;
    config.graph_construction = [];
elseif strcmp(SR_method,'LINE')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.method_fullname = 'LINE';
    config.LINE.tau = 1E-5;
    config.LINE.maxiter = 5;
    config.K_neighbours = in_config.K_neighbours;
    config.neighbor_selection_preprocess = 0;
    config.graph_construction = [];
elseif strcmp(SR_method,'EP')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.method_fullname = 'Eigen-Patches';
    config.search_range = 0;
    config.neighbor_selection_preprocess = 0;
    config.graph_construction = [];
elseif strcmp(SR_method,'OLS')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.method_fullname = 'OLS';
    config.neighbor_selection_preprocess = 0;
    config.graph_construction = [];
elseif strcmp(SR_method,'kmeans_OLS')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 1;
    config.K = in_config.K;
    config.dictionary_selection_method = 'kmeans';
    config.clustering_dict = in_config.clustering_dict;
    config.method_fullname = sprintf('kmeans_OLS_%d%s',config.K,config.clustering_dict);
    config.neighbor_selection_preprocess = 0;
    config.graph_construction = [];
elseif strcmp(SR_method, 'kmeans_lbp_OLS_1')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 1;
    config.K = in_config.K;
    config.dictionary_selection_method = 'kmeans_lbp';
    config.method_fullname = sprintf('kmeans_lbp_OLS_%d_METHOD_1',config.K);
    config.neighbor_selection_preprocess = 0;
    config.graph_construction = [];
elseif strcmp(SR_method, 'AGNN_RR')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 1;
    config.dictionary_selection_method = 'AGNN_RR';
    config.method_fullname = 'AGNN_RR';
    config.AGNNparam = in_config.AGNNparam; % As used by the paper
    config.neighbor_selection_preprocess = 0;
    config.graph_construction = [];
elseif strcmp(SR_method, 'RoM_RR')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    config.method_fullname = 'RoM_RR';
    config.neighbor_selection_preprocess = 1;
    config.graph_construction = [];
elseif strcmp(SR_method, 'IGL_RoM_RR')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    config.method_fullname = 'IGL_RoM_RR';
    config.neighbor_selection_preprocess = 1;
    config.graph_construction = [];
elseif strcmp(SR_method, 'sparseKNNoM_RR')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    config.method_fullname = sprintf('sparseKNNoM_RR_tau_%d',config.param.tau*10);
    config.neighbor_selection_preprocess = 1;
    config.graph_construction = [];
elseif strcmp(SR_method, 'sparseNN_RR')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    config.method_fullname = 'sparseNN_RR';
    config.neighbor_selection_preprocess = 0;    
    config.graph_construction = [];
elseif strcmp(SR_method, 'KSS_RR')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    config.method_fullname = 'KSS_RR';
    config.neighbor_selection_preprocess = 0;    
    config.graph_construction = [];
%elseif strcmp(SR_method, 'BPAD_RR')
elseif strcmp(SR_method, 'LM_CSS')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    
    if strcmp(config.stitch_method,'Quilting')
        config.method_fullname = 'BPAD_RR_Quilting';
    else
        %config.method_fullname = 'BPAD_RR';
        config.method_fullname = 'LM_CSS';
    end
    config.neighbor_selection_preprocess = 0;    
    config.graph_construction = [];
elseif strcmp(SR_method, 'BPAD_RR_Gallery')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    
    if strcmp(config.stitch_method,'Quilting')
        config.method_fullname = 'BPAD_RR_Gallery_Quilting';
    else
        config.method_fullname = 'BPAD_RR';
    end
    config.neighbor_selection_preprocess = 0;    
    config.graph_construction = [];
elseif strcmp(SR_method, 'BPAD_RR_V2')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    
    if strcmp(config.stitch_method,'Quilting')
        config.method_fullname = 'BPAD_RR_V2_Quilting';
    else
        config.method_fullname = 'BPAD_RR_V2';
    end
    config.neighbor_selection_preprocess = 0;    
    config.graph_construction = [];
elseif strcmp(SR_method, 'CCA_BP_RR')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    
    if strcmp(config.stitch_method,'Quilting')
        config.method_fullname = 'CCA_BP_RR_Quilting';
    else
        config.method_fullname = 'CCA_BP_RR';
    end
    config.neighbor_selection_preprocess = 0;    
    config.graph_construction = [];
elseif strcmp(SR_method, 'PP')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param;
    config.method_fullname = 'Position_Patch';
    config.neighbor_selection_preprocess = 0;    
    config.graph_construction = [];
elseif strcmp(SR_method, 'SPP')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param;
    config.method_fullname = 'Sparse Position_Patch';
    config.neighbor_selection_preprocess = 0;    
    config.graph_construction = [];
elseif strcmp(SR_method, 'CSSMRR')
    config.patch_data.patch_based = 1;
    config.algorithm.learning_based = 1;
    config.dictionary_selection = 0;
    config.param = in_config.param; 
    
    if strcmp(config.stitch_method,'Quilting')
        config.method_fullname = sprintf('CSSMRR_Quilting_K_%d',config.param.K);
    else
        config.method_fullname = sprintf('CSSMRR_K_%d',config.param.K);;
    end
    config.neighbor_selection_preprocess = 0;    
    config.graph_construction = [];
end