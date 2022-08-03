function vectors = do_plda_trandsform(plda, vectors)
if ~isstruct(plda),
	fprintf(1, 'Error: plda should be a structure!\n');
	return;
end

Phi     = plda.Phi;
Sigma   = plda.Sigma;
W       = plda.W;
M       = plda.M;

vectors = bsxfun(@minus, vectors', M); % centering the data
vectors = length_norm(vectors); % normalizing the length
vectors = W' * vectors; % whitening data

T = eye(size(Phi, 2)) + (Phi' / Sigma) * Phi;
T = T \ (Phi' / Sigma);
vectors = T * vectors;
