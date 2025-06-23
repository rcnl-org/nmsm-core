function legendString = makeLegendFromFileNames(trackedDataFile, resultsDataFiles)
[directory, ~, ~] = fileparts(trackedDataFile);
directoryFolderNames = split(directory, ["/", "\"]);
topFolderName = directoryFolderNames(end);
if any(strcmp(topFolderName, ["GRFData", "IDData", "IKData", "EMGData"]))
    topFolderName = directoryFolderNames(end-1);
end
legendString = sprintf("%s (T)", topFolderName);
for j = 1 : numel(resultsDataFiles)
    [directory, ~, ~] = fileparts(resultsDataFiles(j));
    directoryFolderNames = split(directory, ["/", "\"]);
    topFolderName = directoryFolderNames(end);
    if any(strcmp(topFolderName, ["GRFData", "IDData", "IKData", "EMGData"]))
        topFolderName = directoryFolderNames(end-1);
    end
    legendString(j+1) = sprintf("%s (%d)", topFolderName, j);
end
end

