% This function is a wrapper for the JointModelPersonalization function
% such that an xml or osimx filename can be passed and the resulting
% computation can be completed according to the instructions of that file.

% Copyright RCNL *change later*

% (string) -> (None)
% Run JointModelPersonalization from settings file
function JointModelPersonalizationTool(settingsFileName)
settingsTree = xml2struct(settingsFileName);
[outputFile, inputs, params] = parseSettingsTree(settingsTree);
newModel = JointModelPersonalization(inputs, params);
newModel.print(outputFile);
end

