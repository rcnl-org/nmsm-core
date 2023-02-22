function saveNeuralControlPersonalizationResults(activations, ...
    synergyWeights, inputs, resultsDirectory)
writeToSto( ...
    inputs.muscleNames, ...
    1:size(synergyWeights, 1), ...
    synergyWeights, ...
    fullfile(resultsDirectory, "synergyWeights.sto"));
for i = 1 : size(activations, 1)
    writeToSto( ...
        inputs.muscleNames, ...
        inputs.time(i, :), ...
        squeeze(activations(i, :, :))', ...
        fullfile( ...
            resultsDirectory, ...
            inputs.prefixes(i) + "_activations.sto" ...
            ) ...
        )
end
end

