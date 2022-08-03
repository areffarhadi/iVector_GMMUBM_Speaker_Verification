%% NIST04
% % nist04InfoFile = [params.nist04 'info_' params.gender '.mat'];
% % if (~exist(nist04InfoFile, 'file'))
% %     % Make nist 04
% %      wavFilePath = nist04GetSphFiles();
% %     % Create phn file for all file in this dataset
% %     % createPhnFile(wavFilePath);
% %     % Conver sph to wav form and remove silence from them using phn's from
% %     % previous step
% %    %* convertToWavAndRemoveSilence(wavFilePath);
% %     % Extract features for all wav files.
% %    %* extractFeatures(wavFilePath);
% %     % Get all utterances with gender equal to params.gender that feature file
% %     % of it created.
% %     [nist04UtterancesId, nist04SpeakersId, nist04FeaturesFile] = getUtterancesWithoutProblem(wavFilePath);
% % else
% %     temp = load(nist04InfoFile);
% %     nist04UtterancesId = temp.uttIdes;
% %     nist04SpeakersId = temp.spkIdes;
% %     nist04FeaturesFile = temp.feaPaths;
% % end

 [nist04SphFiles, nist04SpeakersId] = nist04GetSphFiles();
 [nist04WavFiles, nist04SpeakersId] = nist04ConvertAndRemoveSilence(nist04SphFiles, nist04SpeakersId);
 nist04FeaFiles = featureExtraction(nist04WavFiles, params.nist04FeaturesDir);
 nist04featureOutputDir = [params.nist04FeaturesDir(1:end - 1) '_' params.postProcessing filesep];
% nist04ProcessedFeaFiles = postProcessingFeatures(nist04FeaFiles, nist04featureOutputDir);
nist04ProcessedFeaFiles = nist04FeaFiles;
[nist08WavFiles, trainModelId2FileNameMap, nist08Trials, targetFlags] = nist08ConvertAndRemoveSilence();
nist08FeaFiles = featureExtraction(nist08WavFiles, params.nist08FeaturesDir);
% nist08featureOutputDir = [params.nist08FeaturesDir(1:end - 1) '_' params.postProcessing filesep];
% nist08ProcessedFeaFiles = postProcessingFeatures(nist08FeaFiles, nist08featureOutputDir);
nist08featureOutputDir = [params.nist08FeaturesDir(1:end - 1) filesep];
nist08ProcessedFeaFiles = nist08FeaFiles;