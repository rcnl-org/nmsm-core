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
tic
try 
    verifyProjectOpened()
catch
    error("NMSM Pipeline Project is not opened.")
end
settingsTree = xml2struct(settingsFileName);
verifyVersion(settingsTree, "NeuralControlPersonalizationTool");
[inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree);
outputLogFile = fullfile("commandWindowOutput.txt");
diary(outputLogFile)
precalInputs = parseMuscleTendonLengthInitializationSettingsTree(settingsTree);
if isstruct(precalInputs)
    optimizedInitialGuess = MuscleTendonLengthInitialization(precalInputs);
    inputs = updateNcpInitialGuess(inputs, precalInputs, ...
        optimizedInitialGuess);
end

originalInputs = inputs;
[optimizedValues, inputs] = NeuralControlPersonalization(inputs, params);
if params.useCasadi
    synergyWeights = zeros(inputs.weightMatrixDimensions);
    synergyWeights(inputs.weightMatrixMap) = optimizedValues.weights;
    synergyWeights = synergyWeights';
    synergyCommands = zeros(inputs.numTrials, size(optimizedValues.commandsState, 2), size(optimizedValues.commandsState, 1) / inputs.numTrials);
    for i = 1 : inputs.numTrials
        synergyCommands(i, :, :) = resplineDataToNewTime(optimizedValues.commandsState((i - 1) * size(synergyCommands, 3) + 1 : i * size(synergyCommands, 3), :), inputs.collocationTime, inputs.time)';
    end
    inputs = restoreInputs(inputs, originalInputs);
else
    [synergyWeights, synergyCommands] = findSynergyWeightsAndCommands( ...
        optimizedValues, inputs, params);
end
[synergyWeights, synergyCommands] = normalizeSynergiesByMaximumWeight(...
    synergyWeights, synergyCommands);
[combinedActivations, ncpActivations] = combineFinalActivations(inputs, ...
    synergyWeights, synergyCommands);
combinedMuscleJointMoments = calcFinalMuscleJointMoments(inputs, ...
    combinedActivations);
ncpMuscleJointMoments = calcFinalMuscleJointMoments(inputs, ...
    ncpActivations);
saveNeuralControlPersonalizationResults(synergyWeights, ...
    synergyCommands, combinedActivations, combinedMuscleJointMoments, ...
    ncpMuscleJointMoments, inputs, resultsDirectory, precalInputs);
fprintf("Neural Control Personalization Runtime: %f Hours\n", toc/3600);
diary off
try
    copyfile(settingsFileName, fullfile(resultsDirectory, settingsFileName));
    movefile(outputLogFile, fullfile(resultsDirectory, outputLogFile));
catch
end
end

function [combinedActivations, synergyActivations] = ...
    combineFinalActivations(inputs, synergyWeights, synergyCommands)
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

function inputs = restoreInputs(inputs, originalInputs)
inputs.inverseDynamicsMoments = originalInputs.inverseDynamicsMoments;
inputs.muscleTendonLength = originalInputs.muscleTendonLength;
inputs.muscleTendonVelocity = originalInputs.muscleTendonVelocity;
inputs.mtpActivations = originalInputs.mtpActivations;
inputs.momentArms = originalInputs.momentArms;
end
