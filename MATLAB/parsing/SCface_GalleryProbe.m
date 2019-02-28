function SETS = SCface_GalleryProbe(SETS)

% Determine the dataset filename
foldername = 'DATASET/SCface_database/';

% Open the file containing metadata
fid = fopen([foldername,'all.txt'],'r');

Gallery.subj = cell(130,1);

while ~feof(fid)
    % Read one line at a time
    line = fgetl(fid);
    
    % Read the foldername
    [filename,landmark_pts,subj_id] = scface_parsing(line);

    if strfind(filename,'frontal')
        % This image goes into the gallery set
        gallery_foldername = [foldername,'mugshot_frontal_original_all/'];
        
        % Derive the filename
        img_filename = [gallery_foldername, filename,'.jpg'];
        
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
            probe_foldername = sprintf('%ssurveillance_cameras_distance_%d/cam_%d/',foldername,dist_idx,cam_idx);
            
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

function [filename,landmark_pts,subj_id] = scface_parsing(line)
% Find the index of the tab delimiter
idx = find(line == 9);
% Derive the filename
filename = line(1:idx(1)-1);
landmark_pts{1}.RightEye = [str2double(line(idx(1):idx(2)-1)),str2double(line(idx(2):idx(3)-1))];
landmark_pts{1}.LeftEye  = [str2double(line(idx(3):idx(4)-1)),str2double(line(idx(4):idx(5)-1))];
landmark_pts{1}.Mouth    = [str2double(line(idx(7):idx(8)-1)),str2double(line(idx(8):end))];
subj_id = str2double(filename(1:3));