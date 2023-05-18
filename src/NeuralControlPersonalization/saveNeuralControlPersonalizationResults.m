function saveNeuralControlPersonalizationResults(synergyWeights, ...
    synergyCommands, inputs, resultsDirectory)
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
writeToSto( ...
    inputs.muscleTendonColumnNames, ...
    1:size(synergyWeights, 1), ...
    synergyWeights, ...
    fullfile(resultsDirectory, "synergyWeights.sto"));
commandColumns = [];
for i = 1 : size(synergyWeights, 1)
    commandColumns = [commandColumns convertCharsToStrings(num2str(i))];
end
for i = 1 : size(synergyCommands, 1)
    writeToSto( ...
        commandColumns, ...
        inputs.time(i, :), ...
        squeeze(synergyCommands(i, :, :)), ...
        fullfile( ...
            resultsDirectory, ...
            inputs.prefixes(i) + "_synergyCommands.sto" ...
            ) ...
        )
end
if isstruct(precalInputs)
    writeNeuralControlPersonalizationOsimxFile()
end
end
