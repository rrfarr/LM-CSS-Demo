function idx = KNN_on_Manifold(xp, X, A, sig, alpha, K)
% This function compute KNN on the manifold using the Ranking on Manifold
% paper. Here xp is a low resolution vector, X is the low resolution
% dictionary, A is the pre-computed affinity matrix, sig is the scaling
% parameter, alpha specifies the relative amount of the information from 
% its neighbors and its initial label information and K is the number of
% neighbours.
%
% Designed: Reuben Farrugia
% Date: 23/9/2015

% Compute the affinity between xp and the dictionary X
a = affinity(X,xp,sig);

% Concatenate the probe affinity with the pre-computed gallery affinity
A = [0,a;a',A];

% Mark the first column as a probe
y = [1; zeros(size(a,2),1)];

% Compute the sume of the rows of A
D = sum(A,2);

% Derive the square root and inverse matrix
D_inv = diag(1./sqrt(D));

% Symmetrically normalize the weights
S = D_inv * A * D_inv;

% Compute the ranking on the manifold
f_star = (eye(size(y,1)) - alpha * S) \ y;

% Icnore the first entry since that belongs to the probe
f_star(1) = [];

% Determine the index of the entires with the highest scores
[~, idx] = sort(f_star,'descend');

% Choose the closest K neighbours on the manifold
idx = idx(1:K);

