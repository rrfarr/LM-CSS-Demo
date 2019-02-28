function SETS = SCface_dataset_selection(config)
fprintf(1, 'Starting Loading the the SR dataset information ...\n');
% Generate the information about the datasets to be used in the simulation

if ~exist(config.set_filename,'file')
    % Load the SETS used for test 1
    load('SET_INFO/single_face_SR_SET.MAT');

    % Put the training and dictionary in the sets
    SETS_2.Training = SETS.Training;
    SETS_2.Dictionary = SETS.Dictionary;

    % Clear the sets
    clear('SETS');

    % Put the temporary set into SETS
    SETS = SETS_2;

    % Clear the temporary sets
    clear('SETS_2');

    % Define the folder where the dataset is contained
    SC_face_root_folder = '../../../../../DataSets/SCface_database/';

    % Open the file containing metadata
    fid = fopen([SC_face_root_folder,'all.txt'],'r');

    Gallery.subj = cell(130,1);

    while ~feof(fid)
        % Read one line at a time
        line = fgetl(fid);
    
        if strcmp(line,'')
            break;
        end
    
        % Read the foldername
        [filename,landmark_pts,subj_id] = scface_parsing(line);

        if strfind(filename,'frontal')
            % This image goes into the gallery set
            gallery_foldername = [SC_face_root_folder,'mugshot_frontal_original_cropped/'];
        
            % Derive the filename
            img_filename{1} = [gallery_foldername, filename,'.jpg'];
        
            % Put this into the gallery
            Gallery.subj{subj_id}.img_filename = img_filename;
        
            % Specify the subject id
            Gallery.subj{subj_id}.subj_id = {subj_id};
        
            % Specify the landmark pts
            Gallery.subj{subj_id}.landmark_pts = landmark_pts;
        else
            cam_idx = str2double(line(8));
    
            if cam_idx <=5
                % Get the distance idx
                dist_idx = str2double(line(10));
    
                % Derive the probe foldername
                probe_foldername = sprintf('%ssurveillance_cameras_distance_%d/cam_%d/',SC_face_root_folder,dist_idx,cam_idx);
            
                % Derive the filename
                img_filename = [probe_foldername, filename,'.jpg'];
            
                % Put this into the gallery
                Probe.subj{subj_id}.img_filename{cam_idx,dist_idx} = img_filename;
        
                % Specify the subject id
                Probe.subj{subj_id}.subj_id{cam_idx,dist_idx} = {subj_id};
        
                % Specify the landmark pts
                Probe.subj{subj_id}.landmark_pts{cam_idx,dist_idx} = landmark_pts;
            end
        end
    end

    SETS.Gallery.Nfaces = 130;
    SETS.Gallery.Nunique = 130;
    SETS.Gallery.subj = Gallery.subj;
    SETS.Probe.Nfaces = 5*130;
    SETS.Probe.Nunique = 130;
    SETS.Probe.subj = Probe.subj;
    fclose(fid);
    
    % Save the datasetsset within the mat file specified in
    % config.set_filename
    save(config.set_filename,'SETS');
else
    % Load the information contain in the set
    load(config.set_filename);
end
fprintf(1,'The SR dataset information completed\n');

function [filename,landmark_pts,subj_id] = scface_parsing(line)
% Find the index of the tab delimiter
idx = find(line == 9);
% Derive the filename
filename = line(1:idx(1)-1);
landmark_pts{1}.RightEye = [str2double(line(idx(1):idx(2)-1)),str2double(line(idx(2):idx(3)-1))];
landmark_pts{1}.LeftEye  = [str2double(line(idx(3):idx(4)-1)),str2double(line(idx(4):idx(5)-1))];
landmark_pts{1}.Mouth    = [str2double(line(idx(7):idx(8)-1)),str2double(line(idx(8):end))];
subj_id = str2double(filename(1:3));