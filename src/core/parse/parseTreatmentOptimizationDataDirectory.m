% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a parsed settings tree (xml2struct) and finds the
% inverse dynamics, inverse kinematics, ground reactions (if applicable),
% muscle activation (if applicable) and muscle analysis (if applicable)
% data directories.
%
% (struct, struct) -> (struct)
% Returns input structure with experimental data

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function inputs = parseTreatmentOptimizationDataDirectory(tree, inputs)
[dataDirectory, inputs.previousResultsDirectory] = findDataDirectory(tree, inputs);
inputs.trialName = parseTrialName(tree);
inputs = parseExperimentalData(tree, inputs, dataDirectory);
inputs = parseSynergyExperimentalData(tree, inputs, dataDirectory);
inputs = parseInitialValues(tree, inputs);
inputs.numCoordinates = size(inputs.experimentalJointAngles, 2);
end

function [dataDirectory, previousResultsDirectory] = ...
    findDataDirectory(tree, inputs)
dataDirectory = parseDataDirectory(tree);
previousResultsDirectory = ...
    parseTextOrAlternate(tree, "previous_results_directory", "");
if strcmp(previousResultsDirectory, "") && ...
        strcmp(inputs.controllerType, 'synergy')
    throw(MException("ParseError:RequiredElement", ...
        strcat("Element <previous_results_directory> required", ...
        " for <RCNLSynergyController>, this can be an NCP", ...
        " or Treatment Optimization results directory")))
end
end

function inputs = parseExperimentalData(tree, inputs, dataDirectory)
[inputs.experimentalJointMoments, ...
    inputs.inverseDynamicsMomentLabels] = ...
    parseTrialDataTryDirectories( ...
    fullfile(inputs.previousResultsDirectory, "IDData"), ...
    fullfile(dataDirectory, "IDData"), inputs.trialName, inputs.model);
[inputs.experimentalJointAngles, inputs.coordinateNames, ...
    experimentalTime] = parseTrialDataTryDirectories( ...
    fullfile(inputs.previousResultsDirectory, "IKData"), ...
    fullfile(dataDirectory, "IKData"), inputs.trialName, inputs.model);
inputs.coordinateNames = cellstr(inputs.coordinateNames);
inputs.experimentalTime = experimentalTime - experimentalTime(1);
if exist(fullfile(dataDirectory, "GRFData"), 'dir')
    inputs.grfFileName = findFileListFromPrefixList(...
        fullfile(dataDirectory, "GRFData"), prefix);
end
end

function inputs = parseSynergyExperimentalData(tree, inputs, dataDirectory)
if strcmp(inputs.controllerType, "synergy")
    [inputs.experimentalMuscleActivations, inputs.muscleLabels] = ...
        parseTrialData(inputs.previousResultsDirectory, ...
        strcat(inputs.trialName, "_combinedActivations"), inputs.model);
    inputs.synergyWeights = parseTrialData(inputs.previousResultsDirectory, ...
        "synergyWeights", inputs.model);
    directory = fullfile(dataDirectory, "MAData", inputs.trialName);
    inputs.momentArms = parseSelectMomentArms(directory, ...
        inputs.surrogateModelCoordinateNames, inputs.muscleNames);
    inputs.momentArms = reshape(permute(inputs.momentArms, [1 4 2 3]), [], ...
        length(inputs.surrogateModelCoordinateNames), length(inputs.muscleNames));
    inputs = getMuscleSpecificSurrogateModelData(inputs);
end
end

function inputs = parseInitialValues(tree, inputs)
initialGuess = [];
try
    [inputs.initialStates, inputs.initialStatesLabels, inputs.initialTime] = ...
        parseTrialData(inputs.previousResultsDirectory, ...
        strcat(inputs.trialName, "_states"), inputs.model);
catch; end
try
    [inputs.initialJerks, inputs.initialJerksLabels] = ...
        parseTrialData(inputs.previousResultsDirectory, ...
        strcat(inputs.trialName, "_jerks"), inputs.model);
catch; end
try
    [inputs.initialTorqueControls, inputs.initialTorqueControlsLabels] = ...
        parseTrialData(inputs.previousResultsDirectory, ...
        strcat(inputs.trialName, "_torqueControls"), inputs.model);
catch;end
if strcmp(inputs.controllerType, "synergy")
    [inputs.initialSynergyControls, inputs.initialSynergyControlsLabels] = ...
        parseTrialData(inputs.previousResultsDirectory, ...
        strcat(inputs.trialName, "_synergyCommands"), inputs.model);
end
end

function [data, labels, time] = parseTrialDataTryDirectories( ...
    previousResultsDirectory, dataDirectory, trialName, model)
if ~strcmp(previousResultsDirectory, "")
    try
        [data, labels, time] = parseTrialData(...
            previousResultsDirectory, trialName, model);
    catch
        [data, labels, time] = parseTrialData( ...
            dataDirectory, trialName, model);
    end
else
    [data, labels, time] = parseTrialData(dataDirectory, trialName, model);
end
end
