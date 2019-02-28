function data = ar_parsing(dataset_root)

% Derive the landmark folders
lm_folder = [dataset_root,'AR Dataset/AR_manual_markings/'];

% Derive the image folder
img_folder = [dataset_root,'AR Dataset/dbf_PNG_ALL/'];

% Derive the list of .mat landmark files
info = dir([lm_folder,'*.mat']);

% Derive the number of landmark files
Nfiles = size(info,1);

k = 1;
for n = 1:Nfiles
    % Derive the filename
    lm_filename = [lm_folder,info(n).name];
    
    if strcmp(info(n).name(1),'M')
        % Derive the subject id
        data.subj_id{k} = str2double(info(n).name(3:5));
    else
        data.subj_id{k} = str2double(info(n).name(3:5)) + 76;
    end
    % Derive the image filename
    data.img_filename{k} = [img_folder, lower(info(n).name(1:end-4)),'_PNG.png'];
    
    if ~exist( data.img_filename{k},'file')
        continue;
    end
    
    % Load the landmark points
    load(lm_filename);
    
    % Derive the right Eye coordinates
    face_info.RightEye = round(faceCoordinates(1,:));
    
    % Derive the left Eye coordinate
    face_info.LeftEye  = round(faceCoordinates(14,:));
    
    % Derive the mouth coordinates
    face_info.Mouth = round(faceCoordinates(105,:));

    % Include in the landmark points
    data.landmark_pts{k} = face_info;
    
    % Increment counter
    k = k + 1;
end



