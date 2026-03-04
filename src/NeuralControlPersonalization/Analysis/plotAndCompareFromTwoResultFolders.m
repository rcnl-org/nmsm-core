function plotAndCompareFromTwoResultFolders(ncpResultsFolder1, ncpResultsFolder2)
% Inputs are NCP results folders, each contains one *.xml settings copy

input1 = parseFromResultsFolder(ncpResultsFolder1);
input2 = parseFromResultsFolder(ncpResultsFolder2);

% --- Neural Control Personalization activations ---
plotNeuralControlPersonalizationActivations( ...
    fullfile(input1.ncpResultsDirectory, "synergyWeights.sto"), ...
    fullfile(input1.ncpResultsDirectory, input1.trialPrefixes{1} + "_synergyCommands.sto"), ...
    fullfile(input1.mtpResultsDirectory, "muscleActivations", input1.trialPrefixes{1} + "_muscleActivations.sto"));

plotNeuralControlPersonalizationActivations( ...
    fullfile(input2.ncpResultsDirectory, "synergyWeights.sto"), ...
    fullfile(input2.ncpResultsDirectory, input2.trialPrefixes{1} + "_synergyCommands.sto"), ...
    fullfile(input2.mtpResultsDirectory, "muscleActivations", input2.trialPrefixes{1} + "_muscleActivations.sto"));

% --- Muscle Activation RMS and VAF ---
plotNcpActivationRmsAndVaf( ...
    fullfile(input1.ncpResultsDirectory, "synergyWeights.sto"), ...
    fullfile(input1.ncpResultsDirectory, input1.trialPrefixes{1} + "_synergyCommands.sto"), ...
    fullfile(input1.mtpResultsDirectory, "muscleActivations", input1.trialPrefixes{1} + "_muscleActivations.sto"));

plotNcpActivationRmsAndVaf( ...
    fullfile(input2.ncpResultsDirectory, "synergyWeights.sto"), ...
    fullfile(input2.ncpResultsDirectory, input2.trialPrefixes{1} + "_synergyCommands.sto"), ...
    fullfile(input2.mtpResultsDirectory, "muscleActivations", input2.trialPrefixes{1} + "_muscleActivations.sto"));

% --- Moment matching ---
plotMomentMatchingResults( ...
    fullfile(input1.inputDataDirectory, "IDData", input1.trialPrefixes{1} + ".sto"), ...
    fullfile(input1.ncpResultsDirectory, "modelMoments", input1.trialPrefixes{1} + "_modeledMomentsNcp.sto"));

plotMomentMatchingResults( ...
    fullfile(input2.inputDataDirectory, "IDData", input2.trialPrefixes{1} + ".sto"), ...
    fullfile(input2.ncpResultsDirectory, "modelMoments", input2.trialPrefixes{1} + "_modeledMomentsNcp.sto"));

% --- Reorder + compare synergy controls ---
reorderAndPlotSynergyControls( ...
    fullfile(input1.ncpResultsDirectory, input1.trialPrefixes{1} + "_synergyCommands.sto"), ...
    fullfile(input1.ncpResultsDirectory, "synergyWeights.sto"), [], [], ...
    input1.osimxFileName, input1.inputModelFileName, input1.synergy_vector_normalization_method, ...
    input1.synergy_vector_normalization_value, input1.allow_negative_synergy_vector_weights, ...
    fullfile(input2.ncpResultsDirectory, input2.trialPrefixes{1} + "_synergyCommands.sto"), ...
    fullfile(input2.ncpResultsDirectory, "synergyWeights.sto"), [], [], ...
    input2.osimxFileName, input2.inputModelFileName, input2.synergy_vector_normalization_method, ...
    input2.synergy_vector_normalization_value, input2.allow_negative_synergy_vector_weights);
end


function input = parseFromResultsFolder(ncpResultsFolder)

ncpResultsFolder = string(getAbsPath(ncpResultsFolder));
baseFolder = string(fileparts(char(ncpResultsFolder))); % folder above results folder

settingsXml  = findSingleSettingsXml(ncpResultsFolder);
settingsTree = xml2struct(settingsXml);

input.ncpResultsDirectory = ncpResultsFolder;
mtpDirRaw  = getTextFromField(getFieldByName(settingsTree, 'mtp_results_directory'));
dataDirRaw = getTextFromField(getFieldByName(settingsTree, 'data_directory'));
input.mtpResultsDirectory = string(getAbsPath(fullfile(baseFolder, mtpDirRaw)));
input.inputDataDirectory  = string(getAbsPath(fullfile(baseFolder, dataDirRaw)));
input.trialPrefixes = findPrefixes(settingsTree, input.inputDataDirectory);
modelFileRaw = parseElementTextByName(settingsTree, 'input_model_file');
listing = dir(fullfile(char(ncpResultsFolder), "*.osimx"));
osimxFileRaw = listing(1).name;
input.inputModelFileName = string(getAbsPath(fullfile(baseFolder, modelFileRaw)));
input.osimxFileName = string(getAbsPath(fullfile(ncpResultsFolder, osimxFileRaw)));
% Synergy settings
input.allow_negative_synergy_vector_weights = strcmpi( ...
    getTextFromField(getFieldByNameOrAlternate(settingsTree, ...
    'allow_negative_synergy_vector_weights', 'false')), 'true');
input.synergy_vector_normalization_method = 'none';
input.synergy_vector_normalization_value = str2double(getTextFromField( ...
    getFieldByNameOrAlternate(settingsTree, 'synergy_vector_normalization_value', '1')));
end


function settingsXmlAbsPath = findSingleSettingsXml(resultsFolder)
% Exactly one xml in the folder
listing = dir(fullfile(char(resultsFolder), "*.xml"));
if isempty(listing)
    error("plotAndCompareFromTwoResultFolders:NoSettingsXml", ...
        "No *.xml settings file found in:\n  %s", resultsFolder);
end
if numel(listing) ~= 1
    names = string({listing.name});
    error("plotAndCompareFromTwoResultFolders:MultipleSettingsXml", ...
        "Expected exactly ONE *.xml in:\n  %s\nFound %d:\n  %s", ...
        resultsFolder, numel(listing), strjoin(names, newline + "  "));
end
settingsXmlAbsPath = fullfile(char(resultsFolder), listing(1).name);
end


function p = getAbsPath(p)
% returns absolute path
p = System.IO.Path.GetFullPath(p);
end
