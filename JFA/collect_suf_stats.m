function [N, F] = collect_suf_stats(data, ubm)
% Collect sufficient stats in baum-welch fashion
%  [N, F] = collect_suf_stats(FRAMES, M, V, W) returns the vectors N and
%  F of zero- and first- order statistics, respectively, where FRAMES is a 
%  dim x length matrix of features, UBM file name of the UBM or a structure
%  with UBM hyperparameters.

if (ischar(ubm))
	tmp  = load(ubm);
	ubm  = tmp.gmm;
elseif (~isstruct(ubm))
	error('Oops! ubmFilename should be either a string or a structure!');
end
m = ubm.mu;
v = ubm.sigma;
w = ubm.w';

n_mixtures  = size(w, 1);
dim         = size(m, 1);

% compute the GMM posteriors for the given data
gammas = gaussian_posteriors(data, m, v, w);

% zero order stats for each Gaussian are just sum of the posteriors (soft
% counts)
N = sum(gammas, 2);
% first order stats is just a (posterior) weighted sum
F = data * gammas';
F = reshape(F, n_mixtures * dim, 1);
end

function gammas = gaussian_posteriors(data, m, v, w)
% Computes Gaussian posterior probs for the given data
%   For each frame (column) of data, compute the vector of posterior probs
%   of the given GMM given by means, vars, and weights

n_mixtures      = size(w, 1);
[dim, n_frames] = size(data);
% precompute the model g-consts and normalize the weights
a = w ./ (((2 * pi)^(dim / 2)) * sqrt(prod(v)'));
gammas = zeros(n_mixtures, n_frames); 
for ii = 1 : n_mixtures 
  gammas(ii, :) = gaussian_function(data, a(ii), m(:,ii), v(:,ii));
end
gamasum = sum(gammas);
% normalize
gammas = bsxfun(@rdivide, gammas, gamasum);
end

function Y = gaussian_function(data, a, b, c)
% Y = gaus(data, a, b, c)
% GAUS N-domensional gaussian function
%    See http://en.wikipedia.org/wiki/Gaussian_function for definition.
%    note it's not Gaussian distribution as no normalization (g-const) is performed
%
%    Every row data is one input vector. Y is column vector with the
%    same number of rows as data

auxC = -0.5 ./ c; 
aux = bsxfun(@minus, data, b);
aux = aux .^ 2;
Y = auxC' *aux;
Y = exp(Y) * a;
end