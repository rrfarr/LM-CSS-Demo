function Xs = image_shift(X,hor_shift,ver_shift)
% This function provides the shifted image Xs by a horizontal and vertical
% component. This is done using affine transformation.

% Derive the transformation affine matrix needed to translate the iamge
tform_translate   = maketform('affine',[1,0,0;0,1,0;hor_shift,ver_shift,1]);

% Compute the translation
Xs = imtransform(X,tform_translate,'bicubic','XData',[1,size(X,2)],'YData',[1,size(X,1)]);


