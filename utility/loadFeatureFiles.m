function data = loadFeatureFiles(featureFiles)
nfiles = length(featureFiles);
data = cell(nfiles, 1);
for ix = 1 : nfiles,
    data{ix} = htkread(featureFiles{ix});
end