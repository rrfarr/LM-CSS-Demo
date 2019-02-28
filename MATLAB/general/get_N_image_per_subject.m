function out_set = get_N_image_per_subject(in_set,N)
% This function organizes the input set into unique subjects. This method
% also ensures that N (or the available) number of face iages of the same
% subject are included.

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
    
    % Derive the number of images to be placed in the output set
    Nimg_subj_out = min(N,Nimg_subj_n);
    
    % Increment the number of facesrandperm(Nimg_subj_n,Nimg_subj_out);
    Nfaces = Nfaces + Nimg_subj_out;
    
    % Derive a randompermutation index
    rand_idx = randperm(Nimg_subj_n,Nimg_subj_out);
    
    % Store the image data in the output set
    out_set.subj{n}.img_filename = in_set.img_filename(indx(rand_idx));
    out_set.subj{n}.subj_id      = in_set.subj_id(indx(rand_idx));
    out_set.subj{n}.landmark_pts = in_set.landmark_pts(indx(rand_idx));
end
% Specify the total number of faces considered in the output set
out_set.Nfaces = Nfaces;
out_set.Nunique = Nunique;
