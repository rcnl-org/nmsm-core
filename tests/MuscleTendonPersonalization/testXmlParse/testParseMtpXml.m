
settingsFileName = "MTPSettingsFile.xml";
settingsTree = xml2struct(settingsFileName);
[inputs, params, resultsDirectory] = parseMuscleTendonPersonalizationSettingsTree(settingsTree);

MuscleTendonPersonalizationTool(settingsFileName)