function trans_ivectors = kaldi_transform_ivector(plda, ivectors)
trans_ivectors = zeros(size(ivectors));
for i = 1 : size(ivectors, 2)
    transformed_ivector = plda.offset_;
    transformed_ivector = transformed_ivector + plda.transform_ * ivectors(:, i);
    transformed_ivector = transformed_ivector * get_normalization_factor(plda.psi_, transformed_ivector);
    trans_ivectors(:, i) = transformed_ivector;
end

function factor = get_normalization_factor(psi, transformed_ivector)
sq = transformed_ivector .^ 2;
inv_covar = (psi + 1) .^ -1;
factor = sqrt(length(transformed_ivector) / sum(sq .* inv_covar));