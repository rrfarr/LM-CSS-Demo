function x = img2patch(X, patch_size, overlap)

% Derive the dimensions of the image
[H,W] = size(X);

% Derive the number of horizontal patches
Nh = ceil(W/(patch_size-overlap));

% Derive the number of vertical patches
Nv = ceil(H/(patch_size-overlap));

% Derive the number of patches
N = Nh * Nv;

% Initialize x to contain N patches
x = cell(N,1);

% Initialize the n patch index
n_patch_strt = 1;
% Initialize the patch index
k = 1;
for n = 1:Nv
    % Initialize the m patch start to 1
    m_patch_strt = 1;
    for m = 1:Nh
        % Derive the m patch index
        m_patch_end = m_patch_strt + patch_size - 1;
        % Derive the n patch index
        n_patch_end = n_patch_strt + patch_size - 1;
        
        % Extract the kth patch
        if m_patch_end <= W && n_patch_end <= H
            x{k,1} = X(n_patch_strt:n_patch_end, m_patch_strt:m_patch_end);
        elseif m_patch_end <= W && n_patch_end > H
            x{k,1} = [X(n_patch_strt:H, m_patch_strt:m_patch_end); zeros(n_patch_end-H,patch_size)];
        elseif m_patch_end > W && n_patch_end > H
            x{k,1} = [[X(n_patch_strt:H, m_patch_strt:W), zeros(H-n_patch_strt+1,m_patch_end-W)]; zeros(n_patch_end-H,patch_size)];
        elseif m_patch_end > W && n_patch_end <= H
            x{k,1} = [X(n_patch_strt:n_patch_end, m_patch_strt:W), zeros(patch_size,m_patch_end-W)];
        end
        % Update the start values
        m_patch_strt = m_patch_end - overlap + 1;
        
        % Increment the patch counter
        k = k + 1;
    end
    % Update the n patch strt
    n_patch_strt = n_patch_end - overlap + 1;
end

