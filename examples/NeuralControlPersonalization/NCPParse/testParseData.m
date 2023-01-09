
settingsTree = xml2struct("NCPLatest.xml");
[inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree);
NeuralControlPersonalization(inputs, ...
    params);
