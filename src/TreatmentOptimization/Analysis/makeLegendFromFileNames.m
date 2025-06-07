function legendString = makeLegendFromFileNames(trackedDataFile, resultsDataFiles)
splitFileName = split(trackedDataFile, ["/", "\"]);
for k = 1 : numel(splitFileName)
    if ~strcmp(splitFileName(k), "..")
        legendString = sprintf("%s (T)", ...
            strrep(splitFileName(k), "_", " "));
        break
    end
end
for j = 1 : numel(resultsDataFiles)
    splitFileName = split(resultsDataFiles(j), ["/", "\"]);
    legendString(j+1) = sprintf("%s (%d)", splitFileName(1), j);
end
end

