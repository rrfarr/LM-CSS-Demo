function datasets_report(SETS)
% This script will report information about the datasets being used. This
% is important especially when describing the datasets used for the
% experiment in research papers.

% Derive the foldername containing the report
foldername = 'REPORTS/';

% Make sure that the folder exists
if ~exist(foldername,'dir')
    mkdir(foldername);
end

% Open the file
fid = fopen([foldername,'datasets_report.DAT'],'w');
fprintf(fid,'--------------------------------------------------------------------------------\n');
fprintf(fid,'DATASETS REPORT\n');
fprintf(fid,'--------------------------------------------------------------------------------\n');
fprintf(fid,'Five different datasets were considered in the implementation\n');
fprintf(fid,'of this experiment: Colorferet, MEDS, AR, Multi-Pie, and FRGC\n');
fprintf(fid,'The AR dataset was used to build up the training set to be used to\n');
fprintf(fid,'train the face recognition algorithm. This resulted in %d images\n', SETS.Training.Nfaces);
fprintf(fid,'used to train the face recognizer. The Gallery consists of %d faces which\n', SETS.Gallery.Nfaces);
fprintf(fid,'considers one photo per subject, and includes unique subjects from the MEDS\n');
fprintf(fid,'and FRGC dataset (controlled environment). The probe set consists of %d\n', SETS.Probe.Nfaces);
fprintf(fid,'images taken from the FRGC dataset (uncontrolled environment).\n');
fprintf(fid,'The dictionary to be used to train the super-resolution methods\n');
fprintf(fid,'consists of %d images (%d unique subjects) which combines images from \n', SETS.Dictionary.Nfaces, SETS.Dictionary.Nunique);
fprintf(fid,'both the ColorFeret and Multi-Pie datasets.\n');
fprintf(fid,'--------------------------------------------------------------------------------\n');
% Close the file
fclose(fid);