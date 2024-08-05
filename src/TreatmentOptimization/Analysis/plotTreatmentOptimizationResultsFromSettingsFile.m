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
