function statistical_report(probe_set, complexity, psnr_metric, ssim_metric, fsim_metric, dx,method_fullname)

% Derive the number of subjects
Nsubj = size(probe_set,1);

% Derive the number of images per probe
Nimgs = size(probe_set{1}.img_filename,2);

% Derive the performance filename
performance_filename = sprintf('RESULTS/%s/performance_dx_%d.CSV', method_fullname, dx);

% Open the file to store the performance
fid = fopen(performance_filename,'w');
    
% Print the header data
fprintf(fid,'subj_id, filename, complexity, psnr, ssim, fsim\n');
for n = 1:Nsubj
    for m = 1:Nimgs
        % Derive additional informaiton
        subj_id = n;
        img_filename = probe_set{n}.aligned_img_filename{m};
        
        % Print the informaiton in the csv file
        fprintf(fid,'%d,%s,%0.4f,%0.4f,%0.4f,%0.4f\n',subj_id,img_filename,complexity(n,m),psnr_metric(n,m),ssim_metric(n,m),fsim_metric(n,m));
    end
end
    
% Close the file
fclose(fid);



