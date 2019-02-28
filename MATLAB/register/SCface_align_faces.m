function [SETS, config] = SCface_align_faces(SETS_NA, config)
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
    %[SETS.Probe, SETS.Gallery] = create_face_rec_idx(SETS.Probe, SETS.Gallery);
    [SETS_NA.Probe, SETS_NA.Gallery] = SCFace_create_face_rec_idx(SETS_NA.Probe, SETS_NA.Gallery);    
    
    load('SET_INFO/single_face_SR_SET_modified.MAT');
    SETS.Gallery = [];
    SETS.Probe = [];

    % ---- Align the face images, store then in dataset and include the
    % aligned filename
    SETS.Gallery    = align_face_images(SETS_NA.Gallery,'SCFaceGallery',config.dx_ref);
    SETS.Probe      = SCFace_align_face_images(SETS_NA.Probe,'SCFaceProbe',config.dx_ref);
    
    % Save the modified set filename
    save(out_set_filename,'SETS');
else
    % Load the modified set filename
    load(out_set_filename);
end
% Remove the set filename field since it is no longer needed
config = rmfield(config,'set_filename');
config = rmfield(config,'root_dataset');

function SET = SCFace_align_face_images(SET, dataset, dx_ref)

% Derive the foldername where the images will be stored
foldername = ['DATASET/',dataset,'/'];

% Make sure this folder exists
if ~exist(foldername,'dir')
    mkdir(foldername);
end

% Derive the number of subjects included in the set
Nsubj = SET.Nunique;

warning('off');

for n = 1:Nsubj
    % Extract the subj structure being considered
    subj = SET.subj{n};
    
    % Derive the number of images per subject
    Nimgs = size(subj.subj_id);
    
    % Derive the subfolder where the images will be stored
    out_foldername = [foldername,sprintf('%0.5d',n),'/'];
    
    % Make sure that the folder exists
    if ~exist(out_foldername,'dir')
        mkdir(out_foldername);
    end
    
    for i = 1:Nimgs(1)
        for j = 1:Nimgs(2)  
            % Derive the image filename
            img_filename = subj.img_filename{i,j};
            
            % Extract the landmark points
            landmark_pts = subj.landmark_pts{i,j}{1};
            % Load the image
            I = imread(img_filename);
        
            % Derive the name of the image by parsing it from img_filename
            indx = strfind(img_filename,'/');
            indx = indx(end);
            name = img_filename(indx+1:end-4);
        
            % Align the face image
            [face,dx] = affine_rotate_crop(I,landmark_pts,dx_ref); % To a resolution which allows 100 pixels between the eyes

            % Derive the output image filename
            SET.subj{n}.aligned_img_filename{i,j} = [out_foldername,name,sprintf('_dx_%d',dx),'.BMP'];
            % Store the face image in the output folder
            imwrite(face,SET.subj{n}.aligned_img_filename{i,j});
        end
    end
end
warning('on');

function [face,dx] = affine_rotate_crop(I, landmark_pts, nx)

% Set the configuration of the transformaiton
offset_pct = 0.2; 
if nargin == 2
    nx = 100;
end

% Extract the landmark points
eye_right = landmark_pts.RightEye;
eye_left  = landmark_pts.LeftEye;
mouth     = landmark_pts.Mouth;

% Derive the distance between the eyes
dx = round(sqrt(sum((eye_right - eye_left).^2)));

dest_sz = round(nx/0.6);

% Deri100ve the offset
offset = floor(offset_pct * dest_sz);

% Calculate the scale
scale = dx/nx;

% Derive the reference points where the eyes and mouth need to be warped
eye_right_ref = round([offset, offset].*scale);
eye_left_ref  = round([dest_sz - offset, offset].*scale);
mouth_ref     = round([dest_sz/2, dest_sz - offset].*scale);

% Approximate the affine transformation matrix
hgte1 = vision.GeometricTransformEstimator('ExcludeOutliers', false);
tform = step(hgte1, [eye_right; eye_left; mouth],[eye_right_ref; eye_left_ref; mouth_ref]);

% Compute the affine transformation based on the approximated transform
% matrix
hgt = vision.GeometricTransformer;
Itrans = step(hgt, double(I), tform);

dest_sz = round(dx/0.6);

% Extract the face image
face = uint8(Itrans(1:dest_sz,1:dest_sz,:));

function [probe, gallery] = SCFace_create_face_rec_idx(probe, gallery)
% This function will include a field within the probe and gallery sets of a
% field named face_rec_id which correpsonds to the face recognition
% identifier which will be used during face recognition.

for n = 1:size(gallery.subj,1)
    % Derive the subject id of the current subject
    subj_id_gallery = gallery.subj{n}.subj_id{1};
    
    
    if n <= size(probe.subj,2)
        for m = 1:size(probe.subj,2)

            % Derive the subj id of the probe
            subj_id_probe = probe.subj{m}.subj_id{1}{1,1};
        
            if subj_id_gallery == subj_id_probe
                break;
            end
        end
        probe.subj{m}.face_rec_id = n;
    end
    gallery.subj{n}.face_rec_id = n;
end
