function T = train_T(dataList, ubm, tv_dim, niter, tvFilename)
%% Train total variability space

% Load UBM
if (ischar(ubm))
	tmp  = load(ubm);
	ubm  = tmp.gmm;
elseif (~isstruct(ubm))
	error('Oops! ubm should be either a string or a structure!');
end

[ndim, nmix] = size(ubm.mu);
S = reshape(ubm.sigma, ndim * nmix, 1);

[N, F] = load_data(dataList, ndim, nmix);
if iscell(dataList), clear dataList; end

% initialize T matrix
fprintf('\n\nRandomly initializing T matrix ...\n\n');
% T = randn(tv_dim, ndim * nmix) * sum(S) * 0.001;
T = randn(tv_dim, ndim * nmix) * 0.001;

% iteratively train T
fprintf('Re-estimating the total subspace with %d factors ...\n', tv_dim);
for iter = 1 : niter,
    fprintf('EM iter#: %d\t', iter);
    tim = tic;
    oldT = T;
    [~, T] = estimate_w_and_T(F, N, S, T);
    norm_delta_T = norm(T - oldT);
    tim = toc(tim);
    fprintf('[Norm of delta_T = %.2f]\t[elaps time = %.2f s]\n', norm_delta_T, tim);
end
if (nargin == 5)
	fprintf('\nSaving T matrix to file %s\n', tvFilename);
	% create the path if it does not exist and save the file
	path = fileparts(tvFilename);
	if ( exist(path, 'dir')~=7 && ~isempty(path) ), mkdir(path); end
	save(tvFilename, 'T');
end

function [N, F] = load_data(datalist, ndim, nmix)
% load all data into memory
if ischar(datalist),
    fid = fopen(datalist, 'rt');
    filenames = textscan(fid, '%s');
    fclose(fid);
    filenames = filenames{1};
    nfiles = size(filenames, 1);
    N = zeros(nfiles, nmix, 'single');
    F = zeros(nfiles, ndim * nmix, 'single');
    for file = 1 : nfiles,
        tmp = load(filenames{file});
        N(file, :) = tmp.N;
        F(file, :) = tmp.F;
    end
else
    nfiles = length(datalist);
    N = zeros(nmix, nfiles, 'single');
    F = zeros(ndim * nmix, nfiles, 'single');
    for file = 1 : nfiles,
        N(:, file) = datalist{file}(1:nmix);
        F(:, file) = datalist{file}(nmix + 1 : end);
    end
end
