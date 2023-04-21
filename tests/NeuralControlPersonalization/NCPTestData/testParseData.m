
% NeuralControlPersonalizationTool("newNCPSettingsFile.xml");
settingsTree = xml2struct("newNCPSettingsFile.xml");

[inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree);
% NeuralControlPersonalization(inputs, params);
