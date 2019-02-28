function wq = sum1_LS(x, X)

% Derive the patch vector size
Np = size(x,1) * size(x,2);

% Derive the number of dimensions
D = size(X,2);

% Convert x to a vector
x = reshape(x,Np,1);

% Compute the Gram Matrix of the patch
Gq = (x* ones(D,1)' - X)' * (x * ones(D,1)' - X);

% Derive the weights comulting the sum1_LS solution
wq = pinv(Gq) * ones(D,1) / (ones(D,1)' * pinv(Gq) * ones(D,1));



