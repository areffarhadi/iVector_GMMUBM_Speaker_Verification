function scores = score_gplda_trials2(plda, model_iv, test_iv)

if ~isstruct(plda),
	fprintf(1, 'Error: plda should be a structure!\n');
	return;
end

Phi     = plda.Phi;
Sigma   = plda.Sigma;
W       = plda.W;
M       = plda.M;

%%%%% post-processing the model i-vectors %%%%%
model_iv = bsxfun(@minus, model_iv, M); % centering the data
model_iv = length_norm(model_iv); % normalizing the length
model_iv = W' * model_iv; % whitening data

%%%%% post-processing the test i-vectors %%%%%
test_iv = bsxfun(@minus, test_iv, M); % centering the data
test_iv = length_norm(test_iv); % normalizing the length
test_iv  = W' * test_iv; % whitening data

Sigma_ac  = Phi * Phi';
Sigma_tot = Sigma_ac + Sigma;
Sigma_tot_i = pinv(Sigma_tot);
ss = Sigma_ac * Sigma_tot_i;
scores = zeros(size(model_iv, 2), size(test_iv, 2));
Sigma = Sigma_tot - Sigma_ac * Sigma_tot_i * Sigma_ac;
Sigma_i = pinv(Sigma);
for i = 1 : size(model_iv, 2)
    mu = ss * model_iv(:, i);
    for j = 1 : size(test_iv, 2)
        p = (-0.5 * (test_iv(:, j) - mu)' * Sigma_i * (test_iv(:, j) - mu));% - ...
%             (-0.5 * test_iv(:, j)' * Sigma_tot_i * test_iv(:, j));
%         p = (-0.5 * log(det(Sigma)) -0.5 * (test_iv(:, j) - mu)' * Sigma_i * (test_iv(:, j) - mu));% - ...
%             (-0.5 * log(det(Sigma_tot)) -0.5 * test_iv(:, j)' * Sigma_tot_i * test_iv(:, j));
        scores(i, j) = p;
    end
end
