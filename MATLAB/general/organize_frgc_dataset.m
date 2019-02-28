function [controled_set, uncontroled_set] = organize_frgc_dataset(in_set)
% This function organizes the input set into a controlled set and
% uncontroled set.

% Derive the number of unique subjects
list_unique_subj = unique(cell2mat(in_set.subj_id))';

% Derive the number of unique subjects
Nunique = size(list_unique_subj,1);

% Initialize the output organized set
controled_set.subj = cell(Nunique,1);
uncontroled_set.subj = cell(Nunique,1);

% Initialize the faces
Nfaces_controled = 0;
Nfaces_noncontroled = 0;

for n = 1:Nunique
    % Derive the index of the current unique subject
    indx = find(cell2mat(in_set.subj_id) == list_unique_subj(n));
    
    % Derive the index of the controlled images
    controlled_idx =  indx(strcmp({in_set.controlled{indx}},'FRGCv2-controlled - GT')');
    
    % Derive the index of the non-controlled images
    uncontrolled_idx = indx(strcmp({in_set.controlled{indx}},'FRGCv2-uncontrolled - GT')');
    
    % Derived the controlled random index
    rand_idx_controlled = controlled_idx(randperm(size(controlled_idx,2),1));
    
    % Derive the uncontrolled random index
    rand_idx_uncontrolled = uncontrolled_idx(randperm(size(uncontrolled_idx,2),2));
    
    % Store the image data in the output set
    controled_set.subj{n}.img_filename = in_set.img_filename(rand_idx_controlled);
    controled_set.subj{n}.subj_id      = in_set.subj_id(rand_idx_controlled);
    controled_set.subj{n}.landmark_pts = in_set.landmark_pts(rand_idx_controlled);
    Nfaces_controled = Nfaces_controled + size(rand_idx_controlled,2);
    
    % Store the image data in the output set
    uncontroled_set.subj{n}.img_filename = in_set.img_filename(rand_idx_uncontrolled);
    uncontroled_set.subj{n}.subj_id      = in_set.subj_id(rand_idx_uncontrolled);
    uncontroled_set.subj{n}.landmark_pts = in_set.landmark_pts(rand_idx_uncontrolled);
    Nfaces_noncontroled = Nfaces_noncontroled + size(rand_idx_uncontrolled,2);
end

controled_set.Nfaces = Nfaces_controled;
controled_set.Nunique = Nunique;
uncontroled_set.Nfaces = Nfaces_noncontroled;
uncontroled_set.Nunique = Nunique;
