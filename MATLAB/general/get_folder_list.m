function img_folder_list = get_folder_list(foldername)
% This function is used to return a list of folders contained within
% foldername and excludes all other files

% Derive information from the path
img_info = dir(foldername);
% Derive a logical vector (1 represent directory 0 otherwise)
isub = [img_info(:).isdir]; %# returns logical vector
% Retur image folder list
img_folder_list = {img_info(isub).name}';
% Delete the first two entries
img_folder_list(1:2) = [];