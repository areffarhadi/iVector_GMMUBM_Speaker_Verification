function extractFeatures(inputFile)
global params;
% inputFile = 'I:\NIST\NIST04\wav.scp';
fprintf('Using HCopy for acoustic feature extraction...\n');
tic;
mainDir = [fileparts(inputFile) filesep];
wavDir = [mainDir 'Wav' filesep];
if (~exist(wavDir, 'dir'))
    mkdir(wavDir);
end
feaDir = [mainDir 'Features' filesep params.feaType filesep];
if (~exist(feaDir, 'dir'))
    mkdir(feaDir);
end
fid = fopen(inputFile, 'rt');
sphFiles = textscan(fid, '%s', inf, 'delimiter', '\n');
sphFiles = sphFiles{1};
fclose(fid);
numFiles = length(sphFiles);
% for i = 1 : numFiles
configFile = params.configFile;
parfor i = 1 : numFiles
    parts = textscan(sphFiles{i}, '%s %s', 'delimiter', '\t');
    wavPath = [wavDir parts{2}{1} '.wav'];
    feaPath = [feaDir parts{2}{1} '.fea'];
    if (~exist(feaPath, 'file'))
        if (exist(wavPath, 'file'))
            extractOneFile(configFile, wavPath, feaPath);
        else
            fprintf('Warning - WAV file not exist, WAV : %s\n', wavPath);
        end
    end
end
fprintf('Feature extraction finished, Elapsed time is %f seconds.\n', toc);
end

function extractOneFile(configPath, wavPath, feaPath)
cmd = sprintf('HCopy -C "%s" "%s" "%s"', configPath, wavPath, feaPath);
[status, cmdOut] = system(cmd);
if (status ~= 0)
    error(cmdOut);
end
end