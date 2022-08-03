clc;
clear;
path(path, 'nist04');
path(path, 'nist08');
path(path, 'utility');
path(path, 'MSRIdentityToolkit');
global params;
setParams();
[nist04SphFiles, nist04SpeakersId] = nist04GetSphFiles();
nist04SphFiles = nist04SphFiles(1:20);
nist04SpeakersId = nist04SpeakersId(1:20);
nist04WavFiles = nist04ConvertAndRemoveSilence(nist04SphFiles);
nist04FeaFiles = featureExtraction(nist04WavFiles, params.nist04FeaturesDir);
nist04featureOutputDir = [params.nist04FeaturesDir(1:end - 1) '_' params.postProcessing filesep];
nist04ProcessedFeaFiles = postProcessingFeatures(nist04FeaFiles, nist04featureOutputDir);
[nist08WavFiles, trainModelId2FileNameMap, testFileName2ModelIdMap] = nist08ConvertAndRemoveSilence();
nist08FeatureFiles = featureExtraction(nist08WavFiles, params.nist08FeaturesDir);
if (params.logFile ~= 0)
    fclose(params.logFile);
end