function outputWav = removeSilenceUsingPhn(inputWav, phnFile)
outputWav = [];
fid = fopen(phnFile, 'r');
if (fid <= 0)
    outputWav = inputWav;
    return;
end
seg = textscan(fid, '%d %d %s\n');
fclose(fid);
seg = filterSegmentation(seg);
sIdx = seg{1};
eIdx = seg{2};
type = seg{3};
for i = 1 : length(type)
    if type{i} == 'S'
        if eIdx(i) <= length(inputWav)
            outputWav = [outputWav; inputWav(sIdx(i):eIdx(i))];
        end
    end
end
end

function seg = filterSegmentation(seg)
minNumberOfSampleInEachSegments = 1000;
sIdx = seg{1};
eIdx = seg{2};
type = seg{3};
i = 1;
while (i <= length(type))
    if (strcmp(type{i}, 'S') == 1 && (eIdx(i) - sIdx(i)) < minNumberOfSampleInEachSegments)
        if (i > 1)
            eIdx(i - 1) = eIdx(i);
            sIdx(i) = []; eIdx(i) = []; type(i) = [];
            if (i <= length(type))
                eIdx(i - 1) = eIdx(i);
                sIdx(i) = []; eIdx(i) = []; type(i) = [];
            end
        elseif (i < length(type))
            type{i} = '#h';
            eIdx(i) = eIdx(i + 1);
            sIdx(i + 1) = []; eIdx(i + 1) = []; type(i + 1) = [];
            i = i + 1;
        end
    else
        i = i + 1;
    end
end
i = 1;
while (i <= length(type))
    if (strcmp(type{i}, 'S') ~= 1 && (eIdx(i) - sIdx(i)) < minNumberOfSampleInEachSegments)
        if (i > 1)
            eIdx(i - 1) = eIdx(i);
            sIdx(i) = []; eIdx(i) = []; type(i) = [];
            if (i <= length(type))
                type{i} = 'S';
                eIdx(i - 1) = eIdx(i);
                sIdx(i) = []; eIdx(i) = []; type(i) = [];
            end
        elseif (i < length(type))
            eIdx(i) = eIdx(i + 1);
            sIdx(i + 1) = []; eIdx(i + 1) = []; type(i + 1) = [];
            i = i + 1;
        end
    else
        i = i + 1;
    end
end
seg{1} = sIdx;
seg{2} = eIdx;
seg{3} = type;
end