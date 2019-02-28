function data = lfw_parsing(dataset_root)

% Derive the image folder
img_folder = [dataset_root,'LFW2/'];

% Derive the list of folders
info = dir(img_folder); 
info(1:2) = [];

% Derive the number of unique persons to be included in training
N = size(info,1);

for n = 1:N
    % Derive the folder containing the images
    img_folder_2 = [img_folder, info(n).name,'/'];
    
    % Derive the list of images included
    info_2 = dir([img_folder_2,'*.jpg']);
    
    % Derive the img_filnae
    img_filename = [img_folder_2, info_2(1).name];
    
    % Store the image filename in a structure
    data.img_filename{n} = img_filename;
    data.subj_id{n} = n;
    
    % Derive the static landmark points which were aligned using an
    % automated software
    face_info.RightEye = [106,116];
    face_info.LeftEye  = [151,116];
    face_info.Mouth    = [125,162];
    
    % Put the landmark points in the structure
    data.landmark_pts{n} = face_info;
end

