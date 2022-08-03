function [V, plda, W, dev_mean_pca] = trainLdaAndPlda(modelsOutputDir, dev_ivectors, ivec_idx)
global params;
lda_dim = params.ldaDim;
nphi    = params.pldaDim;
niter   = 20;
pldaFilename = [modelsOutputDir 'Plda'];
if (params.usePca)
    pldaFilename = [pldaFilename '_Pca-' num2str(params.numOfPrincomp)];
end
if (params.useLda)
    pldaFilename = [pldaFilename '_Lda-' num2str(params.ldaDim)];
end
pldaFilename = [pldaFilename '.mat'];
if (~exist(pldaFilename, 'file'))
    % reduce the dimensionality with LDA
    normalized_dev_ivectors = NormalizeNorm(dev_ivectors)';
    if (params.usePca)
        [coeff, ~, latent] = princomp(normalized_dev_ivectors');
        dev_mean_pca = mean(normalized_dev_ivectors, 2);
        normalized_dev_ivectors = bsxfun(@minus, normalized_dev_ivectors, dev_mean_pca);
        W = (coeff(:, 1 : params.numOfPrincomp) * diag(1./sqrt(latent(1 : params.numOfPrincomp))))';
        normalized_dev_ivectors = NormalizeNorm(W * normalized_dev_ivectors, 2);
    end
    V = lda_kaldi(normalized_dev_ivectors, ivec_idx);
    lda_dim = min(size(V, 2), lda_dim);
    dev_mean = mean(normalized_dev_ivectors, 2);
    if (params.useLda)
        normalized_dev_ivectors = bsxfun(@minus, normalized_dev_ivectors, dev_mean);
        normalized_dev_ivectors = V(:, 1 : lda_dim)' * normalized_dev_ivectors;
        normalized_dev_ivectors = NormalizeNorm(normalized_dev_ivectors, 2);
    end
    plda = gplda_em(normalized_dev_ivectors, ivec_idx, nphi, niter);
    if (params.usePca)
        save(pldaFilename, 'plda', 'V', 'lda_dim', 'coeff', 'latent', 'dev_mean_pca');
    else
        save(pldaFilename, 'plda', 'V', 'lda_dim');
    end
else
    load(pldaFilename);
end
if (params.usePca)
    W = (coeff(:, 1 : params.numOfPrincomp) * diag(1./sqrt(latent(1 : params.numOfPrincomp))));
    dev_mean_pca = dev_mean_pca';
else
    W = [];
    dev_mean_pca = 0;
end

Phi     = plda.Phi;
Sigma   = plda.Sigma;
Sigma_ac  = Phi * Phi';
Sigma_tot = Sigma_ac + Sigma;
Sigma_tot_i = pinv(Sigma_tot);
Sigma_i = pinv(Sigma_tot - Sigma_ac * Sigma_tot_i * Sigma_ac);
Sigma_ac_Sigma_tot_i = Sigma_ac * Sigma_tot_i;
plda.Agp = Sigma_ac_Sigma_tot_i' * (Sigma_i' + Sigma_i);
plda.Agg = Sigma_ac_Sigma_tot_i' * Sigma_i * Sigma_ac_Sigma_tot_i;
params.ldaDim = lda_dim;