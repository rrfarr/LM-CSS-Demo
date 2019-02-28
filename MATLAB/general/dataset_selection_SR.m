function SET = dataset_selection_SR(config)
% The dataset_selection() process is used to generate the datasets on which
% the algorithms will be tested and evaluated. This function does not take
% any input since the datasets and their functions are specified in this
% function. This method however returs a structure SET which has four
% fields:
% Designed: Reuben Farrugia
% Date: 25th February 2015
%
% SET.Training: This set is used to train the face recognizer. This set
% consists of all face images included in the AR dataset (895)
%
% SET.Dictionary: This set is used to train the super-resolution
% algorithms. It consists of all images from the color-feret and
% multi-pie for a total of 4933 images
%
% SET.Gallery: This is a set of images consisting the gallery. One face
% image per person is included in the gallery. These consist of the FRGC
% dataset (controlled) and MEDS for a total of 889 images
%
% SET.Probe: This is a set of probe images which will be sub-sampled and
% enhanced. These correspond to 930 face images from the FRGC dataset
% captured in an un-controlled environment.
%
% Designed: Reuben Farrugia 4/92015



% Define the datasets the be considered
datasets = {'colorferet', 'AR dataset', 'MEDS', 'MULTI-PIE', 'FRGC-2.0-dist'}; 

%------------------------------------------------------------
% Load the data from the respective datasets
%------------------------------------------------------------
for i = 1:size(datasets,2)
    % Derive the data mat file to contain informaiton
    dataset_filename = sprintf('SET_INFO/%s_DATA.MAT',datasets{i});
    
    if ~exist(dataset_filename,'file')
        % Derive information about the current dataset
        dataset_DATA = sr_dictionary_selection(datasets{i}, config);
        
        % Save each set in .MAT files containing the filenames of the
        % images in each dataset, the subject ids and landmark points
        if strcmp(datasets{i},'colorferet')
            colorferet_dataset = dataset_DATA;
            save(dataset_filename,'colorferet_dataset');
        elseif strcmp(datasets{i},'AR dataset')
            ar_dataset = dataset_DATA;
            save(dataset_filename,'ar_dataset');
        elseif strcmp(datasets{i},'MEDS')
            meds_dataset = dataset_DATA;
            save(dataset_filename,'meds_dataset')
        elseif strcmp(datasets{i},'MULTI-PIE')
            multipie_dataset = dataset_DATA;
            save(dataset_filename,'multipie_dataset');
        elseif strcmp(datasets{i}, 'FRGC-2.0-dist')
            frgc_dataset = dataset_DATA;
            save(dataset_filename,'frgc_dataset');
        end
    else
        % Load the dataset
        load(dataset_filename);
    end
    % Report the dataset being loaded
    fprintf(1,'Dataset %s was successfully loaded\n',datasets{i});
end

%------------------------------------------------------------
% Organize the datasets
%------------------------------------------------------------

% Filter the FRGC dataset and organize them in terms of subject ids
[frgc_dataset_controled, frgc_dataset_uncontroled] = organize_frgc_dataset(frgc_dataset);

% Make sure that meds contains only one sample per person
meds_dataset_filtered       = get_N_image_per_subject(meds_dataset,1);

%------------------------------------------------------------
% Create the sets
%------------------------------------------------------------
%----- Training Dictionary (for Face Recognizer if needed)
SET.Training = dataset_converter(ar_dataset);

%----- Gallery Dictionary
% Determine the number of unique probe images
Nunique_FRGC = frgc_dataset_controled.Nunique;
% Determine the number of uniue meds images
Nunique_MEDS = meds_dataset_filtered.Nunique;

% Initialize the Gallery set
SET.Gallery.Nunique = Nunique_FRGC + Nunique_MEDS;
SET.Gallery.Nfaces = SET.Gallery.Nunique;
SET.Gallery.subj = [frgc_dataset_controled.subj; meds_dataset_filtered.subj];

%----- Probe Dictionary

% Put the frgc dataset uncontrolled samples as probe
SET.Probe = frgc_dataset_uncontroled;

%----- Dictionaries to be used for super-resolution

colorferet_data = dataset_converter(colorferet_dataset);
multipie_data   = dataset_converter(multipie_dataset);

% Derive the dictionary set
SET.Dictionary.Nunique = colorferet_data.Nunique + multipie_data.Nunique;
SET.Dictionary.Nfaces  = colorferet_data.Nfaces + multipie_data.Nfaces;
SET.Dictionary.subj    = [colorferet_data.subj; multipie_data.subj];

function out_set = dataset_converter(in_set)
% This function is simply used to convert the input set into a standard set
% which includes the subjects, number of unique faces and number of face
% images

% Derive the number of unique subjects
list_unique_subj = unique(cell2mat(in_set.subj_id))';

% Derive the number of unique subjects
Nunique = size(list_unique_subj,1);

% Initialize the output organized set
out_set.subj = cell(Nunique,1);

% Initialize the faces
Nfaces = 0;
for n = 1:Nunique
    % Derive the index of the current unique subject
    indx = find(cell2mat(in_set.subj_id) == list_unique_subj(n));
    
    % Derive the number of images for this subject
    Nimg_subj_n = size(indx,2);
    
    % Increment the number of facesrandperm(Nimg_subj_n,Nimg_subj_out);
    Nfaces = Nfaces + Nimg_subj_n;
    
    % Derive a randompermutation index
    %rand_idx = randperm(Nimg_subj_n,Nimg_subj_out);
    
    % Store the image data in the output set
    out_set.subj{n}.img_filename = in_set.img_filename(indx);
    out_set.subj{n}.subj_id      = in_set.subj_id(indx);
    out_set.subj{n}.landmark_pts = in_set.landmark_pts(indx);
end
% Specify the total number of faces considered in the output set
out_set.Nfaces = Nfaces;
out_set.Nunique = Nunique;