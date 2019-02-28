function data = multipie_parsing(dataset_root)

% Derive the landmark folders
lm_folder = [dataset_root,'MULTI-PIE/labels/051/'];

% Derive the dataset folder
img_foldername = [dataset_root, 'MULTI-PIE/multiview/'];

% Derive information about this folder
img_folder_list = get_folder_list(img_foldername);

% Derive the number of folders contained
Nfolders = size(img_folder_list,1);

k = 1;
for n = 1:Nfolders
    % Derive the subfoldername
    subfoldername = img_folder_list{n};
    % Derive the subject_id
    subj_id = str2double(subfoldername);
    % Derive the full_path of the subfolder
    subfoldername_fp = [img_foldername, subfoldername,'/'];
    % Derive a list of files contained within this folder
    img_list = get_file_list(subfoldername_fp,'png');
    for m = 1:size(img_list,1)
        % Derive the image filename considered
        img_filename = img_list{m};
            
        % Derive the full image filename
        img_filename_fp = [subfoldername_fp, img_filename];
        
        % Derive the landmark filename
        landmark_filename = [lm_folder, img_filename(1:end-4), '_lm.mat'];
       
        % Load the .mat file - this will load a file called pts
        load(landmark_filename);
        
        % Derive the points from the landmark points of the eye
        right_eye_1 = pts(37,:);
        right_eye_2 = pts(40,:);
        left_eye_1  = pts(43,:);
        left_eye_2 = pts(46,:);
        mouth = pts(63,:);
        
        % Approximate the location of the pupil
        right_pupil = right_eye_1 + (right_eye_2 - right_eye_1)/2;
        left_pupil  = left_eye_1  + (left_eye_2 - left_eye_1)/2;
        
        % Store the landmark points in face_info structure
        face_info.RightEye(1) = round(right_pupil(1));
        face_info.RightEye(2) = round(right_pupil(2));
        face_info.LeftEye(1)  = round(left_pupil(1));
        face_info.LeftEye(2)  = round(left_pupil(2));
        face_info.Mouth = round(mouth);
        % Include in the landmark points
        data.landmark_pts{k} = face_info;

        % Include the image filename
        data.img_filename{k} = img_filename_fp;

        % Insert the subject id of the person considered
        data.subj_id{k} = subj_id;
        
        % Increment the counter
        k = k + 1;
    end
end
