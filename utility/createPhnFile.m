function createPhnFile(inputFile)
% inputFile = 'I:\NIST\NIST04\wav.scp';
fprintf('Converting to sph files started...\n');
tic;
mainDir = [fileparts(inputFile) filesep];
phnDir = [mainDir 'PHN' filesep];
if (~exist(phnDir, 'dir'))
    mkdir(phnDir);
end
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
    if (~exist(phnPath, 'file'))
        if (length(strfind(parts{2}{1}, '_')) == 1)
            [status, cmdout] = system(sprintf('sph2phn -sph %s -phn %s -dn Y -af 0.95', sphPath, phnPath));
        else
            channel = parts{2}{1}(end);
            [status, cmdout] = system(sprintf('sph2phn -sph %s -phn %s -ch %s -dn Y -af 0.95', sphPath, phnPath, channel));
        end
        if (status ~= 0)
            error(cmdout);
        end
    end
end
fprintf('Converting finished, Elapsed time is %f seconds.\n', toc);
end