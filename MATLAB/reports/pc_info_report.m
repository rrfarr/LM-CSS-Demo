function pc_info_report(pc_info, method_fullname)

% ---- PC information
% Derive the filename
filename = sprintf('RESULTS/%s/pc_info.TXT', method_fullname);

% Open the file
fid = fopen(filename,'w');
fprintf(fid, 'Computer Architecture: %s\n', pc_info.computer_architecture);
fprintf(fid, 'Operating System: %s\n', pc_info.OSType);
fprintf(fid, 'OS Version: %s\n', pc_info.OSVersion);
fprintf(fid, 'CPU: %s\n', pc_info.cpuname);
fprintf(fid, 'Clock: %s\n', pc_info.clock);
fprintf(fid, 'Cache: %s\n', pc_info.cache);
fprintf(fid, 'Number of Processors: %d\n',pc_info.Nprocessors);

% Close the file
fclose(fid);