function [columnNames, data] = extractMtpDataFromSto(resultsDirectoryParent, resultsDirectoryChild)
    import org.opensim.modeling.Storage
    if exist(fullfile(resultsDirectoryParent, resultsDirectoryChild), "dir")
        dataDir = dir(fullfile(resultsDirectoryParent, resultsDirectoryChild));
        dataFiles = {dataDir(3:end).name};
    else
        fprintf("%s not found\n", resultsDirectoryChild);
        return
    end
    data = cell(1, numel(dataFiles));
    for i = 1:numel(dataFiles)
        dataStorage = Storage(fullfile(fullfile(resultsDirectoryParent, resultsDirectoryChild, dataFiles{i})));
        columnNames = getStorageColumnNames(dataStorage);
        data{i} = storageToDoubleMatrix(dataStorage)';
    end
    trialSize = size(data{1});
    numTrials = numel(data);
    data = reshape(cell2mat(data), trialSize(1), trialSize(2), numTrials);
end