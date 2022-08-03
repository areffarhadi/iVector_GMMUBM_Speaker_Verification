clc
clear
addpath('DeeBNet');
path(path, 'nist04');
path(path, 'nist08');
path(path, 'utility');
path(path, 'MSRIdentityToolkit');
path(path, 'JFA');
global params;
setParams();

%% Step0: Opening MATLAB pool
isopen = parpool('size') > 0;
if ~isopen, parpool(params.nworkers); end

%% Step1: Processing input files
[nist04SphFiles, nist04SpeakersId] = nist04GetSphFiles();
[nist04WavFiles, nist04SpeakersId] = nist04ConvertAndRemoveSilence(nist04SphFiles, nist04SpeakersId);
nist04FeaFiles = featureExtraction(nist04WavFiles, params.nist04FeaturesDir);
 nist04featureOutputDir = [params.nist04FeaturesDir(1:end - 1) '_' params.postProcessing filesep];
 nist04ProcessedFeaFiles = postProcessingFeatures(nist04FeaFiles, nist04featureOutputDir);
%nist04ProcessedFeaFiles = nist04FeaFiles;
load('nist08.mat');

%[nist08WavFiles, trainModelId2FileNameMap, nist08Trials, targetFlags] = nist08ConvertAndRemoveSilence();
nist08FeaFiles = featureExtraction(nist08WavFiles, params.nist08FeaturesDir);
 nist08featureOutputDir = [params.nist08FeaturesDir(1:end - 1) '_' params.postProcessing filesep];
 nist08ProcessedFeaFiles = postProcessingFeatures(nist08FeaFiles, nist08featureOutputDir);
%nist08featureOutputDir = [params.nist08FeaturesDir(1:end - 1) filesep];
%nist08ProcessedFeaFiles = nist08FeaFiles;
%% Step2: Training the UBM from nist04
final_niter = 20;
ds_factor = 1;
modelsOutputDir = [params.mainOutputDir params.feaType '_' params.postProcessing '_' params.gender '_' num2str(params.nmix) filesep];
if (~exist(modelsOutputDir, 'dir'))
    mkdir(modelsOutputDir);
end
ubmFilename = [modelsOutputDir 'ubm.mat'];
if (~exist(ubmFilename, 'file'))
    initModelPath = [params.mainOutputDir params.feaType '_' params.postProcessing '_' params.gender '_256' filesep 'ubm.mat'];
    if (exist(initModelPath, 'file'))
        initModel = load(initModelPath);
        initModel = initModel.gmm;
        ubm = gmm_em(nist04ProcessedFeaFiles, params.nmix, final_niter, ds_factor, params.nworkers, ubmFilename, initModel);
    else
        ubm = gmm_em(nist04ProcessedFeaFiles, params.nmix, final_niter, ds_factor, params.nworkers, ubmFilename);
    end
else
    ubm = load(ubmFilename);
    ubm = ubm.gmm;
end
%% Step3: Learning the total variability subspace from background data
tv_dim = 300;
niter  = 20;
tvFilename = [modelsOutputDir 'tv_T.mat'];
if (~exist(tvFilename, 'file'))
    if (exist([modelsOutputDir 'tv_stats.mat'], 'file'))
        load([modelsOutputDir 'tv_stats.mat']);
    else
        stats = cell(length(nist04ProcessedFeaFiles), 1);
        parfor file = 1 : length(nist04ProcessedFeaFiles),
            fData = htkread(nist04ProcessedFeaFiles{file});
%             [N, F] = compute_bw_stats(fData, ubm);
            [N, F] = collect_suf_stats(fData, ubm);
            stats{file} = [N; F];
        end
        save([modelsOutputDir 'tv_stats.mat'], 'stats');
    end
%     T = train_tv_space(stats, ubm, tv_dim, niter, params.nworkers, tvFilename);
    T = train_T(stats, ubm, tv_dim, niter, tvFilename);
else
    T = load(tvFilename);
    T = T.T;
    load([modelsOutputDir 'tv_stats.mat']);
end
%% Step4: Training the Gaussian PLDA model with development i-vectors
lda_dim = 100;
nphi    = 100;
niter   = 20;
[ndim, nmix] = size(ubm.mu);
S = reshape(ubm.sigma, ndim * nmix, 1);
dev_ivsFilename = [modelsOutputDir 'tv_dev_ivs.mat'];
if (~exist(dev_ivsFilename, 'file'))
    dev_ivs = zeros(tv_dim, length(nist04ProcessedFeaFiles));
    parfor file = 1 : length(nist04ProcessedFeaFiles),
%         dev_ivs(:, file) = extract_ivector(stats{file}, ubm, T);
        N = stats{file}(1 : nmix);
        F = stats{file}(nmix + 1 : end);
        dev_ivs(:, file) = estimate_w_and_T(F, N, S, T);
    end
    save(dev_ivsFilename, 'dev_ivs');
else
   load(dev_ivsFilename);
end

%% Step4: Scoring the verification trialspldaFilename = [modelsOutputDir 'tv_plda.mat'];
pldaFilename = [modelsOutputDir 'plda.mat'];
if (~exist(pldaFilename, 'file'))
    % reduce the dimensionality with LDA
    V = lda(dev_ivs, nist04SpeakersId);
    dev_ivs = V(:, 1 : lda_dim)' * dev_ivs;
    %------------------------------------
    plda = gplda_em(dev_ivs, nist04SpeakersId, nphi, niter);
    save(pldaFilename, 'plda', 'V');
else
    load(pldaFilename);
    dev_ivs = V(:, 1 : lda_dim)' * dev_ivs;
end

%%
%myLog('Scoring the verification trials...');
modelsId = unique(cell2mat(trainModelId2FileNameMap.keys)');
nmodels = length(modelsId);
modelIndexMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
model_ivs1 = zeros(tv_dim, nmodels);
trainFiles = cell(nmodels, 1);
model_ivs2 = model_ivs1;
for model = 1 : nmodels,
    model_files = trainModelId2FileNameMap(modelsId(model));
    for j = 1 : length(model_files)
        model_files{j} = [nist08featureOutputDir model_files{j} '.fea'];
    end
    trainFiles{model, 1} = model_files;
end
model_ivsFilename = [modelsOutputDir 'tv_model_ivs.mat'];
if (~exist(model_ivsFilename, 'file'))
    fprintf('Extracting model ivectors...\n');
    parfor model = 1 : nmodels,
        N = 0; F = 0; 
        for ix = 1 : length(trainFiles{model, 1}),
%             [n, f] = compute_bw_stats(trainFiles{model, 1}{ix}, ubm);
			fData = htkread(trainFiles{model, 1}{ix});
            [n, f] = collect_suf_stats(fData, ubm);
            N = N + n; F = f + F;
            model_ivs1(:, model) = model_ivs1(:, model) + estimate_w_and_T(f, n, S, T);
        end
        F = F / length(trainFiles{model, 1});
        N = N / length(trainFiles{model, 1});
        model_ivs2(:, model) = estimate_w_and_T(F, N, S, T); % stats averaging!
        model_ivs1(:, model) = model_ivs1(:, model) / length(trainFiles{model, 1}); % i-vector averaging!
    end
    save(model_ivsFilename, 'model_ivs1', 'model_ivs2');
else
    load(model_ivsFilename);
end
for model = 1 : nmodels
    modelIndexMap(modelsId(model)) = model;
end
%% Step4: Scoring the verification trials
%myLog('Scoring the verification trials...');
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
trials(flags == 1, :) = [];
Kmodel(flags == 1, :) = [];
Ktest(flags == 1, :) = [];
targetFlags(flags == 1, :) = [];

test_ivs = zeros(tv_dim, length(test_files));
parfor tst = 1 : length(test_files),
%     [N, F] = compute_bw_stats(test_files{tst}, ubm);
	fData = htkread(test_files{tst});
    [N, F] = collect_suf_stats(fData, ubm);
%     test_ivs(:, tst) = extract_ivector([N; F], ubm, T);
    test_ivs(:, tst) = estimate_w_and_T(F, N, S, T);
end
% reduce the dimensionality with LDA
model_ivs1 = V(:, 1 : lda_dim)' * model_ivs1;
model_ivs2 = V(:, 1 : lda_dim)' * model_ivs2;
test_ivs = V(:, 1 : lda_dim)' * test_ivs;
%------------------------------------
scores1 = score_gplda_trials(plda, model_ivs1, test_ivs);
linearInd = sub2ind([nmodels, length(test_files)], Kmodel, Ktest);
scores1 = scores1(linearInd); % select the valid trials

scores2 = score_gplda_trials(plda, model_ivs2, test_ivs);
scores2 = scores2(linearInd); % select the valid trials

%% Step5: Computing the EER and plotting the DET curve
eer1 = compute_eer(scores1, targetFlags, true); % IV averaging
%myLog(sprintf('Test finished, EER1 : %f', eer1));
hold on
eer2 = compute_eer(scores2, targetFlags, true); % stats averaging
fName = [params.feaType '_' params.postProcessing '_' params.gender '_' num2str(params.nmix)];
saveas(gcf, ['Results/IVEC_' fName '.fig'], 'fig');
%myLog(sprintf('Test finished, EER2 : %f', eer2));
if (params.logFile ~= 0)
    fclose(params.logFile);
end