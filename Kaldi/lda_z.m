function [V, mean_X] = lda_z(data, labels)

dim = size(data, 1);
nclass = max(labels);

% compute within-class scatter matrix
%--------------------------------------
mean_X = mean(data, 2);
Sw = zeros(dim, dim);
Sb = zeros(dim, dim);

for i = 1:nclass,
    inx_i = find(labels == i);
    X_i = data(:, inx_i);

    mean_Xi = mean(X_i, 2);
    Sw = Sw + cov( X_i', 1);
    Sb = Sb + length(inx_i) * (mean_Xi - mean_X) * (mean_Xi - mean_X)';
end

[V, D] = eig(Sw \ Sb);
[D, inx] = sort(diag(D), 1, 'descend');

% take new_dim biggest eigenvectors
V = V(: , inx(1 : dim));
return;
% EOF