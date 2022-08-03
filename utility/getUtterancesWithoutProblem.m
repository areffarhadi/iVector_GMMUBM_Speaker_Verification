function [uttIdes, spkIdes, feaPaths] = getUtterancesWithoutProblem(inputFile)
global params;
% inputFile = 'I:\NIST\NIST04\wav.scp';
mainDir = [fileparts(inputFile{1,1}) filesep]; %AREF add {1,1}
feaDir = [mainDir 'Features' filesep params.feaType filesep];
if (~exist(feaDir, 'dir'))
    mkdir(feaDir);
end
[uttIdes, spkIdes, isFemale] = loadSpk2utt([mainDir 'utt2spk']);
if (params.gender == 'F')
    uttIdes = uttIdes(isFemale == 1);
    spkIdes = spkIdes(isFemale == 1);
elseif (params.gender == 'M')
    uttIdes = uttIdes(isFemale == 0);
    spkIdes = spkIdes(isFemale == 0);
end
numFiles = length(uttIdes);
feaNotFound = zeros(numFiles, 1);
feaPaths = cell(numFiles, 1);
for i = 1 : numFiles
    feaPath = [feaDir uttIdes{i} '.fea'];
    if (~exist(feaPath, 'file'))
        feaNotFound(i) = 1;
    else
        feaPaths{i} = feaPath;
    end
end
uttIdes = uttIdes(feaNotFound == 0);
spkIdes = spkIdes(feaNotFound == 0);
feaPaths = feaPaths(feaNotFound == 0);
fprintf('Number of utterances haven''t feature file : %d\n', sum(feaNotFound));
outputFile = [mainDir 'info_' params.gender '.mat'];
save(outputFile, 'uttIdes', 'spkIdes', 'feaPaths');
end

function [uttIdes, spkIdes, isFemale] = loadSpk2utt(filePath)
fid = fopen(filePath, 'rt');
utts = textscan(fid, '%s', inf, 'delimiter', '\n');
utts = utts{1};
uttIdes = cell(length(utts), 1);
spkIdes = cell(length(utts), 1);
isFemale = zeros(length(utts), 1);
fclose(fid);
for i = 1 : length(utts)
    parts = strsplit(utts{i});
    uttIdes{i} = parts{1};
    spkIdes{i} = parts{2};
    if (parts{3} == 'F')
        isFemale(i) = 1;
    end
end
end