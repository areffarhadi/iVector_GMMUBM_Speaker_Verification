nn = 5000;
nums = [100, 200, 300, 400, 500, 600, 700, 800];
if (params.gender == 'M')
    nn = 1000;
end
if (~params.normalizeScore)
    return;
end
zParamFile = [modelsOutputDir 'zParams'];
if (params.usePca)
    zParamFile = [zParamFile '_Pca-' num2str(params.numOfPrincomp)];
end
if (params.useLda)
    zParamFile = [zParamFile '_Lda-' num2str(params.ldaDim)];
end
if (params.usePldaAsTransform)
    zParamFile = [zParamFile '_PldaTransform-' num2str(params.pldaDim)];
end
% if (params.useWccn)
%     zParamFile = [zParamFile '_Wccn'];
% end
if (params.usePlda)
    zParamFile = [zParamFile '_Plda-' num2str(params.pldaDim)];
end
if (params.normalizeScore)
    zParamFile = [zParamFile '_ZTNorm'];
end
if (norm)
    zParamFile = [zParamFile '_Avg'];
else
    zParamFile = [zParamFile '_NoAvg'];
end
zParamFile = [zParamFile '.mat'];
if (exist(zParamFile, 'file'))
    fprintf('Loading normalization parameters...\n');
    load(zParamFile);
    fprintf('Loading normalization parameters finished.\n');
else
    fprintf('Calculating normalization parameters...\n');
    zMean = zeros(length(nums), numSpeakers);
    zStd = zeros(length(nums), numSpeakers);
    for s = 1 : numSpeakers
        normalizingVector = devData(sortIdx(1:nn, s), :);
        if (params.usePlda)
            normRe = score_gplda_trials(plda, normalizingVector', normalizingVector');
        else
            normRe = normalizingVector * normalizingVector';
            normRe = normRe - eye(size(normalizingVector, 1));
        end
        normRe = sort(normRe, 'descend');
        mm = mean(normRe)';
        ss = std(normRe)';
        zScores = normResults(sortIdx(1:nn, s), s);
        for i = 1 : length(nums)
            if (norm)
                meanRe = mean(normRe(1:nums(i), :))';
                % re = bsxfun(@rdivide, zScores, meanRe);
                re = bsxfun(@minus, zScores, meanRe);
            else
                re = zScores;
            end
            re = bsxfun(@minus, re, mm);
            re = bsxfun(@rdivide, re, ss);
            zMean(i, s) = mean(re);
            zStd(i, s) = std(re);
        end
        if (mod(s, 100) == 0)
            fprintf('In train : %d\n', s);
        end
    end
    save(zParamFile, 'zMean', 'zStd');
    fprintf('Calculating normalization parameters finished.\n');
end