function ubmRestimation(outputDir, featureFilesPath, niteration)
if (outputDir(end) ~= filesep)
    outputDir(end + 1) = filesep;
end
if (~exist(outputDir, 'dir'))
    mkdir(outputDir);
end
copyfile('ubm.mmf', [outputDir 'ubm.mmf']);
speakerID = 'ubm';
outFile = [outputDir speakerID '.mnl'];
fid = fopen(outFile, 'w');
fprintf(fid, '%s\n', speakerID);
fclose(fid);
%===============
outFile = [outputDir speakerID '.scp'];
fid = fopen(outFile, 'w');
for i = 1 : length(featureFilesPath)
    fprintf(fid, '%s\n', featureFilesPath{i});
end
fclose(fid);
%===============
outFile = [outputDir speakerID '.mlf'];
fid = fopen(outFile, 'w');
fprintf(fid, '#!MLF!#\n');
for i = 1 : length(featureFilesPath)
    [~, name] = fileparts(featureFilesPath{i});
    fprintf(fid, '"*/%s.lab"\n%s\n.\n', name, speakerID);
end
fclose(fid);
%===============
for i = 1 : niteration
    tic;
	cmd = sprintf('HERest -w 0.1 -t 250.0 150.0 1000.0 -I %s%s.mlf -S %s%s.scp -H %s%s.mmf %s%s.mnl'...
        ,outputDir, speakerID, outputDir, speakerID, outputDir, speakerID, outputDir, speakerID);
	[status, result] = dos(cmd);
    if status ~= 0
        error(result);        
    end
    fprintf('Finished ubm restimation iteration # %d, [total time : %f]\n', i, toc);
end
delete([outputDir speakerID '.mnl']);
delete([outputDir speakerID '.scp']);
delete([outputDir speakerID '.mlf']);