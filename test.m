p1 = -0.5 * log(det(Sigma_tot)) -0.5 * model_iv' * inv(Sigma_tot) * model_iv ...
    -0.5 * log(det(Sigma_tot)) -0.5 * test_iv(:, 1)' * inv(Sigma_tot) * test_iv(:, 1)

mu1 = Sigma_ac * inv(Sigma_tot) * model_iv;
ss0 = Sigma_tot - Sigma_ac * inv(Sigma_tot) * Sigma_ac;
p1 = (-0.5 * log(det(ss0)) -0.5 * (test_iv(:, 1) - mu1)' * inv(ss0) * (test_iv(:, 1) - mu1)) - ...
    (-0.5 * log(det(Sigma_tot)) -0.5 * test_iv(:, 1)' * inv(Sigma_tot) * test_iv(:, 1))
ss1 = [Sigma_tot Sigma_ac; Sigma_ac Sigma_tot];
ss2 = [Sigma_tot zeros(400); zeros(400) Sigma_tot];
vec = [test_iv(:, 1); model_iv];
p2 = (-0.5 * log(det(ss1)) -0.5 * vec' * inv(ss1) * vec) - (-0.5 * log(det(ss2)) -0.5 * vec' * inv(ss2) * vec)

% close all;
% ii = 200;
% x=linspace(-5,5,1e3);
% % mm = mean(devData);
% % devData = bsxfun(@minus, devData, mm);
% [f,xi] = ksdensity(devData(:), x); figure; plot(xi,f);hold; plot(x, normpdf(x), 'r');  plot(x, tpdf(x, 100), 'g');
% % [coeff, ~, latent] = princomp(devData);
% W = coeff(:, 1 : 500);
% ivec = devData * W;
% [f,xi] = ksdensity(ivec(:), x); figure; plot(xi,f);hold; plot(x, normpdf(x), 'r');  plot(x, tpdf(x, 100), 'g');
% return;
% global params;
% setParams();
% params.useLda = true;
% params.normalizeScore = true;
% params.usePca = false;
% iVectorSpeakerVerification_kaldi();
% setParams();
% params.useLda = false;
% params.normalizeScore = true;
% params.usePca = true;
% iVectorSpeakerVerification_kaldi();
% setParams();
% params.useLda = true;
% params.normalizeScore = false;
% params.usePca = false;
% iVectorSpeakerVerification_kaldi();
% setParams();
% params.useLda = true;
% params.normalizeScore = false;
% params.usePca = true;
% iVectorSpeakerVerification_kaldi();
% setParams();
% params.useLda = true;
% params.normalizeScore = true;
% params.usePca = true;
% iVectorSpeakerVerification_kaldi();
setParams();
params.useLda = false;
params.normalizeScore = false;
params.usePca = false;
params.usePlda = true;
iVectorSpeakerVerification_kaldi();
% setParams();
% params.useLda = false;
% params.normalizeScore = true;
% params.usePca = false;
% params.usePlda = true;
% iVectorSpeakerVerification_kaldi();
setParams();
params.useLda = true;
params.normalizeScore = false;
params.usePca = false;
params.usePlda = true;
iVectorSpeakerVerification_kaldi();
% setParams();
% params.useLda = true;
% params.normalizeScore = true;
% params.usePca = false;
% params.usePlda = true;
% iVectorSpeakerVerification_kaldi();