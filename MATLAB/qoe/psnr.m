function metric = psnr(I1,I2)
% Calculate the mean square error
mse = mean2((double(I1) - double(I2)).^2);
% Derive the psnr metric
metric = 20*log10(255/sqrt(mse));