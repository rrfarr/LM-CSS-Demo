function data = frgc_parsing(dataset_root)
% The FRGC filestructure was modified a bit before parsing. The landmark
% points were downloaded from
% http://homes.di.unimi.it/~lipori/download/gt.html and we have copied the
% Fall_2003 and Sprint_2004 images in a folder images (same level as
% FRGCv2-uncontrolled - GT and FRGCv2-controlled - GT folders.



% Fall_2003 and Sprint_2004 in the FRGC-2
% This function should be able to parse the frgc dataset
img_folder = [dataset_root,'FRGC-2.0-dist/FRGCv2 - GT/images/'];

% Specify the FRGC ground truth foldernames
landmark_foldername = [dataset_root, 'FRGC-2.0-dist/FRGCv2 - GT/'];

% Define a list of folders to be considered
frgc_folder_list = {'FRGCv2-controlled - GT','FRGCv2-uncontrolled - GT' };

% 
k = 1;
for n = 1:size(frgc_folder_list,2)
    % Derive the full foldername
    frgc_foldername = [landmark_foldername, frgc_folder_list{n},'/'];
    
    % Derive the list of text files
    txt_list = get_file_list(frgc_foldername,'txt');
    for m = 1:size(txt_list,1)
        % Derive the txt filename
        txt_filename = txt_list{m};
        
        % Derive the image filename
        img_filename = [img_folder, lower(txt_filename(1:end-3)),'jpg'];
        
        if ~exist(img_filename,'file')
            continue;
        end
        % Read the landmark points
        data.landmark_pts{k} = frgc_get_metadata([frgc_foldername,txt_filename]);
        
        % Get the image filename
        data.img_filename{k} = img_filename;
        
        % Mark image as controlled or not
        data.controlled{k} = frgc_folder_list{n};
        
        % Derive the subject id of the person
        data.subj_id{k} = str2double(txt_filename(1:strfind(txt_filename,'d')-1));
        
        % Increment the counter
        k = k + 1;
    end
end

function face_info = frgc_get_metadata(txt_filename)

% Open the current file
fid = fopen(txt_filename,'r');
face_info.RightEye = frgc_lm_parser(fgetl(fid));
face_info.LeftEye  = frgc_lm_parser(fgetl(fid));
fgetl(fid);
face_info.Mouth    = frgc_lm_parser(fgetl(fid));

% Close the landmark point file
fclose(fid);


function coord = frgc_lm_parser(line)
% This script is a simple string to parse the coordinates in the frgc
% landmark files
indx = find(line == 9);
indx = indx(2);
coord(1) = str2double(line(1:indx-1));
coord(2) = str2double(line(indx+1:end));