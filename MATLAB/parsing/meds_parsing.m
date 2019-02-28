function data = meds_parsing(dataset_root)

% Derive the filename where the landmark points are stored
lm_filename = [dataset_root, 'MEDS/metadata/image_landmarks.xls'];

% Read all the data contained in the csv file
[~,~,DATA] = xlsread(lm_filename);

% Derive the dataset folder
img_foldername = [dataset_root, 'MEDS/img/'];

k = 1;
for n = 2:size(DATA,1)
    % Derive the image filename to be considered
    img_filename = DATA{n,2};
    
    % Derive the subject id of the person considered
    subj_id = str2double(img_filename(2:4));
    
    % Derive the full path
    img_filename_fp = [img_foldername, img_filename];
    
    if strcmp(DATA{n,3},'Frontal') && exist(img_filename_fp,'file')% Only frontal images are considered in this experiment
        if ~isnan(DATA{n,5}) % Only faces with good feature points are considered in this experiemnt
            % Insert the subject id of the person considered
            data.subj_id{k} = subj_id;
            
            % Derive the landmark points
            right_pupil_x = DATA{n,67};
            right_pupil_y = DATA{n,68};
            left_pupil_x  = DATA{n,77};
            left_pupil_y  = DATA{n,78};
            mouth_x       = DATA{n,127};
            mouth_y       = DATA{n,128};
            
            % Store the landmark points in face_info structure
            face_info.RightEye(1) = round(right_pupil_x);
            face_info.RightEye(2) = round(right_pupil_y);
            face_info.LeftEye(1) = round(left_pupil_x);
            face_info.LeftEye(2)= round(left_pupil_y);
            face_info.Mouth(1)  = round(mouth_x);
            face_info.Mouth(2)  = round(mouth_y);
            
            % Include in the landmark points
            data.landmark_pts{k} = face_info;

            % Include the image filename
            data.img_filename{k} = img_filename_fp;
            % Increment the counter
            k = k + 1;
        end
    end
end