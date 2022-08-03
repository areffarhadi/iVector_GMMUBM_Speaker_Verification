function i_vector = extract_ivector(N, F, T, ivFilename)
% EXTRACT_IVECTOR(N, F, T, IVFILENAME)
% extracts i-vector from stats in N and F with T structure and optionally
% save the i-vector in ivFilename.
%
% Inputs:
%   - N             : zero order statistics in a one-dimensional array
%   - F             : first order statistics in a one-dimensional array
%   - T             : total subspace structure that contain following fields
%   	T.T         TVS matrix
%       T.T_invS	T * inv(S), this matrix store for prevent matrix
%                   multiplying and inversion. This is useful for speedup. 
%       T.idx_sv	This is a vector that map N dimentions to F dimentions.
%                   This is useful for speedup.
%       T.I         eye(tv_dim), for prevent reconstruct this matrix
%   - ivFilename	: output i-vector file name (optional)
%
% Outputs:
%   - i_vector      : output identity vector (i-vector)
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
% MicroSoft Research, Silicon Valley Center
%
% Modified by Hossein Zeinali <hsn[dot]zeinali[at]gmail[dot]com>
% Sharif University of Technology, Tehran, Iran

L = T.I + bsxfun(@times, T.T_invS, N(T.idx_sv)') * T.T';
B = T.T_invS * F;
i_vector = pinv(L) * B;

if (nargin == 4)
    % create the path if it does not exist and save the file
    dirpath = fileparts(ivFilename);
    if (~isempty(dirpath) && ~exist(dirpath, 'dir')), mkdir(dirpath); end
	save(ivFilename, 'i_vector');
end
