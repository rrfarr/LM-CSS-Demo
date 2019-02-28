function idx = orthogonal_matching_pursuit(X,y,K)
% This function tries to find the support of beta where beta is said to be
% k-sparse 

% Normalize the input dictionary using l2 norm
X = X./repmat(sqrt(sum(X.^2,1)),[size(X,1),1]);

% Normalie the vector xp using l2 norm
y = y / norm(y,2);

%-----------------------------------
% Initialization
%-----------------------------------
% Initialize the residual vector
ri = y;               
% Initialize the array containing the support vectors
Xc = zeros(size(X,1),K);
% Initialize the array containing the indices of the selected support
idx = zeros(K,1);

for i = 1:K
    
    % Find the index that maximizes the correlation with the residual
    [~,t] = max(abs(X'*ri));
    
    % Put the selected vector in the list
    Xc(:,i) = X(:,t);
    
    % Put t as selected support
    idx(i)  = t;
    
    % Project the selected vector
    Pi = Xc * pinv(Xc'*Xc) *Xc';
    
    % Compute the new residual
    ri = (eye(size(Pi,1)) - Pi)*y;
end