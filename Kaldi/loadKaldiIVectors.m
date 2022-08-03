function [ivectors, speakersId, filesId] = loadKaldiIVectors(dirPath)
% dirPath = 'F:\Research\Kaldi\exp\ivectors_sre08_train_short2_male';
if (dirPath(end) ~= filesep)
    dirPath(end + 1) = filesep;
end
files = dir([dirPath 'ivector.*.ark']);
len = length(files);
speakersId = cell(0, 1);
filesId = cell(0, 1);
ivectors = zeros(0, 400);
for i = 1 : len    
    [ivecs, spkId, fId] = loadKaldiIVectorsFromAFile([dirPath files(i).name]);
    ivectors = [ivectors; ivecs]; %#ok<*AGROW>
    speakersId = [speakersId(:); spkId(:)];
    filesId = [filesId(:); fId(:)];
end

function [ivectors, speakersId, filesId] = loadKaldiIVectorsFromAFile(filePath)
% filePath = 'F:\Research\Kaldi\exp\ivectors_sre08_train_short2_male\ivector.1.ark';
fid = fopen(filePath);
lines = textscan(fid, '%s', inf, 'delimiter', '\n');
lines = lines{1};
fclose(fid);
len = length(lines);
speakersId = cell(len, 1);
filesId = cell(len, 1);
ivectors = zeros(len, 400);
for i = 1 : len
    line = lines{i};
    parts = strsplit(line, '  ');
    idx = strfind(parts{1}, '-');
    if (~isempty(idx))
        speakersId{i} = parts{1}(1 : idx(end) - 1);
        filesId{i} = parts{1}(idx(end) + 1 : end);
    else
        filesId{i} = parts{1};
    end
    vec = textscan(parts{2}(2:end - 1), '%f', inf);
    ivectors(i, :) = vec{1}';
end