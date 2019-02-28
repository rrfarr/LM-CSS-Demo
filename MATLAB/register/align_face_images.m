function SET = align_face_images(SET, dataset, dx_ref)

% Derive the foldername where the images will be stored
foldername = ['DATASET/',dataset,'/'];

% Make sure this folder exists
if ~exist(foldername,'dir')
    mkdir(foldername);
end

% Derive the number of subjects included in the set
Nsubj = size(SET.subj,1);

warning('off');

for n = 1:Nsubj
    % Extract the subj structure being considered
    subj = SET.subj{n};
    
    % Derive the number of images per subject
    Nimgs = size(subj.subj_id,2);
    
    % Derive the subfolder where the images will be stored
    out_foldername = [foldername,sprintf('%0.5d',n),'/'];
    
    % Make sure that the folder exists
    if ~exist(out_foldername,'dir')
        mkdir(out_foldername);
    end
    
    for m = 1:Nimgs
        % Derive the image filename
        img_filename = subj.img_filename{m};
        
        % Extract the landmark points
        landmark_pts = subj.landmark_pts{m};
        
        % Load the image
        I = imread(img_filename);
        
        % Derive the name of the image by parsing it from img_filename
        indx = strfind(img_filename,'/');
        indx = indx(end);
        name = img_filename(indx+1:end-4);
        
        % Derive the output image filename
        SET.subj{n}.aligned_img_filename{m} = [out_foldername,name,'.BMP'];
        
        % Align the face image
        face = affine_align(I,landmark_pts,dx_ref); % To a resolution which allows 100 pixels between the eyes
        
        % Store the face image in the output folder
        imwrite(face,SET.subj{n}.aligned_img_filename{m});
    end
end
warning('on');