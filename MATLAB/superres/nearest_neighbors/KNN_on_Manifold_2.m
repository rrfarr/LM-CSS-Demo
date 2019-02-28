function idx = KNN_on_Manifold_2(xp, X, A, sig, beta, m, K)
% This function compute KNN on the manifold using the Ranking on Manifold
% paper. Here xp is a low resolution vector, X is the low resolution
% dictionary, A is the pre-computed affinity matrix, sig is the scaling
% parameter, alpha specifies the relative amount of the information from 
% its neighbors and its initial label information and K is the number of
% neighbours.
%
% Designed: Reuben Farrugia
% Date: 24/9/2015

% Compute the affinity between xp and the dictionary X
a = affinity(X,xp,sig);

% Concatenate the probe affinity with the pre-computed gallery affinity
A = [0,a;a',A];

% Mark the first column as a probe
y = [1; zeros(size(a,2),1)];

% Compute the sume of the rows of A
D = diag(sum(A,2));

% Derive the Laplacian matrix
Lu = D - A;

% Compute the ranking on the manifold
f_star = (inv(beta * eye(size(y,1)) + Lu).^m) * y;

% Icnore the first entry since that belongs to the probe
f_star(1) = [];

% Determine the index of the entires with the highest scores
[~, idx] = sort(f_star,'descend');

% Choose the closest K neighbours on the manifold
idx = idx(1:K);

