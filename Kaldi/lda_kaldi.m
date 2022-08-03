function [V, mean_X] = lda_kaldi(data, labels)

dim = size(data, 1);
nclass = max(labels);
total_covariance_factor = 0.1;
% compute within-class scatter matrix
%--------------------------------------
mean_X = mean(data, 2);
data = bsxfun(@minus, data, mean_X);

tot_covar_ = zeros(dim, dim);
between_covar_ = zeros(dim, dim);

for i = 1 : nclass
    inx_i = find(labels == i);
    X_i = data(:, inx_i);
    mean_Xi = mean(X_i, 2);
    
    tot_covar_ = tot_covar_ + X_i * X_i';
    between_covar_ = between_covar_ + length(inx_i) * (mean_Xi * mean_Xi');
end
total_covar = tot_covar_ / size(data, 2);
within_covar = (tot_covar_ - between_covar_) / size(data, 2);
mat_to_normalize = total_covariance_factor * total_covar + (1 - total_covariance_factor) * within_covar;

T = chol(mat_to_normalize, 'lower') ^ -1;

between_covar = total_covar - within_covar;
between_covar_proj = T * between_covar * T';
[U, s] = schur(between_covar_proj);
s = diag(s);
[~, inx] = sort(s, 1, 'descend');
U = U(: , inx(1 : dim));
V = T' * U;
return;
% EOF