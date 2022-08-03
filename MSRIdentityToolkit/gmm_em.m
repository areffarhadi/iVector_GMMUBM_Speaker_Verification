function gmm = gmm_em(dataList, nmix, final_niter, ds_factor, nworkers, gmmFilename)
% fits a nmix-component Gaussian mixture model (GMM) to data in dataList
% using niter EM iterations per binary split. The process can be
% parallelized in nworkers batches using parfor.
%
% Inputs:
%   - dataList    : ASCII file containing feature file names (1 file per line) 
%					or a cell array containing features (nDim x nFrames). 
%					Feature files must be in uncompressed HTK format.
%   - nmix        : number of Gaussian components (must be a power of 2)
%   - final_iter  : number of EM iterations in the final split
%   - ds_factor   : feature sub-sampling factor (every ds_factor frame)
%   - nworkers    : number of parallel workers
%   - gmmFilename : output GMM file name (optional)
%
% Outputs:
%   - gmm		  : a structure containing the GMM hyperparameters
%					(gmm.mu: means, gmm.sigma: covariances, gmm.w: weights)
%
%
% Omid Sadjadi <s.omid.sadjadi@gmail.com>
% Microsoft Research, Conversational Systems Research Center

if ischar(nmix), nmix = str2double(nmix); end
if ischar(final_niter), final_niter = str2double(final_niter); end
if ischar(ds_factor), ds_factor = str2double(ds_factor); end
if ischar(nworkers), nworkers = str2double(nworkers); end

covar_type = 'diag'; %'full'
mixWeightFloor = 1 / (nmix * 2);

[ispow2, ~] = log2(nmix);
if ( ispow2 ~= 0.5 ),
	error('oh dear! nmix should be a power of two!');
end

% if ischar(dataList) || iscellstr(dataList),
% 	dataList = load_data(dataList);
% end
if ~iscell(dataList),
	error('Oops! dataList should be a cell array!');
end

% dataList = dataList(1 : 100 : end);

nfiles = length(dataList);

% gradually increase the number of iterations per binary split
% mix = [1 2  4  8  16  32  64  128 256 512 1024 2048];
niter = [5 10 10 10 10  10  15  15  20  20  20   30];

if (length(niter) > log2(nmix))
    niter(log2(nmix) + 1) = max(niter(log2(nmix) + 1), final_niter);
else
    niter(log2(nmix) + 1) = final_niter;
end

init_model = [];
if (nargin >= 6)
    [dirPath, name] = fileparts(gmmFilename);
    pathstr = [dirPath filesep 'Models' filesep];
    % if (exist(pathstr, 'dir'))
    %     ii = nmix;
    %     while (ii >= 2)
    %         fPath = [pathstr filesep name '_' num2str(ii) '.mat'];
    %         if (exist(fPath, 'file'))
    %             init_model = load(fPath);
    %             init_model = init_model.gmm;
    %         end
    %         ii = ii / 2;
    %     end
    % end
end

if (isempty(init_model))
    fprintf('\n\nInitializing the GMM hyperparameters ...\n');
    [gm, gv] = comp_gm_gv(dataList, covar_type);
    gmm = gmm_init(gm, gv);
    gmm.covar_type = covar_type;
    mix = 1;
else
    fprintf('\n\nInitializing the GMM using initialize model ...\n');
    gmm = init_model;
    gmm = gmm_mixup(gmm, mixWeightFloor); 
    mix = length(gmm.w);
end
while (mix <= nmix)
	if ( mix >= nmix/2 ), ds_factor = 1; end % not for the last two splits!
    fprintf('\nRe-estimating the GMM hyperparameters for %d components ...\n', mix);
    [ispow2, ~] = log2(mix);
    nIter = 8;
    if (ispow2 == 0.5), nIter = niter(log2(mix) + 1); end
    for iter = 1 : nIter
        fprintf('EM iter#: %d \t', iter);
        N = 0; F = 0; S = 0; L = 0; nframes = 0;
        tim = tic;
%         for ix = 1 : nfiles
        parfor (ix = 1 : nfiles, nworkers)
            if (ischar(dataList{ix}))
                fData = htkread(dataList{ix});
            else
                fData = dataList{ix};
            end
            [n, f, s, l] = expectation(fData(:, 1:ds_factor:end), gmm);
            N = N + n; F = F + f; S = S + s; L = L + sum(l);
			nframes = nframes + length(l);
        end
        tim = toc(tim);
        fprintf('[llk = %.4f] \t [elaps = %.2f s]\n', L/nframes, tim);
        gmm = maximization(N, F, S);
        gmm.covar_type = covar_type;
    end
    if (nargin >= 6 && ispow2 == 0.5 && mix > 256)
        [dirPath, name] = fileparts(gmmFilename);
        pathstr = [dirPath filesep 'Models' filesep];
        if (~exist(pathstr, 'dir')), mkdir(pathstr); end
        pathstr = [pathstr filesep name '_' num2str(mix) '.mat']; %#ok<AGROW>
        save(pathstr, 'gmm');
    end
    if (mix < nmix)
        gmm = gmm_mixup(gmm, mixWeightFloor);
    else
        break;
    end
    mix = length(gmm.w);
end

if ( nargin >= 6 ),
	fprintf('\nSaving GMM to file %s\n', gmmFilename);
	% create the path if it does not exist and save the file
	path = fileparts(gmmFilename);
	if ( exist(path, 'dir')~=7 && ~isempty(path) ), mkdir(path); end
	save(gmmFilename, 'gmm');
end

function data = load_data(datalist)
% load all data into memory
if ~iscellstr(datalist)
    fid = fopen(datalist, 'rt');
    filenames = textscan(fid, '%s');
    fclose(fid);
    filenames = filenames{1};
else
    filenames = datalist;
end
nfiles = size(filenames, 1);
data = cell(nfiles, 1);
for ix = 1 : nfiles,
    data{ix} = htkread(filenames{ix});
end

function [gm, gv] = comp_gm_gv(data, covar_type)
% computes the global mean and variance of data
data = data(1:20:end);
if (iscellstr(data))
    data = load_data(data);
end
nframes = cellfun(@(x) size(x, 2), data, 'UniformOutput', false);
nframes = sum(cell2mat(nframes));
gm = cellfun(@(x) sum(x, 2), data, 'UniformOutput', false);
gm = sum(cell2mat(gm'), 2) / nframes;
if (strcmp(covar_type, 'diag'))
    gv = cellfun(@(x) sum(bsxfun(@minus, x, gm) .^ 2, 2), data, 'UniformOutput', false);
    gv = sum(cell2mat(gv'), 2) / (nframes - 1);
else
    gv = cellfun(@(x) (bsxfun(@minus, x, gm) * bsxfun(@minus, x, gm)'), data, 'UniformOutput', false);
    gv = sum(cell2mat(gv)) / (nframes - 1);
end

function gmm = gmm_init(glob_mu, glob_sigma)
% initialize the GMM hyperparameters (Mu, Sigma, and W)
gmm.mu    = glob_mu;
gmm.sigma = glob_sigma;
gmm.w     = 1;

function [N, F, S, llk] = expectation(data, gmm)
% compute the sufficient statistics
[post, llk] = postprob(data, gmm);
N = sum(post, 2)';
F = data * post';
% S = zeros(size(data, 1), size(post, 1));
% for i = 1 : size(post, 1)
%     temp = bsxfun(@minus, data, gmm.mu(:, i));
%     S(:, i) = (temp .* temp) * post(i, :)';
% end
S = (data .* data) * post';

function [post, llk] = postprob(data, gmm)
% compute the posterior probability of mixtures for each frame
post = lgmmprob(data, gmm);
llk  = logsumexp(post, 1);
post = exp(bsxfun(@minus, post, llk));

function logprob = lgmmprob(data, gmm)
% compute the log probability of observations given the GMM
mu = gmm.mu; sigma = gmm.sigma; w = gmm.w(:);
ndim = size(data, 1);
if (strcmp(gmm.covar_type, 'diag'))
    C = sum(mu.*mu./sigma) + sum(log(sigma));
    D = (1./sigma)' * (data .* data) - 2 * (mu./sigma)' * data  + ndim * log(2 * pi);
    logprob = -0.5 * (bsxfun(@plus, C',  D));
    logprob = bsxfun(@plus, logprob, log(w));
else
    sigma_inv = inv(sigma);
    C = sum(mu' * sigma_inv * mu) + log(det(sigma)); %#ok<*MINV>
    D = sum(data .* (sigma_inv * data)) - 2 * mu' * sigma_inv * data + ndim * log(2 * pi);
    logprob = -0.5 * (bsxfun(@plus, C', D));
    logprob = bsxfun(@plus, logprob, log(w));
end

function y = logsumexp(x, dim)
% compute log(sum(exp(x),dim)) while avoiding numerical underflow
xmax = max(x, [], dim);
y    = xmax + log(sum(exp(bsxfun(@minus, x, xmax)), dim));
ind  = find(~isfinite(xmax));
if ~isempty(ind)
    y(ind) = xmax(ind);
end

function gmm = maximization(N, F, S)
% ML re-estimation of GMM hyperparameters which are updated from accumulators
w  = N / sum(N);
mu = bsxfun(@rdivide, F, N);
sigma = bsxfun(@rdivide, S, N) - (mu .* mu);
sigma = apply_var_floors(w, sigma, 0.1);
gmm.w = w;
gmm.mu= mu;
gmm.sigma = sigma;

function sigma = apply_var_floors(w, sigma, floor_const)
% set a floor on covariances based on a weighted average of component
% variances
vFloor = sigma * w' * floor_const;
sigma  = bsxfun(@max, sigma, vFloor);
% sigma = bsxfun(@plus, sigma, 1e-6 * ones(size(sigma, 1), 1));

%{
function gmm = gmm_mixup(gmm)
% perform a binary split of the GMM hyperparameters
mu = gmm.mu; sigma = gmm.sigma; w = gmm.w;
[ndim, nmix] = size(sigma);
[sig_max, arg_max] = max(sigma);
eps = sparse(0 * mu);
eps(sub2ind([ndim, nmix], arg_max, 1 : nmix)) = sqrt(sig_max);
% only perturb means associated with the max std along each dim 
mu = [mu - eps, mu + eps];
% mu = [mu - 0.2 * eps, mu + 0.2 * eps]; % HTK style
sigma = [sigma, sigma];
w = [w, w] * 0.5;
gmm.w  = w;
gmm.mu = mu;
gmm.sigma = sigma;
%}

function gmm = gmm_mixup(gmm, mixWeightFloor)
gmm.hook = zeros(1, length(gmm.w));
gmm = fixDefunctMix(gmm, mixWeightFloor);
newMixCount = length(gmm.w);
if (newMixCount == 1)
    newMixCount = 2;
else
    newMixCount = newMixCount + max(2, 2 ^ (floor(log2(newMixCount)) - 2));
end
gmm = upMix(gmm, newMixCount);

function gmm = upMix(gmm, newMixCount)
while (length(gmm.w) < newMixCount)
  m = heaviestMix(gmm);
  gmm = splitMix(gmm, m);
end

function m = heaviestMix(gmm)
[~, m] = max(gmm.w - gmm.hook);

function gmm = fixDefunctMix(gmm, mixWeightFloor)
count = countDefunctMix(gmm, mixWeightFloor);
nMix = length(gmm.w);
for n = 1 : count
    for i = 1 : nMix
        if (gmm.w(i) <= mixWeightFloor)
            fprintf('**** Warning : DefunctMix %d , %e ****\n', i, gmm.w(i));
            break;
        end
    end
    m = heaviestMix(gmm);
    gmm = splitMix(gmm, m, i);
end

function defunct = countDefunctMix(gmm, mixWeightFloor)
nMix = length(gmm.w);
defunct = 0;
for i = 1 : nMix
    if (gmm.w(i) <= mixWeightFloor)
        defunct = defunct + 1;
    end
end

function gmm = splitMix(gmm, heaviestMixIndex, defunctMixIndex)
pertDepth = 0.2;
if (nargin < 3)
    % add new mix to end of all
    defunctMixIndex = length(gmm.w) + 1;
end
gmm.hook(heaviestMixIndex) = gmm.hook(heaviestMixIndex) + 1;
gmm.hook(defunctMixIndex) = gmm.hook(heaviestMixIndex);
gmm.w(heaviestMixIndex) = gmm.w(heaviestMixIndex) / 2;
gmm.w(defunctMixIndex) = gmm.w(heaviestMixIndex);
% copy heavist to defunct
gmm.sigma(:, defunctMixIndex) = gmm.sigma(:, heaviestMixIndex);
% then perturb them
x = sqrt(gmm.sigma(:, heaviestMixIndex)) * pertDepth;
gmm.mu(:, defunctMixIndex) = gmm.mu(:, heaviestMixIndex) + x;
gmm.mu(:, heaviestMixIndex) = gmm.mu(:, heaviestMixIndex) - x;