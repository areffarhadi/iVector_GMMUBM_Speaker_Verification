% clc
% clear
addpath('DeeBNet');
path(path, 'nist04');
 path(path, 'nist08');
path(path, 'utility');
path(path, 'MSRIdentityToolkit');
global params;
setParams();

%% Step0: Opening MATLAB pool
nworkers = 12;
nworkers = min(nworkers, feature('NumCores'));
params.nworkers = nworkers;
isopen = parpool('size') > 0;
if ~isopen, parpool(nworkers); end

%% Step1: Processing input files
     [nist04SphFiles, nist04SpeakersId] = nist04GetSphFiles();
  [nist04WavFiles, nist04SpeakersId] = nist04ConvertAndRemoveSilence(nist04SphFiles, nist04SpeakersId);
  nist04FeaFiles = featureExtraction(nist04WavFiles, params.nist04FeaturesDir);
  nist04featureOutputDir = [params.nist04FeaturesDir(1:end - 1) '_' params.postProcessing filesep];
    nist04ProcessedFeaFiles = postProcessingFeatures(nist04FeaFiles, nist04featureOutputDir);
%  nist04ProcessedFeaFiles = preDBN(nist04FeaFiles, nist04featureOutputDir);  %AREF feature stacking for DBN
load('nist08.mat');
%  [nist08WavFiles, trainModelId2FileNameMap, nist08Trials, targetFlags] = nist08ConvertAndRemoveSilence();
 nist08FeaFiles = featureExtraction(nist08WavFiles, params.nist08FeaturesDir);
  nist08featureOutputDir = [params.nist08FeaturesDir(1:end - 1) '_' params.postProcessing filesep];
  nist08ProcessedFeaFiles = postProcessingFeatures(nist08FeaFiles, nist08featureOutputDir);
%  nist08ProcessedFeaFiles = preDBN(nist08FeaFiles, nist08featureOutputDir);  %AREF feature stacking for DBN

% nist08featureOutputDir = [params.nist08FeaturesDir(1:end - 1) filesep];
% nist08ProcessedFeaFiles = nist08FeaFiles;
%% Step2: Training the UBM from nist04
nmix = 32;
final_niter = 10;
ds_factor = 1;
modelsOutputDir = [params.mainOutputDir params.feaType '_' params.postProcessing '_' params.gender '_' num2str(nmix) filesep];
initModelPath = [params.mainOutputDir params.feaType '_' params.postProcessing '_' params.gender '_1024' filesep 'ubm.mat'];
if (~exist(modelsOutputDir, 'dir'))
    mkdir(modelsOutputDir);
end
ubmFilename = [modelsOutputDir 'ubm.mat'];
if (~exist(ubmFilename, 'file'))
    % nist04data = loadFeatureFiles(nist04ProcessedFeaFiles);
    if (exist(initModelPath, 'file'))
        initModel = load(initModelPath);
        initModel = initModel.gmm;
        ubm = gmm_em(nist04ProcessedFeaFiles, nmix, final_niter, ds_factor, nworkers, ubmFilename, initModel);
    else
        ubm = gmm_em(nist04ProcessedFeaFiles, nmix, final_niter, ds_factor, nworkers, ubmFilename);
    end
else
    ubm = load(ubmFilename);
    ubm = ubm.gmm;
end
%% Step3: Adapting the speaker models from UBM
fprintf('Start adapting the speaker models.\n');
map_tau = 10.0;
config = 'm''w';% adapt just mean
modelsId = unique(cell2mat(trainModelId2FileNameMap.keys)');
nmodels = length(modelsId);
gmm_models = cell(nmodels, 1);
modelIndexMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
for model = 1 : nmodels %parfor bud AREF changed
    model_files = trainModelId2FileNameMap(modelsId(model));
    for j = 1 : length(model_files)
        model_files{j} = [nist08featureOutputDir model_files{j} '.fea'];
    end
    gmmPath = [modelsOutputDir num2str(modelsId(model)) '.mat'];
    if (exist(gmmPath, 'file'))
        gmm = load(gmmPath);
        gmm_models{model} = gmm.gmm;
    else
        gmm_models{model} = mapAdapt(model_files, ubm, map_tau, config, gmmPath);
        % do second iteration
        gmm_models{model} = mapAdapt(model_files, gmm_models{model}, map_tau, config, gmmPath);
    end
end
for model = 1 : nmodels
    modelIndexMap(modelsId(model)) = model;
end
fprintf('Spaker model apaptation finished.\n');
%% Step4: Scoring the verification trials
%* myLog('Scoring the verification trials...');
values = cell2mat(nist08Trials(:, 2));
keys = nist08Trials(:, 1);
[model_ids, ~, Kmodel] = unique(values, 'stable'); % check if the order is the same as above!
[test_files, ~, Ktest] = unique(keys, 'stable');
for j = 1 : length(test_files)
    test_files{j} = [nist08featureOutputDir test_files{j} '.fea'];
end
trials = zeros(length(values), 2);
flags = zeros(length(values), 1);
for i = 1 : length(values)
    if (modelIndexMap.isKey(values(i)))
        trials(i, 1) = modelIndexMap(values(i));
        trials(i, 2) = Ktest(i);
    else
        flags(i) = 1;
    end
end
fprintf('All gmm models loaded.\n');
trials(flags == 1, :) = [];
scores = score_gmm_trials(gmm_models, test_files, trials, ubm);

%% Step5: Computing the EER and plotting the DET curve
eer = compute_eer(scores, targetFlags, true);
fName = [params.feaType '_' params.postProcessing '_' params.gender '_' num2str(nmix)];
saveas(gcf, ['Results/GMM_' fName '.fig'], 'fig');
%* myLog(sprintf('Test finished, EER : %f', eer));
if (params.logFile ~= 0)
    fclose(params.logFile);
end