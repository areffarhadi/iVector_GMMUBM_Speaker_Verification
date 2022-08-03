function [nist04SphFiles, nist04SpeakersId] = nist04GetSphFiles()
global params;
validModels = getValidModels(params);
if (exist([params.nist04 'nist04Files.mat'], 'file'))
    load([params.nist04 'nist04Files.mat']);
    if (validModelCount == validModels.Count) %#ok<NODEF>
        return;
    end
end
gender = params.gender;
mainDir = params.nist04MainDir;
if (~exist(mainDir, 'dir'))
    str = 'Error : Nist04 directory not found';
    myLog(str);
    error(str);
end
if (mainDir(end) ~= filesep)
    mainDir(end + 1) = filesep;
end
keyFilePath = strrep([mainDir 'keys\key-v3.txt'], '\', filesep);
if (~exist(keyFilePath, 'file'))
    error('Key file not exist.');
end
fid = fopen(keyFilePath, 'rt');
if (fid == 0)
    str = 'Error : Can not open nist04 key file.';
    myLog(str);
    error(str);
end
% segment_id language source channel segment_type speaker_id gender segment_len dialect mic_type phone_type
fileIds = textscan(fid, '%s %s %s %s %s %d %s %f %s %s %s', 'Delimiter', ' \r\n', 'HeaderLines', 1);
fclose(fid);
nist04SphFiles = cell(0, 1);
nist04SpeakersId = zeros(0, 1);
idx = 1;
for i = 1 : length(fileIds{1})
    if (strcmp(fileIds{5}{i}, '1s') ~= 1)
        continue;
    end
    if (strcmp(params.language, 'ENG') == 1 && fileIds{2}{i} ~= 'E')
        continue;
    end
    if (strcmp(fileIds{4}{i}, 'X2'))
        continue;
    end
    if (exist([mainDir 'test' filesep 'data' filesep fileIds{1}{i} '.sph'], 'file'))
        fPath = [mainDir 'test' filesep 'data' filesep fileIds{1}{i} '.sph'];
    else
      %*  myLog(sprintf('Test file not found : %s', fileIds{1}{i}));
        continue;
    end
    if (gender == 'B')
        nist04SphFiles{idx, 1} = fPath;
        nist04SpeakersId(idx, 1) = fileIds{6}(i);
        idx = idx + 1;
    elseif (gender == fileIds{7}{i})
        nist04SphFiles{idx, 1} = fPath;
        nist04SpeakersId(idx, 1) = fileIds{6}(i);
       
        idx = idx + 1;
    end
end
% =========================================================================
% search on train files
mapFilePath = strrep([mainDir 'keys\speaker-map-v3.txt'], '\', filesep);
if (~exist(mapFilePath, 'file'))
    error('Speaker-map file not exist.');
end
modelsMap = loadModelsMap(mapFilePath);
if (gender == 'B')
    male = dir(strrep([mainDir 'train\male\*.trn'], '\', filesep));
    female = dir(strrep([mainDir 'train\female\*.trn'], '\', filesep));
elseif (gender == 'M')
    male = dir(strrep([mainDir 'train\male\*.trn'], '\', filesep));
    female = [];
elseif (gender == 'F')
    male = [];
    female = dir(strrep([mainDir 'train\female\*.trn'], '\', filesep));
else
    str = 'Error : Unknown gender id.';
    myLog(str);
    error(str);
end
dic = containers.Map;
for m = 1 : length(male)
    if (strcmp(male(m).name, '3convs.trn') == 1 || strcmp(male(m).name, '10sec.trn') == 1 ||...
            strcmp(male(m).name, '30sec.trn') == 1)
        continue;
    end
    fid = fopen(strrep([mainDir 'train\male\' male(m).name], '\', filesep));
    ids = textscan(fid, '%d %s', 'Delimiter', ' \r\n');
    fclose(fid);
    for i = 1 : length(ids{2})
        if (~validModels.isKey(ids{1}(i)))
            continue;
        end
        names = textscan(ids{2}{i}, '%s', inf, 'Delimiter', ',');
        names = names{1};
        for n = 1 : length(names)
            if (dic.isKey(names{n}))
                continue;
            end
            dic(names{n}) = 1;
            if (exist([mainDir 'train' filesep 'data' filesep names{n}], 'file'))
                fPath = [mainDir 'train' filesep 'data' filesep names{n}];
            else
                myLog(sprintf('Male train file not found : %s', names{n}));
                continue;
            end
            if (modelsMap.isKey(ids{1}(i)))
                nist04SpeakersId(idx, 1) = modelsMap(ids{1}(i));
            else
                str = ['Model id not found in map, ' num2str(ids{1}(i))];
                myLog(str);
                error(str);
            end
            nist04SphFiles{idx, 1} = fPath;
           
            idx = idx + 1;
        end
    end
end
for m = 1 : length(female)
    if (strcmp(female(m).name, '3convs.trn') == 1 || strcmp(female(m).name, '10sec.trn') == 1 ||...
            strcmp(female(m).name, '30sec.trn') == 1)
        continue;
    end
    fid = fopen(strrep([mainDir 'train\female\' female(m).name], '\', filesep));
    ids = textscan(fid, '%d %s', 'Delimiter', ' \r\n');
    fclose(fid);
    for i = 1 : length(ids{2})
        if (~validModels.isKey(ids{1}(i)))
            continue;
        end
        names = textscan(ids{2}{i}, '%s', 'Delimiter', ',');
        names = names{1};
        for n = 1 : length(names)
            if (dic.isKey(names{n}))
                continue;
            end
            dic(names{n}) = 1;
            if (exist([mainDir 'train' filesep 'data' filesep names{n}], 'file'))
                fPath = [mainDir 'train' filesep 'data' filesep names{n}];
            else
                myLog(sprintf('Female train file not found : %s', names{n}));
                continue;
            end
            if (modelsMap.isKey(ids{1}(i)))
                nist04SpeakersId(idx, 1) = modelsMap(ids{1}(i));
            else
                str = ['Model id not found in map, ' num2str(ids{1}(i))];
                myLog(str);
                error(str);
            end
            nist04SphFiles{idx, 1} = fPath;
           
            idx = idx + 1;
        end
    end
end
if (~exist(params.nist04, 'dir'))
    mkdir(params.nist04);
end
validModelCount = validModels.Count; %#ok<NASGU>
save([params.nist04 'nist04Files.mat'], 'nist04SphFiles', 'nist04SpeakersId', 'validModelCount');
%* myLog(sprintf('Total number of files are : %d', length(nist04SphFiles)));
end

function modelsMap = loadModelsMap(mapFilePath)
fid = fopen(mapFilePath, 'rt');
if (fid == 0)
    str = 'Error : Can not open nist04 speaker-map file.';
    myLog(str);
    error(str);
end
modelsMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
% model_id speaker_id language gender condition
maps = textscan(fid, '%d %d %s %s %s', 'Delimiter', ' \r\n', 'HeaderLines', 1);
fclose(fid);
for i = 1 : length(maps{1})
    modelsMap(maps{1}(i)) = maps{2}(i);
end
end

function validModels = getValidModels(params)
keyPath = [params.nist04MainDir 'keys' filesep 'speaker-map-v3.txt'];
if (~exist(keyPath, 'file'))
    str = ['Error : Nist04 speaker map file not exist, path : ' keyPath];
    error(str);
end
fid = fopen(keyPath, 'rt');
% model_id speaker_id language gender condition
% 2000 4824 A M 8
modelKeys = textscan(fid, '%d %d %c %c %s', 'Delimiter', ' \t\r', 'HeaderLines', 1);
fclose(fid);
validModels = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
for i = 1 : length(modelKeys{1})
    if (strcmp(modelKeys{5}{i}, '10s') == 1 || strcmp(modelKeys{5}{i}, '30s') == 1 ||...
            strcmp(modelKeys{5}{i}, '3C') == 1)
        continue;
    end
    if (strcmp(params.language, 'ENG') == 1 && modelKeys{3}(i) ~= 'E')
        continue;
    end
    if (params.gender == 'M' && modelKeys{4}(i) ~= 'M')
        continue;
    elseif (params.gender == 'F' && modelKeys{4}(i) ~= 'F')
        continue;
    end
    validModels(modelKeys{1}(i)) = 1;
end
end