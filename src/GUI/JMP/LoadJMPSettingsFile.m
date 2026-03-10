function settingsTree = LoadJMPSettingsFile(app, settingsFileName)
settingsTree = xml2struct(settingsFileName);
settingsTree = settingsTree.NMSMPipelineDocument.JointModelPersonalizationTool;
end