function [nist04WavFiles, nist04SpeakersId] = nist04ConvertAndRemoveSilence(sphFiles, nist04SpeakersId)
global params;
if (exist([params.nist04 'nist04WavFiles.mat'], 'file'))
    load([params.nist04 'nist04WavFiles.mat']);
    if (gender == params.gender) %#ok<NODEF>
        return;
    end
end
if (nargin ~= 2)
    error('This function must have two argumnet.');
end
%myLog('Converting of nist04 sph files started...');
tic;
outputWavDir = params.nist04WavDir;
if (outputWavDir(end) ~= filesep)
    outputWavDir(end + 1) = filesep;
end
if (~exist(outputWavDir, 'dir'))
    mkdir(outputWavDir);
end
phnDir = params.nist04PhnDir;
if (phnDir(end) ~= filesep)
    phnDir(end + 1) = filesep;
end
if (~exist(phnDir, 'dir'))
    mkdir(phnDir);
end
numFiles = length(sphFiles);
nist04WavFiles = cell(numFiles, 1);
mustRemove = false(numFiles, 1);
 for i = 1 : numFiles
%parfor i = 1 : numFiles
%Aref=i                      %AREF
    [~, name] = fileparts(sphFiles{i});
    file = [outputWavDir name '.wav'];
    if (exist(file, 'file'))
        files = {file};
    else
        files = convertOneSphFile(sphFiles{i}, phnDir, outputWavDir);
    end
    nist04WavFiles{i, 1} = files{1, 1}; % #ok<PFOUS>
    if (files{1, 1} == 0)
        mustRemove(i) = true;
    end
end
nist04SpeakersId(mustRemove) = [];
nist04WavFiles(mustRemove) = [];
% check that all file converted truly.
for i = 1 : length(nist04WavFiles)
    if (~exist(nist04WavFiles{i, 1}, 'file'))
       str = ['Input sph file not converted, ' nist04WavFiles{i, 1}];
       myLog(str);
       error(str);
    end
end
gender = params.gender; %#ok<NASGU>
save([params.nist04 'nist04WavFiles.mat'], 'nist04WavFiles', 'nist04SpeakersId', 'gender');
%* myLog(sprintf('Converting finished, Elapsed time is %f seconds.', toc));
end