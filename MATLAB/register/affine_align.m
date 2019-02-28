function face = affine_align(I, landmark_pts,nx)
% The affine transform will get an image I and landmark points (right eye,
% left eye and mouth center coordinates) and align it so that it has a
% fixed offset (0.2 by default) and a distance nx between the eyes.

% Set the configuration of the transformaiton
offset_pct = 0.2; 
if nargin == 2
    nx = 100;
end

dest_sz = round(nx/0.6);

% Extract the landmark points
eye_right = landmark_pts.RightEye;
eye_left  = landmark_pts.LeftEye;
mouth     = landmark_pts.Mouth;

% Deri100ve the offset
offset = floor(offset_pct * dest_sz);

% Derive the reference points where the eyes and mouth need to be warped
eye_right_ref = [offset, offset];
eye_left_ref  = [dest_sz - offset, offset];
mouth_ref     = [dest_sz/2, dest_sz - offset];

% Find the minimum dimaneison
min_dim = min(size(I,1),size(I,2));

if min_dim < dest_sz
    % Find the required scaling valune
    scale = dest_sz / min_dim;
    
    eye_right = eye_right * scale;
    eye_left = eye_left * scale;
    mouth = mouth * scale;
    
    % Rescape the image based on the scale
    I = imresize(I, scale);
end

% Approximate the affine transformation matrix
hgte1 = vision.GeometricTransformEstimator('ExcludeOutliers', false);
tform = step(hgte1, [eye_right; eye_left; mouth],[eye_right_ref; eye_left_ref; mouth_ref]);

% Compute the affine transformation based on the approximated transform
% matrix
hgt = vision.GeometricTransformer;
Itrans = step(hgt, double(I), tform);

% Extract the face image
face = uint8(Itrans(1:dest_sz,1:dest_sz,:));