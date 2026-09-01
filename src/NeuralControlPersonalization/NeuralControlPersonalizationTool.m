% This function is part of the NMSM Pipeline, see file for full license.
%
% Top-level entry point for Neural Control Personalization. Parses the
% settings XML, optionally runs Muscle Tendon Length Initialization for
% a warm-started initial guess, runs the NCP optimization, and saves
% synergy weights/commands, combined activations, and modeled joint
% moments to the results directory.
%
% (string) -> (None)
% Runs Neural Control Personalization from a settings file

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
resultsDirectory = getUniqueResultsDirectory(resultsDirectory);
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
[~, fname, fext] = fileparts(settingsFileName);
copyfile(settingsFileName, fullfile(resultsDirectory, fname + fext));
outputLogFile = fullfile(resultsDirectory, "commandWindowOutput.txt");
diary(outputLogFile)
precalInputs = parseMuscleTendonLengthInitializationSettingsTree(settingsTree);
if isstruct(precalInputs)
    optimizedInitialGuess = MuscleTendonLengthInitialization(precalInputs);
    inputs = updateNcpInitialGuess(inputs, precalInputs, ...
        optimizedInitialGuess);
end

[optimizedValues, inputs] = NeuralControlPersonalization(inputs, params);
[synergyWeights, synergyCommands, ~] = findSynergyWeightsAndCommands( ...
    optimizedValues, inputs);
if inputs.optimize_synergy_vectors
    [synergyWeights, synergyCommands] = normalizeSynergiesByMaximumWeight(...
        synergyWeights, synergyCommands);
end
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
muscleJointMoments = calcMuscleJointMoments(inputs, ...
    activations, inputs.normalizedFiberLengths, ...
    inputs.normalizedFiberVelocities);

end
