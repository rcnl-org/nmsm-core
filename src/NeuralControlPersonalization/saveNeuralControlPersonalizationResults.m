function saveNeuralControlPersonalizationResults(activations, ...
    synergyWeights, inputs, resultsDirectory)
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
writeToSto( ...
    inputs.muscleNames, ...
    1:size(synergyWeights, 1), ...
    synergyWeights, ...
    fullfile(resultsDirectory, "synergyWeights.sto"));
for i = 1 : size(activations, 1)
    writeToSto( ...
        inputs.muscleTendonColumnNames, ...
        inputs.time(i, :), ...
        squeeze(activations(i, :, :))', ...
        fullfile( ...
            resultsDirectory, ...
            inputs.prefixes(i) + "_activations.sto" ...
            ) ...
        )
end
end

