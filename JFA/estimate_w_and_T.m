function [w, T, C] = estimate_w_and_T(F, N, S, T)
% estimate_w_and_T estimates total vaiability space and i-vectors

% F - matrix of first order statistics (not centered). The columns correspond
%     to training segments. Number of rows is given by the supervector
%     dimensionality. The first n rows correspond to the n dimensions
%     of the first Gaussian component, the second n rows to second 
%     component, and so on.
% N - matrix of zero order statistics (occupation counts of Gaussian
%     components). The columns correspond to training segments. The rows
%     correspond to Gaussian components.
% S - speaker and channel independent variance supervector (e.g. concatenated
%     UBM variance vectors)
% T - The rows of matrix T are 'eigenvoices'. Number of columns is given
%     by the supervector dimensionality.

nmix            = size(N, 1);
dim_of_sup      = size(F, 1);
ndim            = dim_of_sup / nmix;
tv_dim          = size(T, 1);
num_train_seg	= size(N, 2);

if nargin == 2 && nargout == 1
	% update w from statistics F and N
    w = update_T(F, N);
    return
end

w = zeros(tv_dim, num_train_seg);

if nargout > 1
    A = cell(nmix, 1);
    for c = 1 : nmix
        A{c} = zeros(tv_dim);
    end
    C = zeros(tv_dim, dim_of_sup);
end

TvT = cell(nmix, 1);
for c = 1 : nmix
  c_elements = ((c - 1) * ndim + 1) : (c * ndim);
  TvT{c} = bsxfun(@rdivide, T(:, c_elements), S(c_elements)') * T(:, c_elements)';
end

for i = 1 : num_train_seg
    Fs  = F(:, i);
    Ns  = N(:, i);

    L = eye(tv_dim);
    for c = 1 : nmix
        L = L + TvT{c} * Ns(c);
    end

    invL = inv(L);
    w(:, i) = invL' * (T * (Fs ./ S));

    if nargout > 1
        invL = invL + w(:, i) * w(:, i)';
        for c = 1 : nmix
            A{c} = A{c} + invL * Ns(c);
        end
        C = C + w(:, i) * Fs';
    end
end

if nargout == 3
    % output new estimates of y and accumulators A and C
    T = A;
elseif nargout == 2
    % output new estimates of w and T
    T = update_T(A, C);
end

%-------------------------------------------------
function N = update_T(F, N)
dim = size(N, 2) / length(F);
for c = 1 : length(F)
    c_elements = ((c - 1) * dim + 1) : (c * dim);
    N(:, c_elements) = F{c} \ N(:, c_elements);
end
