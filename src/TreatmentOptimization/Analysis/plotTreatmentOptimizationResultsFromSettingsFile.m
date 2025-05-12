% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (string) -> (None)
% Plot Treatment Optimization results.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function plotTreatmentOptimizationResultsFromSettingsFile(settingsFileName, ...
    resultsDirectories)
settingsTree = xml2struct(settingsFileName);
toolName = findToolName(settingsTree);
resultsDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'results_directory'));
if nargin > 1
    resultsDirectory = resultsDirectories;
end
trackedQuantitiesDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'tracked_quantities_directory'));
initialGuessDirectory = getTextFromField(getFieldByName(settingsTree, ...
    'initial_guess_directory'));
[isTorque, isSynergy] = parseControllers(settingsTree);
modelFileName = parseElementTextByName(settingsTree, 'input_model_file');
trialPrefix = getTextFromField(getFieldByName(settingsTree, ...
    'trial_name'));
if isSynergy
    if exist(fullfile(initialGuessDirectory, ...
            strcat(trialPrefix, "_combinedActivations.sto")), "file")
        experimentalEmgFile = fullfile(initialGuessDirectory, ...
            strcat(trialPrefix, "_combinedActivations.sto"));
    elseif exist(fullfile(initialGuessDirectory, "EMGData", ...
            strcat(trialPrefix, ".sto")), "file")
        experimentalEmgFile = fullfile(initialGuessDirectory, "EMGData", ...
            strcat(trialPrefix, ".sto"));
    elseif exist(fullfile(trackedQuantitiesDirectory, "EMGData", ...
            strcat(trialPrefix, ".sto")), "file")
        experimentalEmgFile = fullfile(trackedQuantitiesDirectory, ...
            "EMGData", strcat(trialPrefix, ".sto"));
    elseif exist(fullfile(trackedQuantitiesDirectory, ...
            strcat(trialPrefix, "_combinedActivations.sto")), "file")
        experimentalEmgFile = fullfile(trackedQuantitiesDirectory, ...
            strcat(trialPrefix, "_combinedActivations.sto"));
    end
end

plotTreatmentOptimizationJointAngles( ...
    modelFileName, ...
    fullfile(trackedQuantitiesDirectory, "IKData", strcat(trialPrefix, ".sto")), ...
    fullfile(resultsDirectory, "IKData", strcat(trialPrefix, ".sto")));

plotTreatmentOptimizationJointVelocities(...
    modelFileName, ...
    fullfile(trackedQuantitiesDirectory, "IKData", strcat(trialPrefix, ".sto")), ...
    fullfile(resultsDirectory, strcat(trialPrefix, "_states.sto")));

plotTreatmentOptimizationJointLoads( ...
    fullfile(trackedQuantitiesDirectory, "IDData", strcat(trialPrefix, ".sto")), ...
    fullfile(resultsDirectory, "IDData", strcat(trialPrefix, ".sto")));

if exist(fullfile(trackedQuantitiesDirectory, "GRFData"), 'dir')
    for i = 1 : numel(resultsDirectory)
        plotTreatmentOptimizationGroundReactions( ...
            fullfile(resultsDirectory(i), strcat(trialPrefix, "_replacedExperimentalGroundReactions.sto")), ...
            fullfile(resultsDirectory, "GRFData", strcat(trialPrefix, ".sto")));
    end
end

if isTorque
    torqueIndices = boolean([]);
    for i = 1 : numel(resultsDirectory)
        if exist(fullfile(resultsDirectory(i), strcat(trialPrefix, "_torqueControls.sto")))
            torqueIndices(i) = 1;
        else
            torqueIndices(i) = 0;
        end
    end

    if strcmp(toolName, "DesignOptimization") | strcmp(toolName, "VerificationOptimization")
        plotTreatmentOptimizationControls( ...
            [fullfile(trackedQuantitiesDirectory, strcat(trialPrefix, "_torqueControls.sto")), ...
            fullfile(resultsDirectory(torqueIndices), strcat(trialPrefix, "_torqueControls.sto"))])
    else
        plotTreatmentOptimizationControls( ...
            fullfile(resultsDirectory(torqueIndices), strcat(trialPrefix, "_torqueControls.sto")))
    end
end
if isSynergy
    synergyIndices = boolean([]);
    for i = 1 : numel(resultsDirectory)
        if exist(fullfile(resultsDirectory(i), strcat(trialPrefix, "_synergyCommands.sto")))
            synergyIndices(i) = 1;
        else
            synergyIndices(i) = 0;
        end
    end
    if strcmp(toolName, "DesignOptimization") | strcmp(toolName, "VerificationOptimization")
        plotTreatmentOptimizationControls( ...
            [fullfile(trackedQuantitiesDirectory, strcat(trialPrefix, "_synergyCommands.sto")), ...
            fullfile(resultsDirectory(synergyIndices), strcat(trialPrefix, "_synergyCommands.sto"))])

    else
        plotTreatmentOptimizationControls( ...
            fullfile(resultsDirectory(synergyIndices), strcat(trialPrefix, "_synergyCommands.sto")))
    end
    plotTreatmentOptimizationMuscleActivations(...
        fullfile(experimentalEmgFile), ...
        fullfile(resultsDirectory(synergyIndices), strcat(trialPrefix, "_combinedActivations.sto")))
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
if isstruct(torque) && ~isempty(torque.coordinate_list.Text)
    isTorque = true;
else
    isTorque = false;
end
end