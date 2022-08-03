function [nist08WavFiles, trainModelId2FileNameMap, nist08Trials, targetFlags] = nist08ConvertAndRemoveSilence()
global params;
validModels = getValidModels(params);
% if (exist([params.nist08 'nist08.mat'], 'file'))
%     load([params.nist08 'nist08.mat']);
%     if (validModelCount == validModels.Count) %#ok<NODEF>
%         return;
%     end
% end
% * myLog('Converting of nist08 sph files started...');
tic;
outputWavDir = params.nist08WavDir;
if (outputWavDir(end) ~= filesep)
    outputWavDir(end + 1) = filesep;
end
if (~exist(outputWavDir, 'dir'))
    mkdir(outputWavDir);
end
phnDir = params.nist08PhnDir;
if (phnDir(end) ~= filesep)
    phnDir(end + 1) = filesep;
end
if (~exist(phnDir, 'dir'))
    mkdir(phnDir);
end
cond = textscan(params.testCondition, '%s', 'Delimiter', '-');
trainDir = cond{1}{1};
testDir = cond{1}{2};
sphDir = [params.nist08TrainDir trainDir];
if (params.gender == 'M')
    gen = {'male'};
elseif (params.gender == 'F')
    gen = {'female'};
else
    gen = {'male'; 'female'};
end
nist08WavFiles = cell(1, 1);
trainModelId2FileNameMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
idx = 1;
for i = 1 : length(gen) %0
    fid = fopen([params.nist08TrainDir gen{i} filesep trainDir '.trn'], 'rt');
    models = textscan(fid, '%d %s', 'Delimiter', ' \t\r');
    fclose(fid);
    for m = 1 : length(models{2})
        if (~validModels.isKey(models{1}(m)))
            continue;
        end
        fIds = textscan(models{2}{m}, '%s', 'Delimiter', ',');
        fIds = fIds{1};
        modelFiles = cell(0, 1);
        ii = 1;
        for f = 1 : length(fIds)
            channel = fIds{f}(end);
            if (channel ~= 'A' && channel ~= 'B')
                myLog(['Warnning : Undefind channel id, ' gen{i} ', ' fIds{f}]);
                continue;
            end
            [~, name, ext] = fileparts(fIds{f}(1:end-2));
            sphFile = [sphDir filesep name ext];
            modelFiles{ii, 1} = [name '_' channel];
            ii = ii + 1;
            file = [outputWavDir name '_' channel '.wav'];
            if (exist(file, 'file'))
                files = {file};
            else
                files = convertOneSphFile(sphFile, phnDir, outputWavDir, channel);
            end
            nist08WavFiles{idx, 1} = files{1, 1};
            if (mod(idx, 50) == 0)
                fprintf('%d files converted.\n', idx);
            end
            idx = idx + 1;
        end
        trainModelId2FileNameMap(models{1}(m)) = modelFiles;
    end
end
sphDir = [params.nist08TestDir 'test' filesep 'data' filesep testDir];
fid = fopen([params.nist08TestDir 'trials' filesep params.testCondition '.ndx'], 'rt');
trials = textscan(fid, '%d %c %s', 'Delimiter', ' \t\r');
fclose(fid);
keyPath = [params.nist08KeysDir 'trial-keys' filesep 'NIST_SRE08_' params.testCondition '.trial.key'];
if (~exist(keyPath, 'file'))
    str = ['Error : Nist08 key file not exist, path : ' keyPath];
    myLog(str);
    error(str);
end
fid = fopen(keyPath, 'rt');
% model_id,test_id,channel,trial_status,is_1,is_2,is_3,is_4,is_5,is_6,is_7,is_8
trialKeys = textscan(fid, '%d %s %c %s %c %c %c %c %c %c %c %c', 'Delimiter', ',\t\r', 'HeaderLines', 1);
fclose(fid);
if (length(trials{1}) ~= length(trialKeys{1}))
    str = 'Error : Trial file and its key does not have equal entry.';
    myLog(str);
    error(str);
end
nist08Trials = cell(0, 2);
targetFlags = zeros(0, 1);
tIdx = 1;
for m = 1 : length(trials{2})
    channel = trials{3}{m}(end);
    if (channel ~= 'A' && channel ~= 'B')
        myLog(['Warnning : Undefind channel id in trials, ' num2str(trials{1}(m)) ', ' trials{3}{m}]);
        continue;
    end
    if (trials{1}(m) ~= trialKeys{1}(m))
        str = 'Invalid key file. model id doesnt match.';
        myLog(str);
        error(str);
    end
    if (~validModels.isKey(trials{1}(m)))
        continue;
    end
    if (trials{2}(m) ~= 'm' && trials{2}(m) ~= 'f')
        myLog(['Warnning : Undefind gender id in trials, ' num2str(trials{1}(m)) ', ' trials{3}{m}]);
        continue;
    end
    if (params.gender == 'M' && trials{2}(m) ~= 'm')
        continue;
    elseif (params.gender == 'F' && trials{2}(m) ~= 'f')
        continue;
    end
    if (params.conditionNumber ~= 0 && trialKeys{4 + params.conditionNumber}(m) ~= 'Y')
        continue;
    end
    [~, name, ext] = fileparts(trials{3}{m}(1:end-2));
    sphFile = [sphDir filesep name ext];
    nist08Trials{tIdx, 1} = [name '_' channel];
    nist08Trials{tIdx, 2} = trials{1}(m);
    if (strcmp(trialKeys{4}{m}, 'target') == 1)
        targetFlags(tIdx, 1) = 1;
    else
        targetFlags(tIdx, 1) = 0;
    end
    tIdx = tIdx + 1;
    file = [outputWavDir name '_' channel '.wav'];
    if (exist(file, 'file'))
        files = {file};
    else
        files = convertOneSphFile(sphFile, phnDir, outputWavDir, channel);
    end

    nist08WavFiles{idx, 1} = files{1, 1};
    if (mod(idx, 500) == 0)
        fprintf('%d files converted.\n', idx);
    end
    idx = idx + 1;
end
nist08WavFiles = unique(nist08WavFiles);
gender = params.gender; %#ok<NASGU>
if (~exist(params.nist08, 'dir'))
    mkdir(params.nist08);
end
validModelCount = validModels.Count; %#ok<NASGU>
%trainModelId2FileNameMap=validModels; %AREF
save([params.nist08 'nist08.mat'], 'validModelCount', 'nist08WavFiles', 'trainModelId2FileNameMap', 'nist08Trials', 'targetFlags');
%* myLog(sprintf('Converting finished, Elapsed time is %f seconds.', toc));
end

function validModels = getValidModels(params)
cond = textscan(params.testCondition, '%s', 'Delimiter', '-');
trainDir = cond{1}{1};
keyPath = [params.nist08KeysDir 'model-keys' filesep 'NIST_SRE08_' trainDir '.model.key'];
if (~exist(keyPath, 'file'))
    str = ['Error : Nist08 model key file not exist, path : ' keyPath];
    error(str);
end
fid = fopen(keyPath, 'rt');
% model_id,sex,segment_id:channel,speaker_id,speech_type,channel_type,language,speaker_native_language
% 10017,f,tdvlv:a,110118,interview,mic-12,ENG,USE
modelKeys = textscan(fid, '%d %c %s %d %s %s %s %s', 'Delimiter', ',\t\r', 'HeaderLines', 1);
fclose(fid);
validModels = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
for i = 1 : length(modelKeys{1})
    if (strcmp(params.speechType, 'all') ~= 1 && strcmp(params.speechType, modelKeys{5}{i}) ~= 1)
        continue;
    end
    if (strcmp(params.language, 'all') ~= 1 && strcmp(params.language, modelKeys{7}{i}) ~= 1)
        continue;
    end
    if (params.gender == 'M' && modelKeys{2}(i) ~= 'm')
        continue;
    elseif (params.gender == 'F' && modelKeys{2}(i) ~= 'f')
        continue;
    end
    validModels(modelKeys{1}(i)) = 1;
end
end