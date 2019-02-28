function [Xs, mu_X, sig_X] = standardize(X, mu_X, sig_X)

if nargin == 1
    % Determine the mean vector
    mu_X = mean(X);
    
    % Determine the standard deviation row vector
    sig_X = std(X);
    
    % Set the standard deviation to unit in case it is zero
    sig_X(sig_X == 0) = 1; % To avoid nan in regression
end
% Compute the standardization
Xs = (X - repmat(mu_X,[size(X,1),1])) ./ repmat(sig_X,[size(X,1),1]);