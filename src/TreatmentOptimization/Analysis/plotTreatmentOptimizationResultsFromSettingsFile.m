function plotTreatmentOptimizationResultsFromSettingsFile(settingsFileName)
settingsTree = xml2struct(settingsFileName);
toolName = findToolName(settingsTree);
resultsDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'results_directory'));
trackedQuantitiesDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'tracked_quantities_directory'));
initialGuessDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'initial_guess_directory'));
[isTorque, isSynergy] = parseControllers(settingsTree);
modelFileName = parseElementTextByName(settingsTree, 'input_model_file');
trialPrefix = getTextFromField(getFieldByName(settingsTree, ...
    'trial_name'));


plotTreatmentOptimizationJointAngles( ...
    modelFileName, ...
    fullfile(trackedQuantitiesDirectory, "IKData", strcat(trialPrefix, ".sto")), ...
    fullfile(resultsDirectory, "IKData", strcat(trialPrefix, ".sto")));

plotTreatmentOptimizationJointLoads( ...
    fullfile(trackedQuantitiesDirectory, "IDData", strcat(trialPrefix, ".sto")), ...
    fullfile(resultsDirectory, "IDData", strcat(trialPrefix, ".sto")));

plotTreatmentOptimizationGroundReactions( ...
    fullfile(trackedQuantitiesDirectory, "GRFData", strcat(trialPrefix, ".sto")), ...
    fullfile(resultsDirectory, "GRFData", strcat(trialPrefix, ".sto")));

if isTorque
    if strcmp(toolName, "DesignOptimization")
        plotTreatmentOptimizationControls( ...
            [fullfile(initialGuessDirectory, strcat(trialPrefix, "_torqueControls.sto")), ...
            fullfile(resultsDirectory, strcat(trialPrefix, "_torqueControls.sto"))])
    else
        plotTreatmentOptimizationControls( ...
            fullfile(resultsDirectory, strcat(trialPrefix, "_torqueControls.sto")))
    end
end
if isSynergy
    if strcmp(toolName, "DesignOptimization")
        plotTreatmentOptimizationControls( ...
            [fullfile(initialGuessDirectory, strcat(trialPrefix, "_synergyCommands.sto")), ...
            fullfile(resultsDirectory, strcat(trialPrefix, "_synergyCommands.sto"))])
    else
        plotTreatmentOptimizationControls( ...
            fullfile(resultsDirectory, strcat(trialPrefix, "_synergyCommands.sto")))
    end
end
end

function [isTorque, isSynergy] = parseControllers(settingsTree)
synergy = getFieldByName(settingsTree, 'RCNLSynergyController');
if isstruct(synergy)
    isSynergy = true;
else
    isSynergy = false;
end
torque = getFieldByName(settingsTree, 'RCNLTorqueController');
if isstruct(torque)
    isTorque = true;
else
    isTorque = false;
end
end

