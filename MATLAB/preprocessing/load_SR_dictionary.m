function HR_face = load_SR_dictionary(SR_dictionary)
% Derive the number of images
 Ndict = size(SR_dictionary,1);
    
 % Initialize the SR_dictionary of high resolution images
 HR_face = cell(Ndict,1);
    
 for n = 1:Ndict
     % Derive the image considered
     img_filename = SR_dictionary{n}.aligned_img_filename{1}; % Using 1 since we know only one image per subject

     % Load the image
     Irgb = imread(img_filename);
        
     % Convert the image to ycbcr
     Iycbcr = rgb2ycbcr(Irgb);
        
     % Consider only the luminance component
     HR_face{n} = Iycbcr(:,:,1);
 end
    

