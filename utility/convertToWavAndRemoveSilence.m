function convertToWavAndRemoveSilence(inputFile)
% inputFile = 'I:\NIST\NIST04\wav.scp';
fprintf('Converting to wav files started...\n');
tic;
%AREF
% AA=size(inputFile);
% maindir=cell(AA(1),1);
% for ij=1:AA
% mainDir{ij,1} = [fileparts(inputFile{ij,1}) filesep];
% end
%END AREF
mainDir = [fileparts(inputFile{1,1}) filesep];
wavDir = [mainDir 'Wav' filesep];
if (~exist(wavDir, 'dir'))
    mkdir(wavDir);
end
phnDir = [mainDir 'PHN' filesep];
if (~exist(phnDir, 'dir'))
    mkdir(phnDir);
end
%fid = fopen(inputFile{1,1}, 'rt'); %AREF
 fid = fopen(inputFile, 'rt');
sphFiles = textscan(fid, '%s', inf, 'delimiter', '\n');
sphFiles = sphFiles{1};
fclose(fid);
numFiles = length(sphFiles);
% for i = 1 : numFiles
parfor i = 1 : numFiles
    parts = textscan(sphFiles{i}, '%s %s', 'delimiter', '\t');
    sphPath = parts{1}{1};
    phnPath = [phnDir parts{2}{1} '.phn'];
    wavPath = [wavDir parts{2}{1} '.wav'];
    if (~exist(wavPath, 'file'))
        if (exist(phnPath, 'file'))
            if (length(strfind(parts{2}{1}, '_')) == 1)
                convertOneSphFile(sphPath, phnPath, wavPath);
            else
                channel = parts{2}{1}(end);
                convertOneSphFile(sphPath, phnPath, wavPath, channel);
            end
        else
            fprintf('Warning - PHN file not exist, PHN : %s\n', phnPath);
        end
    end
end
fprintf('Converting finished, Elapsed time is %f seconds.\n', toc);
end

function convertOneSphFile(sphPath, phnPath, wavPath, channel)
[wav, fs] = readSphAsWav(sphPath);
if (size(wav, 2) == 1)
    outWav = removeSilenceUsingPhn(wav, phnPath);
else
    if (channel == 'A')
        outWav = removeSilenceUsingPhn(wav(:, 1), phnPath);
    elseif (channel == 'B')
        outWav = removeSilenceUsingPhn(wav(:, 2), phnPath);
    else
        error('Undefined channel, %s', channel);
    end
end
if (length(outWav) > fs / 2)
    audiowrite(wavPath, outWav, fs);
else
    fprintf('Warning - There is no speech area in this file, file : %s\n', sphPath);
end
end