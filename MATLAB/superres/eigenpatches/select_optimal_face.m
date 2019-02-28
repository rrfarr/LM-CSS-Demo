function Ys_star = select_optimal_face(Ys, x)

% Determine the number of search points to consider
[N1,N2] = size(Ys);

% Derive the sub-sampling scale
scale = size(x,1)/size(Ys{1,1},1);

% Initialize the distance to infinite
E = inf;

for n1 = 1:N1
    for n2 = 1:N2
        % Subsample the tentative image
        Ys_l = double(imresize(uint8(Ys{n1,n2}),scale));
        
        % Compute the absolute error
        E_c = mean2(abs(Ys_l - x));
        
        if E_c < E
            % Set the current 
            Ys_star = Ys{n1,n2};
            
            % Update the error threshold
            E = E_c; 
        end
        
    end
end