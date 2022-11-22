function NeuralControlPersonalizationTool(settingsFileName)
settingsTree = xml2struct(settingsFileName);
[inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree);
optimizedParams = NeuralControlPersonalization(inputs, params);
%% results is a structure, report not implemented yet
results = calcFinalMuscleActivations(optimizedParams, inputs);
results = calcFinalModelMoments(results, inputs);
save("results.mat", "results", '-mat')
% reportNeuralControlPersonalization(inputs.model, results)
saveNeuralControlPersonalizationResults(inputs.model, ...
    inputs.coordinates, results, resultsDirectory);
end