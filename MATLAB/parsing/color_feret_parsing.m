function data = color_feret_parsing(dataset_root)

% Derive the dataset folder
img_foldername = [dataset_root, 'colorferet/images/'];

% Derive information about this folder
img_folder_list = get_folder_list(img_foldername);

% Derive the number of folders contained
Nfolders = size(img_folder_list,1);

% Initialize the data counter
k = 1;
for n = 1:Nfolders
    % Derive the subfoldername
    subfoldername = img_folder_list{n};
    
    % Derive the subject_id
    subj_id = str2double(subfoldername);
    
    % Derive the full_path of the subfolder
    subfoldername_fp = [img_foldername, subfoldername,'/'];
    
    % Derive a list of files contained within this folder
    img_list = get_file_list(subfoldername_fp,'ppm');
    
    % Multiple image of the same subject is considered
    for m = 1:size(img_list,1)
        % Derive the image filename considered
        img_filename = img_list{m};
        
        % Only fa and fb images will be considered
        if ~isempty(strfind(img_filename,'_fa')) || ~isempty(strfind(img_filename,'_fb'))
            % Derive the full image filename
            img_filename_fp = [subfoldername_fp, img_filename];
            % Derive the xml filename
            xml_filename = color_feret_xml_from_img_filename(img_filename_fp);
            
            % Check that the xml filename exists
            if exist(xml_filename,'file') % It exists
                % Derive the eye coordinates from the color feret metadata
                face_info = color_feret_get_metadata(xml_filename);
                
                % Check that the xml file contains face related information
                if ~isempty(face_info) % Left Eye and Right Eye coordinates available
                    % Include in the data the subj_id
                    data.subj_id{k} = subj_id;
                    % Include in the data the landmark points
                    data.landmark_pts{k} = face_info;
                    % Include in the data the filename
                    data.img_filename{k} = img_filename_fp;
                    % Increment the counter
                    k = k + 1;
                end
            end
        end
    end
end

function face_info = color_feret_get_metadata(xml_filename)


% Open the xml file
fid = fopen(xml_filename,'r');

face_info = [];

if fid == -1
    return;
end
while ~feof(fid)
    % Read a line
    line = fgetl(fid);
    
    % try to fine command LeftEye or RightEye
    if ~isempty(strfind(line,'LeftEye'))
        % This line contains information about left eye
        indx1 = strfind(line,'x=');
        indx2 = strfind(line,'y=');
        indx3 = strfind(line,'/>');
        substr1 = line(indx1+2:indx2-1);
        substr2 = line(indx2+2:indx3-1);
        indx1 = strfind(substr1,'"');
        indx2 = strfind(substr2,'"');
        face_info.LeftEye(1) = str2double(substr1(indx1(1)+1:indx1(2)-1));
        face_info.LeftEye(2)= str2double(substr2(indx2(1)+1:indx2(2)-1));
    elseif ~isempty(strfind(line,'RightEye'))
        % This line contains information about left eye
        indx1 = strfind(line,'x=');
        indx2 = strfind(line,'y=');
        indx3 = strfind(line,'/>');
        substr1 = line(indx1+2:indx2-1);
        substr2 = line(indx2+2:indx3-1);
        indx1 = strfind(substr1,'"');
        indx2 = strfind(substr2,'"');
        face_info.RightEye(1) = str2double(substr1(indx1(1)+1:indx1(2)-1));
        face_info.RightEye(2) = str2double(substr2(indx2(1)+1:indx2(2)-1));
    elseif ~isempty(strfind(line,'Mouth'))
        % This line contains information about left eye
        indx1 = strfind(line,'x=');
        indx2 = strfind(line,'y=');
        indx3 = strfind(line,'/>');
        substr1 = line(indx1+2:indx2-1);
        substr2 = line(indx2+2:indx3-1);
        indx1 = strfind(substr1,'"');
        indx2 = strfind(substr2,'"');
        face_info.Mouth(1) = str2double(substr1(indx1(1)+1:indx1(2)-1));
        face_info.Mouth(2) = str2double(substr2(indx2(1)+1:indx2(2)-1));
    end
end

% Close the xml file
fclose(fid);

function xml_filename = color_feret_xml_from_img_filename(img_filename)
% This function is used to convert the img_filename to the xml_filename
indx = strfind(img_filename,'images');
xml_filename = [img_filename(1:indx-1),'xml',img_filename(indx+length('images'):end)];
xml_filename(end-2:end) = 'xml';