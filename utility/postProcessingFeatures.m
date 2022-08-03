function outFeatureFiles = postProcessingFeatures(featureFiles, featureOutputDir)
global params;
if (nargin ~= 2)
    error('This function must have two argumnet.');
end
postPro = params.postProcessing;
if (~exist(featureOutputDir, 'dir'))
    mkdir(featureOutputDir);
end
if (exist([featureOutputDir 'outFeatureFiles.mat'], 'file'))
    load([featureOutputDir 'outFeatureFiles.mat']);
    if (gender == params.gender)  %#ok<NODEF>
        return;
    end
end
% myLog('Starting postprocessing of features...');
tic;
numFiles = length(featureFiles);
outFeatureFiles = cell(numFiles, 1);
% myLog(sprintf('Total files is %d', length(featureFiles)));
dic = containers.Map;
for i = 1 : length(featureFiles)
    [~, name, ext] = fileparts(featureFiles{i});
    outFeatureFiles{i} = [featureOutputDir name ext];
    if (dic.isKey(featureFiles{i}))
        continue;
    end
    dic(featureFiles{i}) = 1;
end

keys = dic.keys;
% myLog(sprintf('Number of files to process is %d', length(keys)));
for i = 1 : length(keys)
    [~, name, ext] = fileparts(keys{i});
    outFea = [featureOutputDir name ext];
    if (~exist(outFea, 'file'))
        [data, frate, feakind] = htkread(keys{i});
        if (strcmp(postPro, 'cmn'))
            data = cmvn(data, 0);
        elseif (strcmp(postPro, 'cmvn'))
            data = cmvn(data, 1);
        elseif (strcmp(postPro, 'wcmn'))
            data = wcmvn(data, 301, 0);
        elseif (strcmp(postPro, 'wcmvn'))
            data = wcmvn(data, 301, 1);
        elseif (strcmp(postPro, 'warp'))
            data = fea_warping(data);
        elseif (strcmp(postPro, 'DBNFea'))
            data = DBNFea(data);
        else
            error('Undefind postprocessing.');
        end
        htkwrite(outFea, data, frate, feakind);

    end
    if (mod(i, 50) == 0)
        fprintf('File # %d processed.\n', i);
    end
end

% check that all file processed truly.
for i = 1 : length(outFeatureFiles)
    if (~exist(outFeatureFiles{i}, 'file'))
       str = ['Postprocessed feature file not exist, ' outFeatureFiles{i}];
       myLog(str);
       error(str);
    end
end
gender = params.gender; %#ok<NASGU>
save([featureOutputDir 'outFeatureFiles.mat'], 'outFeatureFiles', 'gender');
% myLog(sprintf('Post processing finished, Elapsed time is %f seconds.', toc));