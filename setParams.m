function setParams
 global params;
params.feaType = 'MFCC_Z';
params.testCondition = 'short2-short3';

if (filesep == '/')
    params.nist04MainDir = strrep('/media/kashef/ZeinaliHDD/NIST/NIST2004/NIST_SRE04/', '\', filesep);
    params.nist04 = strrep('/media/kashef/ZeinaliHDD/NIST/NIST04/', '\', filesep);
    params.nist04WavDir = strrep('/media/kashef/ZeinaliHDD/NIST/NIST04/Wav/', '\', filesep);
    params.nist04PhnDir = strrep('/media/kashef/ZeinaliHDD/NIST/NIST04/PHN/', '\', filesep);
    params.nist04FeaturesDir = strrep(['/media/kashef/ZeinaliHDD/NIST/NIST04/Features/' params.feaType filesep], '\', filesep);
    params.nist08TrainDir = '/media/kashef/ZeinaliHDD/NIST/NIST2008_train/';
    params.nist08TestDir = '/media/kashef/ZeinaliHDD/NIST/NIST2008_test/';
    params.nist08 = strrep('/media/kashef/ZeinaliHDD/NIST/NIST08/', '\', filesep);
    params.nist08WavDir = strrep('/media/kashef/ZeinaliHDD/NIST/NIST08/Wav/', '\', filesep);
    params.nist08PhnDir = strrep('/media/kashef/ZeinaliHDD/NIST/NIST08/PHN/', '\', filesep);
    params.nist08FeaturesDir = strrep(['/media/kashef/ZeinaliHDD/NIST/NIST08/Features/' params.feaType filesep], '\', filesep);
    params.nist08KeysDir = '/media/kashef/ZeinaliHDD/NIST/Other/NIST_SRE08_KEYS.v0.1/';
    params.mainOutputDir = '/media/kashef/ZeinaliHDD/NIST/Output/';
else
    params.nist04MainDir = strrep('D:\University\databases\NIST_2004\', '\', filesep);
    params.nist04 = strrep('D:\University\databases\NIST_2004\', '\', filesep);
    params.nist04WavDir = strrep('D:\University\databases\NIST_2004\Wav\', '\', filesep);
    params.nist04PhnDir = strrep('D:\University\databases\NIST_2004\PHN\', '\', filesep);
    params.nist04FeaturesDir = strrep(['D:\University\databases\NIST_2004\Features\' params.feaType filesep], '\', filesep);
    params.nist08TrainDir = 'E:\NIST\2008 NIST Speaker Recognition Evaluation\Train\';
    params.nist08TestDir = 'E:\NIST\2008 NIST Speaker Recognition Evaluation\NIST2008_test\';
    params.nist08 = strrep('E:\NIST\2008 NIST Speaker Recognition Evaluation\', '\', filesep);
    params.nist08WavDir = strrep('E:\NIST2008\Wav\', '\', filesep);
    params.nist08PhnDir = strrep('E:\NIST2008\PHN\', '\', filesep);
    params.nist08PhnDirA = strrep('E:\NIST2008\PHN\A\', '\', filesep);%AREF
    params.nist08PhnDirB = strrep('E:\NIST2008\PHN\B\', '\', filesep);%AREF
    params.nist08FeaturesDir = strrep(['E:\NIST2008\Features\' params.feaType filesep], '\', filesep);
    params.nist08KeysDir = 'E:\NIST2008\NIST_SRE08_KEYS.v0.1\';
    params.mainOutputDir = 'D:\University\databases\NIST_2004\Output\';
end
if (~exist(params.mainOutputDir, 'dir'))
    params.mainOutputDir = 'E:\output\';
end
params.resourcesPath = ['Resources' filesep];
%params.resourcesPath = ['D:\University\TOOLbox\SpeakerRecognition\Resources' filesep];
params.configFile = [params.resourcesPath 'Config.cfg'];
params.logFile = fopen('log.txt', 'w');
params.gender = 'M';
params.postProcessing = 'cmvn';
params.conditionNumber = 0;
params.speechType = 'all';
params.language = 'all';
params.nworkers = min(12, feature('NumCores'));
params.nmix = 512; %AREF 256 bud, baraye iVector kardam 512
params.useLda = false;
params.ldaDim = 200;
params.pldaDim = 150;
params.usePlda = true;
params.useCondPlda = false;
params.useKaldiPlda = false;
params.usePldaAsTransform = false;
params.normalizeScore = false;
params.usePca = false;
params.numOfPrincomp = 250;