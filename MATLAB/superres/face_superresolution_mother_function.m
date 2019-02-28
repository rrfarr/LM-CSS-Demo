function face_superresolution_mother_function(SETS, config)
% This function is a mother function which is used to select the
% super_resolution method to be performed. The SETS includes the datasets
% to be used while the configuration parameters are passed through the
% config structure
%
% Designed: Reuben Farrugia
% Date: 26/2/2015
% Latest update: 13/10/2015

% Extract the resolutions
resolutions = config.resolutions;

% Derive the number of resolutions
Nres = size(resolutions,2);

% Derive the reference distance between the eyes
dx_ref = config.dx_ref;

%------------ Load the training images in the dictionary
if config.algorithm.learning_based == 1
    % Load the SR Dictionary in SR_config - these are a list of high
    % resolution images to be used as dictionary
    SR_config.SR_dictionary.HR_face = load_SR_dictionary(SETS.Dictionary.subj);
end

if strcmp(config.SR_method,'NE') || strcmp(config.SR_method,'LINE')
    % Put the number of nearest neighbors in SR_config
    SR_config.K_neighbours = config.K_neighbours;
end
% Derive the stiching method to be used to combine the patches
SR_config.stitch_method = config.stitch_method;

% Get the configuration parameters
if strcmp(config.SR_method,'LINE')
    SR_config.tau = config.LINE.tau;
    SR_config.maxiter = config.LINE.maxiter;
elseif strcmp(config.SR_method,'EP')
    SR_config.search_range = config.search_range;
elseif strcmp(config.SR_method,'AGNN_RR')
    SR_config.AGNNparam = config.AGNNparam;
elseif strcmp(config.SR_method,'RoM_RR') ...
        || strcmp(config.SR_method,'IGL_RoM_RR') ...
        || strcmp(config.SR_method,'sparseKNNoM_RR') ...
        || strcmp(config.SR_method,'sparseNEoM_RR') ...
        || strcmp(config.SR_method,'sparseNN_RR') ...
        || strcmp(config.SR_method,'KSS_RR') ...
        || strcmp(config.SR_method,'BPAD_RR') ...
        || strcmp(config.SR_method,'CCA_BP_RR') ...
        || strcmp(config.SR_method,'BPAD_RR_V2') ...
        || strcmp(config.SR_method,'BPAD_RR_Gallery') ...
        || strcmp(config.SR_method,'CSSMRR')
    SR_config.param = config.param;
end

% Extract the probe_set
probe_set = SETS.Probe.subj;

% Determine the number of subjects in the probe
Nsubj = size(probe_set,1);

% Put information relevant the SR method in DATA
SR_config.SR_method = config.SR_method;

% Initialize the interation total
iter_total = 0;

% Start the simulator timer
sim_start = tic;

% Derive the total number of iterations
Niter_tot = size(resolutions,2) * SETS.Probe.Nfaces;

% Get information about the machiine on which evaluation is run
pc_info = get_computer_information();

for r = 1:Nres
    % Initialize the arrays which will store the results to be reported
    complexity = zeros(Nsubj,size(probe_set{1}.img_filename,2));
    psnr_metric = zeros(Nsubj,size(probe_set{1}.img_filename,2));
    ssim_metric = zeros(Nsubj,size(probe_set{1}.img_filename,2));
    fsim_metric = zeros(Nsubj,size(probe_set{1}.img_filename,2));
    
    % Derive the current resolution (distance between eyes) beinc
    % considered
    dx = resolutions(r);
    
    if config.patch_data.patch_based == 1
        % Convert the testing image to patches
        [SR_config.SR_dictionary.HR_patches, SR_config.SR_dictionary.LR_patches]  =  ...
            hr_lr_face2patch(SR_config.SR_dictionary.HR_face,dx,dx_ref);
        
        if strcmp(config.SR_method,'CCA_BP_RR')
            % Learn the projection matrices for each patch
            [SR_config.SR_dictionary.PL, SR_config.SR_dictionary.PH] = learn_cca_projections(SR_config.SR_dictionary.HR_patches, SR_config.SR_dictionary.LR_patches);
        end
        
        % Check whether a dictionary selection method will be used
        if config.dictionary_selection == 1
            if strcmp(config.dictionary_selection_method,'kmeans')
                % K-means clustering using L2 norm distance on the standardized vectors
                SR_config.sub_dict_data = kmeans_dictionary_selection(SR_config.SR_dictionary.LR_patches, config.K);
            elseif strcmp(config.dictionary_selection_method,'kmeans_lbp')
                % K-means clustering using the histogram intersection
                % distance on LB feature vectors
                SR_config.sub_dict_data = kmeans_lbp_dictionary_slection(SR_config.SR_dictionary.LR_patches, config.K);
            elseif strcmp(config.dictionary_selection_method,'AGNN_RR')
                % Compute the diffused affinity matrix using replicator
                % graph method
                SR_config.sub_dict_data = replicator_dynamic_diffusion(SR_config.SR_dictionary.LR_patches, SR_config.AGNNparam);
            elseif strcmp(config.dictionary_selection_method,'AGNN_X_v01_RR')
                % Compute the diffused affinity matrix using replicator
                % dynamic diffusion and model the manifold using b-matching
                SR_config.sub_dict_data = manifold_modelling(SR_config.SR_dictionary.LR_patches, SR_config.param);
            end
        end
        
        if config.neighbor_selection_preprocess == 1
            % Derive the affinity matrix for every patch
            [SR_config.param.A, SR_config.param.mu] = compute_affinities(SR_config.SR_dictionary.LR_patches);
            if ~isempty(config.graph_construction)
                % This means that the method employs graph construction to
                % sparsify the affinity matrix
                if strcmp(config.graph_construction,'KNN')
                    % Compute the k nearest neighbour to derive the graph
                    SR_config.param.G = k_nearest_neighbours(SR_config.param.A,SR_config.param.K);
                end
            end
        end
        

    end
    
    % Determine the foldername where the super-resolved probe images will
    % be stored
    out_foldername = sprintf('RESULTS/%s/images/dx_%d/',config.method_fullname,dx);
    
    % Determine the scaling factor
    scale = dx/dx_ref;
   
    for n = 1:Nsubj
        % Determine the number of images of the same subject
        Nimgs = size(probe_set{n}.img_filename,2);
        
        for m = 1:Nimgs
            % Derive the in_img_filename
            in_img_filename = probe_set{n}.aligned_img_filename{m};
            
            % Derive the output subjct foldername
            out_subj_foldername = sprintf('%s%0.5d/',out_foldername,n);
            
            % Make sure that the folder exists
            if ~exist(out_subj_foldername,'dir')
                mkdir(out_subj_foldername);
            end
            
            % Load the input image
            Irgb_original = imread(in_img_filename);
            
            % Rescale the image
            Irgb_LR = imresize(Irgb_original,scale);
            
            % Convert the rgb image to ycbcr
            Iycbcr_LR = rgb2ycbcr(Irgb_LR);
            
            % Initialize a high resolution image
            Iycbcr_HR_ = zeros(size(Irgb_original));
            
            % Derive the dimensions of the RGB image
            [H,W,~] = size(Irgb_original);
            
            % Store the dimensions of the high resolution image
            SR_config.HR_img.H = H;
            SR_config.HR_img.W = W;
            
            % Upsamble the Cb component using bi-cubic interpolation
            Iycbcr_HR_(:,:,2) = imresize(Iycbcr_LR(:,:,2),[H,W],'bicubic');
            
            % Upsample the Cr component using bi-cubic interpolation
            Iycbcr_HR_(:,:,3) = imresize(Iycbcr_LR(:,:,3),[H,W],'bicubic');
            
            %% For testing This can be removed when testing
            IHR = rgb2ycbcr(Irgb_original);
            SR_config.IHR = IHR(:,:,1);
            SR_config.dx = dx;
            %%------------

            % Compute the super-resolution of the luminance component
            [Iycbcr_HR_(:,:,1), t_elapsed, stat] = face_superresolution(Iycbcr_LR(:,:,1),SR_config);
            
            % Put the elapsed time into the complexity arrya
            complexity(n, m) = t_elapsed;
            
            % Convert the up-sampled image to the RGB color space
            Irgb_sr = ycbcr2rgb(uint8(Iycbcr_HR_));
            
            % Derive the filename of the image to be stored
            indx = strfind(in_img_filename,'/')+1;
            
            % Derive the full filename of the output image
            out_img_filename = [out_subj_foldername, in_img_filename(indx(end):end)];

            % Store the reconstructed image
            imwrite(Irgb_sr,out_img_filename);
            
            %----- Quality Evaluation
            % Convert the high resolution face to grayscale
            hr_face = rgb2gray(Irgb_original);
            
            % Convert the hallucinated face image to grayscale
            lr_face = rgb2gray(Irgb_sr);
            
            % Compute the quality metrics
            [psnr_metric(n, m), ssim_metric(n, m), fsim_metric(n, m)] = face_quality_eval(hr_face, lr_face);
            
            if ~isempty(stat)
                fprintf(fid,'%s, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f\n', ... 
                    in_img_filename, stat.corr_direct(1),stat.corr_direct(2), ...
                    stat.rmse_direct, stat.norm_direct(1), stat.norm_direct(2), ...
                    stat.corr_rr(1), stat.corr_rr(2), stat.rmse_rr, stat.norm_rr(1), stat.norm_rr(2), ...
                    stat.norm_actual(1), stat.norm_actual(2));
                   
                fprintf(1,'%s, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f, %0.4f\n', ... 
                    in_img_filename, stat.corr_direct(1),stat.corr_direct(2), ...
                    stat.rmse_direct, stat.norm_direct(1), stat.norm_direct(2), ...
                    stat.corr_rr(1), stat.corr_rr(2), stat.rmse_rr, stat.norm_rr(1), stat.norm_rr(2), ...
                    stat.norm_actual(1), stat.norm_actual(2));
            end
            %----- Time left prediction
            % Derive the iterations
            iter_total = iter_total + 1;
            
            % Derive the total elapsed time
            t_elapsed_total = toc(sim_start);

            % Average elapsed time
            t_elapsed_ave = t_elapsed_total/iter_total;
           
            % Expected total time
            expected_total_time = Niter_tot * t_elapsed_ave;
        
            % Time remaining
            est_time_left = expected_total_time - t_elapsed_total;
        
            % Convert the estimated time to string
            time_left_str = seconds2human(est_time_left);

            % Put on console information about the simulation
            clc;
            fprintf(1, 'Resolution %d subject %d (out of %d) Time left: %s\n',dx,n,Nsubj,time_left_str);
        end
    end
    
    % Output a report using the current data
    statistical_report(probe_set, complexity, psnr_metric, ssim_metric, fsim_metric, dx,config.method_fullname);
end

% Output the pc report
pc_info_report(pc_info, config.method_fullname);