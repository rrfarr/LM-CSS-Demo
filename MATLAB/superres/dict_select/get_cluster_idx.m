function k = get_cluster_idx(xp, C)

% Compute the euclidean distance between point xp and the centroids
d = mean((C - repmat(xp,[1,size(C,2)])).^2);

% Choose the centroid which has minimum distance
[~, k] = min(d);