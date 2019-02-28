function [SETS, config] = align_faces(SETS, config)
% This function is used to extract the images included in SETS, and align
% them using affine transformation. All these images will be aligned to a
% resolution of 128x128 which correspond to X pixels between the eyes. The
% images will be stored in the dataset folder and the SETS will be modified
% such that it will include the filename of the aligned images
% 
% Designed: Reuben Farrugia
% Data: 26/2/2015
%

% Derive the input set filename
in_set_filename = config.set_filename;

% Derive the filename of the modified sets
out_set_filename = [in_set_filename(1:end-4), '_modified.MAT'];

if ~exist(out_set_filename,'file')
    % ---- Arrange the probe and gallery face recognition idx
    [SETS.Probe, SETS.Gallery] = create_face_rec_idx(SETS.Probe, SETS.Gallery);
    
    % ---- Align the face images, store then in dataset and include the
    % aligned filename
    SETS.Training   = align_face_images(SETS.Training,'Training',config.dx_ref);
    SETS.Dictionary = align_face_images(SETS.Dictionary,'Dictionary',config.dx_ref);
    SETS.Gallery    = align_face_images(SETS.Gallery,'Gallery',config.dx_ref);
    SETS.Probe      = align_face_images(SETS.Probe,'Probe',config.dx_ref);
    
    % Save the modified set filename
    save(out_set_filename,'SETS');
else
    % Load the modified set filename
    load(out_set_filename);
end
% Remove the set filename field since it is no longer needed
config = rmfield(config,'set_filename');
config = rmfield(config,'root_dataset');