function [V,D] = eigenvector_selection(Evector,Evalues, T)

% Sort the Eigenvalues in descending order
[Evalues, I] = sort(Evalues,'descend');

if nargin == 3
    % Initialize the accumulative eigenvalues
    s = 0;
    for n = 1:size(Evalues,1)
        % Derive the accumulative variance
        s = s + Evalues(n);
    
        % Calculate the overall energy within the current n
        ratio = s/sum(Evalues,1);
    
        if ratio > T
            % Truncate the other indices
            I = I(1:n);
            % Return the vale
            break;
        end
    end
    % Derive the eigenvectors selected
    V = Evector(:,I);

    % Derive the selected eigenvalues
    D = Evalues(1:n);
elseif nargin == 2
    I(Evalues < 0) = [];
    Evalues(Evalues < 0) = [];
    % Derive the eigenvectors selected
    V = Evector(:,I);

    % Derive the selected eigenvalues
    D = Evalues;
end

