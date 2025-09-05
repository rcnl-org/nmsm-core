% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes an NCP settings file and produces plots of NCP muscle
% activations, model moments, and if applicable, VAF and RMSE between
% tracked and NCP muscle activations
%
% (string) -> (None)

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

function plotNcpResultsFromSettingsFile(settingsFileName)
settingsTree = xml2struct(settingsFileName);
ncpResultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
mtpResultsDirectory = getFieldByName(settingsTree, 'mtp_results_directory');
inputDataDirectory = getFieldByName(settingsTree, 'data_directory').Text;
trialPrefixes = findPrefixes(settingsTree, inputDataDirectory);
inputModelFileName = parseElementTextByName(settingsTree, 'input_model_file');
inputOsimxFileName = parseElementTextByName(settingsTree, 'input_osimx_file');
if ~isempty(inputOsimxFileName)
    [~, osimxFileName, ~] = fileparts(inputOsimxFileName);
    osimxFileName = fullfile(ncpResultsDirectory, ...
        strcat(osimxFileName, "_ncp.osimx"));
else
    [~, modelFileName, ~] = fileparts(inputModelFileName);
    osimxFileName = fullfile(ncpResultsDirectory, ...
        strcat(modelFileName, "_ncp.osimx"));
end
for i = 1 : numel (trialPrefixes)
    if isstruct(mtpResultsDirectory) && ~isempty(mtpResultsDirectory.Text)
        plotNeuralControlPersonalizationActivations( ...
            fullfile(ncpResultsDirectory, "synergyWeights.sto"), ...
            fullfile(ncpResultsDirectory, strcat(trialPrefixes{i}, ...
                "_synergyCommands.sto")), ...
            fullfile(mtpResultsDirectory.Text, "muscleActivations", ...
                strcat(trialPrefixes{i}, "_muscleActivations.sto")));
        plotNcpActivationRmsAndVaf(...
            fullfile(ncpResultsDirectory, "synergyWeights.sto"), ...
            fullfile(ncpResultsDirectory, strcat(trialPrefixes{i}, ...
                "_synergyCommands.sto")), ...
            fullfile(mtpResultsDirectory.Text, "muscleActivations", ...
                strcat(trialPrefixes{i}, "_muscleActivations.sto")))
    else
        plotNeuralControlPersonalizationActivations( ...
            fullfile(ncpResultsDirectory, "synergyWeights.sto"), ...
            fullfile(ncpResultsDirectory, strcat(trialPrefixes{i}, ...
                "_synergyCommands.sto")), ...
            0)
    end
    plotMomentMatchingResults(...
        fullfile(inputDataDirectory, "IDData", strcat(trialPrefixes{i}, ".sto")), ...
        fullfile(ncpResultsDirectory, "modelMoments", ...
            strcat(trialPrefixes{i}, "_modeledMomentsNcp.sto")))
    plotTreatmentOptimizationSynergyControls( ...
        fullfile(ncpResultsDirectory, strcat(trialPrefixes{i}, "_synergyCommands.sto")), ...
        fullfile(ncpResultsDirectory, "synergyWeights.sto"), [], [], ...
        osimxFileName, inputModelFileName, "sum", 1)
end

