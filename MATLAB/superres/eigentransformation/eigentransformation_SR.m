function IH = eigentransformation_SR(xl, hr_dictionary)
% This function is used to compute the eigentransformation. It receives the
% low resolution face image, a dictionary of high resolution face images.
% The images contained within the dictionary will be sub-sampled to the
% resolution of xl and eigentransformation is used to derive the projection
% weights to develop a prototype of xl using the eigenfaces provided by the
% low resolution face images in the dictionary. These projeciton weights
% will then be used to hallucinate the high resolution face image.
%
% Designed: Reuben Farrugia
% Date: 27/2/2015
%

% Convert the low resolution image to double
xl = double(xl);

% --- Derive the projection weights

% Derive the number of images in the dictionary
Nimgs = size(hr_dictionary.HR_face,1);

% Derive the dimensions of the high res image
[Hh,Wh] = size(hr_dictionary.HR_face{1});

% Initialize the matrix H which will contain the high resolution vectors
Hv = zeros(Hh*Wh,Nimgs);

% Derive the image resolution
resolution = size(xl,1);

% Convert the low resolution target image to vector
xl = reshape(xl,[resolution^2,1]);

% Initialize the matrix L which will contain the low resolution vectors
Lv = zeros(resolution^2,Nimgs);

% Convert the list of Ih_list into vectors of type double
for n = 1:Nimgs
    % Extract the high resolution training image
    Ih = hr_dictionary.HR_face{n};
    
    % Derive the corresponding low resolution image
    Il = imresize(Ih,[resolution,resolution]);
    
    % Convert the high resolution image to a vector (double type)
    Ih = double(reshape(Ih, [size(Ih,1)*size(Ih,2),1]));
    
    % Convert the low resolution image to a vector
    Il = double(reshape(Il, [size(Il,1)*size(Il,2),1]));
   
    % Put the high resolution vector
    Hv(:,n) = Ih;
    
    % Put the low resolution vector
    Lv(:,n) = Il;
end

% Compute the mean vector
M = mean(Lv,2);

% Derive the difference vector L
L = Lv - repmat(M,[1,Nimgs]);

% Compute the covariance matrix
C = L'*L;

% Derive the eigen values and eigenvectors of the covariance matrix
[Evector,Evalue] = eig(C);

% Derive the eigenvectors and eigenvalues that cover 99% of the variance
[V,D] = eigenvector_selection(Evector,diag(Evalue),0.99);

% Derive the Eigenfaces
E = L * V * diag(1./sqrt(D));

% Derive the projection parameters
w = E'*(xl - M);

% Derive the weights
c = V * diag(1./sqrt(D))* w;

% --- Projection on high resolution

% This is a parameter used for noise suppression
a = 2;

% Compute the mean vector
M = mean(Hv,2);

% Derive the difference vector L
H = Hv - repmat(M,[1,Nimgs]);

% Reconstruct the high resolution image
xh = round(H * c + M);

% Compute the covariance matrix
C = H'*H;

% Derive the eigen values and eigenvectors of the covariance matrix
[Evector,Evalue] = eig(C);

% Derive the eigenvectors and eigenvalues that cover 99% of the variance
[V,lambda] = eigenvector_selection(Evector,diag(Evalue),0.99);

% Derive the Eigenfaces
Eh = H * V * diag(1./sqrt(lambda));

% Derive the projection parameters
wh = Eh'*(xh - M);

% Find where the magnitude of wh is smaller than a threshold - to avoid
% distortions 
indx = find(abs(wh) > a*sqrt(lambda));

if ~isempty(indx)
    wh(indx) = sign(wh(indx)) * a * sqrt(lambda(indx));
end

% Return the modified high resolution image
xh = uint8(Eh * wh + M);

% Reshape the face image
IH = reshape(xh,[Hh,Wh]);
