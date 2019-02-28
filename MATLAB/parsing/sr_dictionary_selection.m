function set = sr_dictionary_selection(dataset, config)
% This function is used to select one unique subject from a dataset. The
% set is a structure which contains the img_filename, subj_id, and
% landmark_pts coordinates.s
% 
% Designed: Reuben Farrugia
% Date: 25th February 2015
%

if strcmp(dataset,'colorferet')
    % Parse the data from the colorferet dataset
    set = color_feret_parsing(config.root_dataset);
elseif strcmp(dataset,'AR dataset')
    % Parse the data from the AR dataset
    set = ar_parsing(config.root_dataset);
elseif strcmp(dataset,'MEDS')
    % Parse the data from the MEDS dataset
    set = meds_parsing(config.root_dataset);
elseif strcmp(dataset,'MULTI-PIE')
    % Parse the multipie dataset
    set = multipie_parsing(config.root_dataset);
elseif strcmp(dataset,'LFW2')
    % Prase the lfw dataset
    set = lfw_parsing(config.root_dataset);
elseif strcmp(dataset,'FRGC-2.0-dist')
    % Parse the frgc dataset
    set = frgc_parsing(config.root_dataset);
else
    error('This process did not consider the colorferet dataset\n');
end

