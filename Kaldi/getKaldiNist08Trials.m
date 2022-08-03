function [nist08Trials, targetFlags] = getKaldiNist08Trials(filePath)
global params;
% filePath = 'C:\Users\Hossein\Desktop\sre08_trials\short2-short3-male.trials';
fid = fopen(filePath, 'rt');
% model_id test_id_channel trial_status is_1 is_2 is_3 is_4 is_5 is_6 is_7 is_8
trialKeys = textscan(fid, '%d %s %s %c %c %c %c %c %c %c %c', 'Delimiter', ' \t\r\n');
fclose(fid);
nist08Trials = cell(0, 2);
targetFlags = zeros(0, 1);
tIdx = 1;
for m = 1 : length(trialKeys{1})
    if (params.conditionNumber ~= 0 && trialKeys{3 + params.conditionNumber}(m) ~= 'Y')
        continue;
    end
    nist08Trials{tIdx, 1} = trialKeys{2}{m};
    nist08Trials{tIdx, 2} = trialKeys{1}(m);
    if (strcmp(trialKeys{3}{m}, 'target') == 1)
        targetFlags(tIdx, 1) = 1;
    else
        targetFlags(tIdx, 1) = 0;
    end
    tIdx = tIdx + 1;
end