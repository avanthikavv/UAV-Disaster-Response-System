clear;
clc;

datasetPath='C:\DisasterDataset';

imds=imageDatastore( ...
    datasetPath,...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

badFiles={};

for i=1:numel(imds.Files)

    try
        img=imread(imds.Files{i});

    catch

        fprintf('BAD FILE: %s\n',imds.Files{i});

        badFiles{end+1}=imds.Files{i};

    end

end

fprintf('\nTotal Bad Files = %d\n',length(badFiles));

for i=1:length(badFiles)

    delete(badFiles{i});

end

fprintf('\nBad files removed.\n');