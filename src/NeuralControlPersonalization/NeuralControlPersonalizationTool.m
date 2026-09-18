% This function is part of the NMSM Pipeline, see file for full license.
%
% Top-level entry point for Neural Control Personalization. Parses the
% settings XML, optionally runs Muscle Tendon Length Initialization for
% a warm-started initial guess, runs the NCP optimization, and saves
% synergy weights/commands, combined activations, and modeled joint
% moments to the results directory.
%
% The optional app is the GUI's run window. It is used three ways:
% updateRunStageGui toggles the stage labels, CancelOptimizationGui is
% installed as fmincon's OutputFcn so the Cancel button can stop the solver,
% and isRunCancelled is read between stages so a cancel during Muscle Tendon
% Length Initialization does not fall through into the NCP optimization. All
% three are found by name, so a scripted run that passes no app is
% unaffected.
%
% (string, App) -> (None)
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

function NeuralControlPersonalizationTool(settingsFileName, app)
tic
try
    verifyProjectOpened()
catch
    error("NMSM Pipeline Project is not opened.")
end
if nargin < 2
    app = [];
end
settingsTree = xml2struct(settingsFileName);
verifyVersion(settingsTree, "NeuralControlPersonalizationTool");
[inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree);
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
[~, fname, fext] = fileparts(settingsFileName);
copyfile(settingsFileName, fullfile(resultsDirectory, fname + fext));
updateRunStageGui(app, 'ParsingLabel', 'off');
outputLogFile = fullfile("commandWindowOutput.txt");
diary(outputLogFile)
precalInputs = parseMuscleTendonLengthInitializationSettingsTree(settingsTree);
if isstruct(precalInputs)
    updateRunStageGui(app, 'RunningMTLILabel', 'on');
    optimizedInitialGuess = MuscleTendonLengthInitialization(precalInputs, app);
    inputs = updateNcpInitialGuess(inputs, precalInputs, ...
        optimizedInitialGuess);
    updateRunStageGui(app, 'RunningMTLILabel', 'off');
end
% Cancelling during initialization only produced an initial guess, so there
% is nothing worth optimizing or saving. Cancelling during NCP itself is
% different: fmincon returns the iterate it stopped on, and that is saved
% below the same way a converged run is.
if runCancelled(app)
    diary off
    return
end

updateRunStageGui(app, 'RunningNCPLabel', 'on');
[optimizedValues, inputs] = NeuralControlPersonalization(inputs, params, app);
updateRunStageGui(app, 'RunningNCPLabel', 'off');
updateRunStageGui(app, 'SavingResultsLabel', 'on');
[synergyWeights, synergyCommands] = findSynergyWeightsAndCommands( ...
    optimizedValues, inputs);
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
updateRunStageGui(app, 'SavingResultsLabel', 'off');
fprintf("Neural Control Personalization Runtime: %f Hours\n", toc/3600);
diary off
end

% (App) -> (logical)
% True when the GUI's Cancel button has been pressed. A scripted run has no
% app and is never cancelled.
function cancelled = runCancelled(app)
cancelled = ~isempty(app) && ismethod(app, "isRunCancelled") && ...
    app.isRunCancelled();
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
