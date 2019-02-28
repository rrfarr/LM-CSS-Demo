function [psnr_metric, ssim_metric, fsim_metric] = face_quality_eval(hr_face, lr_face)

% Compute the psnr quality metric
psnr_metric = psnr(lr_face, hr_face);
        
% Compute the ssim metric
ssim_metric = ssim(lr_face, hr_face);
        
% Compute the fsim metric
fsim_metric = FeatureSIM(lr_face, hr_face);

