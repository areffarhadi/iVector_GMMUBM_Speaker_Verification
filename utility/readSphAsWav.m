function [wav, fs] = readSphAsWav(filePath)
[y, fs] = readsph(filePath, 'r');
y = y + 128;
if size(y, 2) == 1
    wav = mu2lin(y);
else
    wav(:, 1) = mu2lin(y(:, 1));
    wav(:, 2) = mu2lin(y(:, 2));
end