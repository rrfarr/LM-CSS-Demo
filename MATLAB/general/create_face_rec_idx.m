function [probe, gallery] = create_face_rec_idx(probe, gallery)
% This function will include a field within the probe and gallery sets of a
% field named face_rec_id which correpsonds to the face recognition
% identifier which will be used during face recognition.

for n = 1:size(gallery.subj,1)
    % Derive the subject id of the current subject
    subj_id_gallery = gallery.subj{n}.subj_id{1};
    
    
    if n <= size(probe.subj,1)
        for m = 1:size(probe.subj,1)
            % Derive the subj id of the probe
            subj_id_probe = probe.subj{m}.subj_id{1};
        
            if subj_id_gallery == subj_id_probe
                break;
            end
        end
        probe.subj{m}.face_rec_id = n;
    end
    gallery.subj{n}.face_rec_id = n;
end
