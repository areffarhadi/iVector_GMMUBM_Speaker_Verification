function T = train_tv_space(dataList, ubmFilename, tv_dim, niter, nworkers, tvFilename)
% TRAIN_TV_SPACE(DATALIST, UBMFILENAME, TV_DIM, NITER, NWORKERS, TVFILENAME)
% uses statistics in dataLits to train the i-vector extractor with tv_dim 
% factors and niter EM iterations. The training process can be parallelized
% via parfor with nworkers. The output can be optionally saved in tvFilename.
%
% Technically, assuming a factor analysis (FA) model of the from:
%
%           M = m + T . x
%
% for mean supervectors M, the code computes the maximum likelihood 
% estimate (MLE)of the factor loading matrix T (aka the total variability 
% subspace). Here, M is the adapted mean supervector, m is the UBM mean 
% supervector, and x~N(0,I) is a vector of total factors (aka i-vector).
%
% Inputs:
%   - dataList    : ASCII file containing stats file names (1 file per line)
%                   or a cell array of concatenated stats (i.e., [N; F])
%   - ubmFilename : UBM file name or a structure with UBM hyperparameters.
%                   Matrix covariance of this model can be diagonal or
%                   full. Also each of mixture component can have different
%                   dimension. In this case, ubm.sigma is a cell that
%                   each of which contain a matrix covariance for each
%                   component.
%   - tv_dim      : dimensionality of the total variability subspace
%   - niter       : number of EM iterations for total subspace learning
%   - nworkers    : number of parallel workers 
%   - tvFilename  : output total variability matrix file name (optional)
%
% Outputs:
%   - T 		  : total variability subspace matrix  
%
% References:
%   [1] D. Matrouf, N. Scheffer, B. Fauve, J.-F. Bonastre, "A straightforward 
%       and efficient implementation of the factor analysis model for speaker 
%       verification," in Proc. INTERSPEECH, Antwerp, Belgium, Aug. 2007, 
%       pp. 1242-1245.  
%   [2] P. Kenny, "A small footprint i-vector extractor," in Proc. Odyssey, 
%       The Speaker and Language Recognition Workshop, Singapore, Jun. 2012.
%   [3] N. Dehak, P. Kenny, R. Dehak, P. Dumouchel, and P. Ouellet, "Front-end 
%       factor analysis for speaker verification," IEEE TASLP, vol. 19, pp. 
%       788-798, May 2011. 
%
%
% Omid Sadjadi <s.omid.sadjadi@gmail.com>
% Microsoft Research, Conversational Systems Research Center
%
% Modified by Hossein Zeinali <hsn[dot]zeinali[at]gmail[dot]com>
% Sharif University of Technology, Tehran, Iran

if (ischar(tv_dim)), tv_dim = str2double(tv_dim); end
if (ischar(niter)), niter = str2double(niter); end
if (ischar(nworkers)), nworkers = str2double(nworkers); end

if (ischar(ubmFilename))
	tmp  = load(ubmFilename);
	ubm  = tmp.gmm;
elseif (isstruct(ubmFilename))
	ubm = ubmFilename;
else
    error('Oops! ubmFilename should be either a string or a structure!');
end

% if S_or_invS was a cell array, each cell of it shows ins(S{i}), this
% is usefull for speedup
[S_or_invS, idx_sv, mix_dim, len_N, len_F] = getEssentialParameters(ubm);

[N, F] = load_data(dataList, len_N, len_F);
if (iscell(dataList)), clear dataList; end

fprintf('\n\nRandomly initializing T matrix ...\n\n');
% suggested in jfa cookbook
% T = randn(tv_dim, len_F) * sum(S) * 0.001;
T = randn(tv_dim, len_F) * 0.001;

fprintf('Re-estimating the total subspace with %d factors ...\n', tv_dim);
for iter = 1 : niter
    fprintf('EM iter#: %d \t', iter);
    tim = tic;
    [LU, RU] = expectation_tv(T, N, F, S_or_invS, idx_sv, nworkers);
    oldT = T;
    T = maximization_tv(LU, RU, mix_dim, len_N);
    norm_diff_T = norm(T - oldT);
    tim = toc(tim);
    diff_trace = abs(trace(T * T') - trace(oldT * oldT'));
    fprintf('[Norm diff T = %.2f]\t[Diff trace T*T'' = %.2f]\t[Elaps = %.2f s]\n', norm_diff_T, diff_trace, tim);
%     if (norm_diff_T < 0.1)
%         break;
%     end
end

if (iscell(S_or_invS))
    T_invS =  T;
    for i = 1 : len_N
        T_invS(:, idx_sv == i) = T_invS(:, idx_sv == i) * S_or_invS{i};
    end
else
    T_invS =  bsxfun(@rdivide, T, S_or_invS');
end

t = T; T = [];
T.T = t;
T.T_invS = T_invS;
T.idx_sv = idx_sv;
T.I = eye(size(T.T, 1));

if ( nargin == 6 ),
	fprintf('\nSaving T matrix to file %s\n', tvFilename);
	% create the path if it does not exist and save the file
	path = fileparts(tvFilename);
	if ( exist(path, 'dir')~=7 && ~isempty(path) ), mkdir(path); end
	save(tvFilename, 'T');
end

function [N, F] = load_data(datalist, len_N, len_F)
% load all data into memory
if ischar(datalist),
    fid = fopen(datalist, 'rt');
    filenames = textscan(fid, '%s');
    fclose(fid);
    filenames = filenames{1};
    nfiles = size(filenames, 1);
    N = zeros(nfiles, len_N, 'single');
    F = zeros(nfiles, len_F, 'single');
    for file = 1 : nfiles,
        tmp = load(filenames{file});
        N(file, :) = tmp.N;
        F(file, :) = tmp.F;
    end
else
    nfiles = length(datalist);
    N = zeros(nfiles, len_N, 'single');
    F = zeros(nfiles, len_F, 'single');
    for file = 1 : nfiles,
        N(file, :) = datalist{file}(1 : len_N);
        F(file, :) = datalist{file}(len_N + 1 : end);
    end
end

function [LU, RU] = expectation_tv(T, N, F, S_or_invS, idx_sv, nworkers)
% Compute the posterior means and covariance matrices of the factors 
% or latent variables
nfiles = size(F, 1);
tv_dim = size(T, 1);
nmix = size(N, 2);

LU = cell(nmix, 1);
LU(:) = {zeros(tv_dim)};

RU = zeros(tv_dim, length(idx_sv));
I = eye(tv_dim);
if (iscell(S_or_invS))
    T_invS =  T;
    for i = 1 : nmix
        T_invS(:, idx_sv == i) = T_invS(:, idx_sv == i) * S_or_invS{i};
    end
else
    T_invS =  bsxfun(@rdivide, T, S_or_invS');
end

parts = 80; % modify this based on your resources
nbatch = floor( nfiles / parts + 0.99999 );
for batch = 1 : nbatch,
    start = 1 + ( batch - 1 ) * parts;
    fin = min(batch * parts, nfiles);
    len = fin - start + 1;
    index = start : fin;
    N1 = N(index, :);
    F1 = F(index, :);
    Ex = zeros(tv_dim, len);
    Exx = zeros(tv_dim, tv_dim, len);
    parfor (ix = 1 : len, nworkers)
%     for ix = 1 : len
        L = I +  bsxfun(@times, T_invS, N1(ix, idx_sv)) * T';
        Cxx = pinv(L); % this is the posterior covariance Cov(x,x)
        B = T_invS * F1(ix, :)';
        Ex(:, ix) = Cxx * B; % this is the posterior mean E[x]
        Exx(:, :, ix) = Cxx + Ex(:, ix) * Ex(:, ix)';
    end
    RU = RU + Ex * F1;
    parfor (mix = 1 : nmix, nworkers)
%     for mix = 1 : nmix
        tmp = bsxfun(@times, Exx, reshape(N1(:, mix),[1 1 len]));
        LU{mix} = LU{mix} + sum(tmp, 3);
    end
end

function RU = maximization_tv(LU, RU, mix_dim, nmix)
% ML re-estimation of the total subspace matrix or the factor loading matrix
start_idx = 1;
for mix = 1 : nmix
    end_idx = start_idx + mix_dim(mix) - 1;
    idx = start_idx : end_idx;
    start_idx = start_idx + mix_dim(mix);
    RU(:, idx) = LU{mix} \ RU(:, idx);
end

function [S, idx_sv, mix_dim, len_N, len_F] = getEssentialParameters(ubm)
isDiag = ubm.covar_type(1) == 'd';
if (isDiag)
    if (iscell(ubm.sigma))
        len_N = length(ubm.sigma);
        S = []; idx_sv = []; mix_dim = zeros(len_N, 1);
        for i = 1 : len_N
            S = [S; ubm.sigma{i}]; %#ok<*AGROW>
            mix_dim(i) = length(ubm.sigma{i});
            idx_sv = [idx_sv; i * ones(mix_dim(i), 1)];
        end
    else
        [ndim, len_N] = size(ubm.sigma);
        S = reshape(ubm.sigma, ndim * len_N, 1);
        idx_sv = reshape(repmat(1 : len_N, ndim, 1), ndim * len_N, 1);
        mix_dim = ndim * ones(len_N, 1);
    end
    len_F = length(S);
    return;
end

if (iscell(ubm.sigma))
    len_N = length(ubm.sigma);
    S = ubm.sigma;
    idx_sv = []; mix_dim = zeros(len_N, 1);
    for i = 1 : len_N
        mix_dim(i) = size(ubm.sigma{i}, 1);
        idx_sv = [idx_sv; i * ones(mix_dim(i), 1)];
    end
else
    [ndim, ~, len_N] = size(ubm.sigma);
    idx_sv = reshape(repmat(1 : len_N, ndim, 1), ndim * len_N, 1);
    mix_dim = ndim * ones(len_N, 1);
    S = cell(len_N, 1);
    for i = 1 : len_N
        S{i} = ubm.sigma(:, :, i);
    end
end
len_F = length(idx_sv);
% in this case change each cell of S to inv(S) for speedup
for i = 1 : len_N
    S{i} = inv(S{i});
end
