
% NeuralControlPersonalizationTool("newNCPSettingsFile.xml");
settingsTree = xml2struct("newNCPSettingsFile.xml");

[inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree);
% NeuralControlPersonalization(inputs, params);

% org.opensim.modeling.Storage("D:\RCNL\Repositories\nmsm-core\examples\NeuralControlPersonalization\NCPParse\preprocessed\mtpResults\muscleActivations\speed1_gait_1_muscleActivations.sto")
