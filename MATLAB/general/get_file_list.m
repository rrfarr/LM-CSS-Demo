function list = get_file_list(foldername,ext)
% Derive the information about this folder 
info = dir([foldername,'*.',ext]);
% Return the list of images with extension ext
list = {info(:).name}';