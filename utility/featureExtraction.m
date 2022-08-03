function featureFiles = featureExtraction(wavFiles, featureOutputDir)
global params;
if (nargin ~= 2)
    str = 'Error : featureExtraction function must have two argumnet.';
    myLog(str);
    error(str);
end
if (featureOutputDir(end) ~= filesep)
    featureOutputDir(end + 1) = filesep;
end
if (~exist(featureOutputDir, 'dir'))
    mkdir(featureOutputDir);
end
if (exist([featureOutputDir 'features.mat'], 'file'))
    load([featureOutputDir 'features.mat']);
    if (gender == params.gender) %#ok<NODEF>
        return;
    end
end
% =========================================================================
%* myLog('Generate wav2fea.scp');
featureFiles = cell(length(wavFiles), 1);
dic = containers.Map;
wav2feaFile = [featureOutputDir 'wav2fea.scp'];
fid = fopen(wav2feaFile, 'w');
fileCount = 0;
for i = 1 : length(wavFiles)
	[~, name] = fileparts(wavFiles{i});
    featureFiles{i} = [featureOutputDir name '.fea'];
    if (dic.isKey(name))
        continue;
    end
    dic(name) = wavFiles{i};
    if (~exist(featureFiles{i}, 'file'))
        fileCount = fileCount + 1;
        fprintf(fid, '"%s"\t"%s"\n', wavFiles{i}, featureFiles{i});
    end
end
fclose(fid);
% keys = dic.keys;
% count = floor(length(keys) / params.nworkers);
% endIdx = 1;
% for i = 1 : params.nworkers
%     wav2feaFile = [featureOutputDir 'wav2fea_' num2str(i) '.scp'];
%     fid = fopen(wav2feaFile, 'w');
%     if (fid == 0)
%         str = 'Error : Can not open wav2fea.scp file for writing';
%         myLog(str);
%         error(str);
%     end
%     startIdx = endIdx;
%     endIdx = startIdx + count;
%     if (endIdx >= length(keys) - params.nworkers)
%         endIdx = length(keys);
%     end
%     for j = startIdx : endIdx
%         feaFile = [featureOutputDir keys{i} '.fea'];
%         if (~exist(feaFile, 'file'))
%             fprintf(fid, '"%s"\t"%s"\n', dic(keys{j}), feaFile);
%         end
%     end
%     fclose(fid);
% end
% =========================================================================
%* myLog('Using HCopy for acoustic feature extraction...');
tic;
if (fileCount > 0)
    configFile = params.configFile;
    cmd = sprintf('HCopy -C "%s" -S "%s"', configFile, [featureOutputDir 'wav2fea.scp']);
    [status, cmdOut] = system(cmd);
  %  myLog(cmdOut);
    if (status ~= 0)
        error(cmdOut);
    end
    % parfor i = 1 : params.nworkers
    %     cmd = sprintf('HCopy -C "%s" -S "%s"', configFile, [featureOutputDir 'wav2fea_' num2str(i) '.scp']);
    %     [status, cmdOut] = system(cmd);
    %     myLog(cmdOut);
    %     if (status ~= 0)
    %         error(cmdOut);
    %     end
    % end
    % check that all file processed truly.
end
for i = 1 : length(featureFiles)
    if (~exist(featureFiles{i}, 'file'))
       str = ['Feature file not exist, ' featureFiles{i}];
       myLog(str);
       error(str);
    end
end
gender = params.gender; %#ok<NASGU>
save([featureOutputDir 'features.mat'], 'featureFiles', 'gender');
% myLog(sprintf('Feature extraction finished, Elapsed time is %f seconds.', toc));