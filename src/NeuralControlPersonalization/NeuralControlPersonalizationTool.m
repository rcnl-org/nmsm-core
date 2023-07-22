% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the necessary inputs and produces the results of IK,
% ID, and MuscleAnalysis so the values can be used as inputs for
% MuscleTendonPersonalization.
%
% (struct, struct) -> (None)
% Prepares raw data for MuscleTendonPersonalization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function NeuralControlPersonalizationTool(settingsFileName)
settingsTree = xml2struct(settingsFileName);
verifyVersion(settingsTree, "NeuralControlPersonalizationTool");
[inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree);

precalInputs = parseMuscleTendonLengthInitializationSettingsTree(settingsTree);
if isstruct(precalInputs)
    optimizedInitialGuess = MuscleTendonLengthInitialization(precalInputs);
    inputs = updateNcpInitialGuess(inputs, precalInputs, ...
        optimizedInitialGuess);
end

[optimizedValues, inputs] = NeuralControlPersonalization(inputs, params);
[synergyWeights, synergyCommands] = findSynergyWeightsAndCommands( ...
    optimizedValues, inputs, params);
[synergyWeights, synergyCommands] = normalizeSynergiesByMaximumWeight(...
    synergyWeights, synergyCommands);
combinedActivations = combineFinalActivations(inputs, synergyWeights, ...
    synergyCommands);
muscleJointMoments = calcFinalMuscleJointMoments(inputs, ...
    combinedActivations);
saveNeuralControlPersonalizationResults(synergyWeights, ...
    synergyCommands, combinedActivations, muscleJointMoments, inputs, ...
    resultsDirectory, precalInputs);
end

function combinedActivations = combineFinalActivations(inputs, ...
    synergyWeights, synergyCommands)
synergyActivations = zeros(inputs.numTrials, inputs.numMuscles, ...
    inputs.numPoints);
for i = 1:inputs.numTrials
    synergyActivations(i, :, :) = synergyWeights' * ...
        squeeze(synergyCommands(i, :, :))';
end
combinedActivations = synergyActivations;
if isfield(inputs, 'mtpActivationsColumnNames')
    for i = 1:length(inputs.mtpActivationsColumnNames)
        combinedActivations(:, inputs.muscleTendonColumnNames == ...
            inputs.mtpActivationsColumnNames(i), :) = ...
            inputs.mtpActivations(:, i, :);
    end
end
end

function muscleJointMoments = calcFinalMuscleJointMoments(inputs, ...
    activations)
[normalizedFiberLengths, normalizedFiberVelocities] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities( ...
    inputs, inputs.optimalFiberLengthScaleFactors, ...
    inputs.tendonSlackLengthScaleFactors);
muscleJointMoments = calcMuscleJointMoments(inputs, ...
    activations, normalizedFiberLengths, ...
    normalizedFiberVelocities);
end
