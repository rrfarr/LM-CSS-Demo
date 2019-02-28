function X = patch2imgQuilting(x, dim, patch_size, overlap)
% This method will combine the different patches using the average
% approach.

% Determine the number of patches
N = size(x,1);

% Derive the dimensions of the image
H = dim(1); W = dim(2);

% Derive the number of horizontal patches
Nh = ceil(W/(patch_size-overlap));

% Derive the number of vertical patches
Nv = ceil(H/(patch_size-overlap));

% Derive the configuration structure
config.dim_x = [Nv,Nh];
config.patch_size = patch_size;
config.overlap = overlap;

for k = 1:N
    % Extract the current patch values
    patch = x{k};
    
    % Get the start and termination point affecting the current patch
    idxC_pts = get_patch_idx_pts(k, config);
    
    % Get upper and lower patch neighbor index
    [idxU, idxL] = get_neighbors(k,[Nv,Nh]);
    
    if isnan(idxU) && isnan(idxL) % This block has no neighbors
        % Put the current patch in the current location
        X(idxC_pts.strt(1):idxC_pts.end(1), idxC_pts.strt(2):idxC_pts.end(2)) = patch;
    elseif isnan(idxU) % There is no upper block
        % Get the index of the neighboring block
        idxL_pts = get_patch_idx_pts(idxL, config);
        % Derive the patch from the image
        patch_L = X(idxL_pts.strt(1):idxL_pts.end(1), idxL_pts.strt(2):idxL_pts.end(2));
        % Extract the overlapping regions from the left patch
        O_L = patch_L(:,patch_size-overlap+1:patch_size);
        % Extract overlap from the current patch
        OcL = patch(:, 1:overlap);
        % Combine the overlapping regions
        O_L = quilting(O_L,OcL,'vertical'); % Using the average
        % Put the modified overlapping region in the image
        X(idxC_pts.strt(1):idxC_pts.end(1),idxC_pts.strt(2):idxC_pts.strt(2)+overlap-1) = O_L;
        % Put the non overlapping part in X
        X(idxC_pts.strt(1):idxC_pts.end(1),idxC_pts.strt(2)+overlap:idxC_pts.end(2)) = patch(:,overlap+1:end);
    elseif isnan(idxL) % There is no left neighbor
        % Get the index of the neighboring block
        idxU_pts = get_patch_idx_pts(idxU, config);
        % Derive the patch from the image
        patch_U = X(idxU_pts.strt(1):idxU_pts.end(1), idxU_pts.strt(2):idxU_pts.end(2));
        % Extract the overlapping regions from the upper patch
        O_U = patch_U(patch_size-overlap+1:patch_size,:);
        % Extract the overlap from the current patch
        OcU = patch(1:overlap,:);
        % Combine the overlapping regions
        O_U = quilting(O_U,OcU,'horizontal');
        % Put the modified overlap region in the image
        X(idxC_pts.strt(1):idxC_pts.strt(1)+overlap-1, idxC_pts.strt(2):idxC_pts.end(2)) = O_U;
        % Put the non overlapping part in X
        X(idxC_pts.strt(1)+overlap:idxC_pts.end(1), idxC_pts.strt(2):idxC_pts.end(2)) = patch(overlap+1:end,:);
    else               % All neighbors are present
        % Get the index of the neighboring block
        idxL_pts = get_patch_idx_pts(idxL, config);
        % Derive the patch from the image
        patch_L = X(idxL_pts.strt(1):idxL_pts.end(1), idxL_pts.strt(2):idxL_pts.end(2));
        % Extract the overlapping regions from the left patch
        O_L = patch_L(:,patch_size-overlap+1:patch_size);
        % Extract overlap from the current patch
        OcL = patch(:, 1:overlap);
        % Combine the overlapping regions
        O_L = quilting(O_L,OcL,'vertical');%round((O_L + OcL)/2); % Using the average
        % Put the modified overlapping region in the image
        X(idxC_pts.strt(1):idxC_pts.end(1),idxC_pts.strt(2):idxC_pts.strt(2)+overlap-1) = O_L;
        % Get the index of the neighboring block
        idxU_pts = get_patch_idx_pts(idxU, config);
        % Derive the patch from the image
        patch_U = X(idxU_pts.strt(1):idxU_pts.end(1), idxU_pts.strt(2):idxU_pts.end(2));
        % Extract the overlapping regions from the upper patch
        O_U = patch_U(patch_size-overlap+1:patch_size,:);
        % Extract the overlap from the current patch
        OcU = patch(1:overlap,:);
        % Combine the overlapping regions
        O_U = quilting(O_U,OcU,'horizontal');%round((O_U + OcU)/2); % Using the average
        % Put the modified overlap region in the image
        X(idxC_pts.strt(1):idxC_pts.strt(1)+overlap-1, idxC_pts.strt(2):idxC_pts.end(2)) = O_U;
        % Put the non overlapping part in X
        X(idxC_pts.strt(1)+overlap:idxC_pts.end(1), idxC_pts.strt(2)+overlap:idxC_pts.end(2)) = patch(overlap+1:end, overlap+1:end);
    end
end

% Reshape the image (it was normalized in range [0,255])
X = X(1:H,1:W);


function O_L = quilting(B1,B2,direction)


O_L = zeros(size(B1));

% Initialize a matrix E containing the cumulative minimum error
E = zeros(size(B1));

% Derive the error at each location
e = (B1 - B2).^2;

if strcmp(direction,'vertical')
    %% Forward path
    % Initialize the first row
    E(1,:) = e(1,:);
    for j = 2:size(E,1)
        % Derive the connected components
        for i = 1:size(E,2)
            if i == 1
                E1 = inf;
            else
                E1 = E(j-1,i-1);
            end
            E2 = E(j-1,i);
            if i == size(E,2)
                E3 = inf;
            else
                E3 = E(j-1,i+1);
            end
            
            % Derive the cumulative energy at this point
            E(j,i) = e(j,i) + min([E1,E2,E3]);
        end
    end
    
    %% Backtracking path
    Eb = zeros(size(E));
    
    N = size(E,1);
    
    % Find the minimum value in the last row
    [~,min_idx] = min(E(N,:));
    
    Eb(N,1:min_idx) = 1;
    
    for j = N-1:-1:1
        if min_idx == 1
            E1 = inf;
        else
            E1 = E(j,min_idx-1);
        end
        E2 = E(j,min_idx);
        if min_idx == size(E,2)
            E3 = inf;
        else
            E3 = E(j,min_idx+1);
        end
        
        % Find the smallest path
        [~, idx] = min([E1,E2,E3]);
        
        % Update the smallest path index
        min_idx = min_idx + idx - 2;

        % Update the mask
        Eb(j,1:min_idx) = 1;
    end
    roi_idx = find(Eb==1);
    O_L(roi_idx) = B1(roi_idx);
    roi_idx = find(Eb==0);
    O_L(roi_idx) = B2(roi_idx);
    
else
    %% Forward path
    % Initialize the first row
    E(:,1) = e(:,1);
    for j = 2:size(E,2)
        % Derive the connected components
        for i = 1:size(E,1)
            if i == 1
                E1 = inf;
            else
                E1 = E(i-1,j-1);
            end
            E2 = E(i,j-1);
            if i == size(E,1)
                E3 = inf;
            else
                E3 = E(i+1,j-1);
            end
            
            % Derive the cumulative energy at this point
            E(i,j) = e(i,j) + min([E1,E2,E3]);
        end
    end
    %% Backtracking path
    Eb = zeros(size(E));
    
    N = size(E,2);
    
    % Find the minimum value in the last row
    [~,min_idx] = min(E(:,N));
    
    Eb(1:min_idx,N) = 1;
    
    for j = N-1:-1:1
        if min_idx == 1
            E1 = inf;
        else
            E1 = E(min_idx-1,j);
        end
        E2 = E(min_idx,j);
        if min_idx == size(E,1)
            E3 = inf;
        else
            E3 = E(min_idx+1,j);
        end
        
        % Find the smallest path
        [~, idx] = min([E1,E2,E3]);
        
        % Update the smallest path index
        min_idx = min_idx + idx - 2;

        % Update the mask
        Eb(1:min_idx,j) = 1;
    end
    roi_idx = find(Eb==1);
    O_L(roi_idx) = B1(roi_idx);
    roi_idx = find(Eb==0);
    O_L(roi_idx) = B2(roi_idx);
end


function idx_pts = get_patch_idx_pts(idx, config)

% Derive the patch limits
Nv = config.dim_x(1);
Nh = config.dim_x(2);
patch_size = config.patch_size;
overlap = config.overlap;

% Derive the 2D index of this patch
x_idx = mod(idx-1, Nv)+1;
y_idx = floor((idx-1)/Nh) + 1;

% Derive the start points of the current idx
idx_pts.strt(2) = (x_idx-1)*(patch_size - overlap) + 1;
idx_pts.strt(1) = (y_idx-1)*(patch_size - overlap) + 1;

% Derive the end point sof the current idx
idx_pts.end = idx_pts.strt + patch_size-1;

function [idxU, idxL] = get_neighbors(idxC, dim)

% Derive the total number of columns (patch wise)
Nh = dim(2);

% Derive the index of the upper patch
idxU = idxC - Nh;
% If this index does not exist mark as -1
if idxU <= 0
    idxU = NaN;
end

% Derive the index of the left neighbor patch
idxL = idxC - 1;
% Ensure that it is the left neighbor
if mod(idxL,Nh) == 0
    idxL = NaN; 
end
