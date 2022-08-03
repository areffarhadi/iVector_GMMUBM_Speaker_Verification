function scores = kaldi_log_likelihood_ratio(plda, model_ivectors, test_ivectors)
mean_ = plda.psi_ ./ (plda.psi_ + 1);
var_ = 1 + mean_;
var_i = (var_ .^ -1)';
dim = size(model_ivectors, 1);
logdet = sum(log(var_));
log_2pi = log(2 * pi) * dim;
scores = zeros(size(model_ivectors, 2), size(test_ivectors, 2));
for i = 1 : size(model_ivectors, 2)
    m = model_ivectors(:, i) .* mean_;
    for j = 1 : size(test_ivectors, 2)
        sqdiff = (test_ivectors(:, j) - m) .^ 2;
        scores(i, j) = -0.5 * (logdet + log_2pi + var_i * sqdiff);
    end
end
% var_ = 1 + plda.psi_;
% var_i = (var_ .^ -1)';
% logdet = sum(log(var_));
% for j = 1 : size(test_ivectors, 2)
%     sqdiff = test_ivectors(:, j) .^ 2;
%     scores(:, j) = scores(:, j) + 0.5 * (logdet + log_2pi + var_i * sqdiff);
% end