function plda = read_kaldi_plda(filePath)
% filePath = 'C:\Users\Hossein\Desktop\plda';
fid = fopen(filePath, 'rb', 'l');
fread(fid, 9); %read header
plda.mean_ = readVec(fid);
plda.transform_ = readMat(fid)';
plda.psi_ = readVec(fid);
% fread(fid, inf);
fclose(fid);
plda.offset_ = -plda.transform_ * plda.mean_;

function vec = readVec(fid)
fread(fid, 4);
len = fread(fid, 1, 'int32');
vec = fread(fid, len, 'double');

function mat = readMat(fid)
fread(fid, 4);
rows = fread(fid, 1, 'int32'); fread(fid, 1); cols = fread(fid, 1, 'int32');
mat = reshape(fread(fid, rows * cols, 'double'), rows, cols);