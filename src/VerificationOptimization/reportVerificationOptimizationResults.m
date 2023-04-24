% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function reportVerificationOptimizationResults(solution, inputs)

values = getVerificationOptimizationValueStruct(solution.solution.phase, inputs);
if strcmp(inputs.controllerType, 'synergy_driven') 
% plot Muscle Activations
plotMuscleActivations(solution.muscleActivations, values.time, ...
    inputs.experimentalMuscleActivations, inputs.experimentalTime, ...
    inputs.muscleLabels);
%% fix title labels"
% plot synergy activations
plotResultsWithOutComparison(values.controlNeuralCommands, values.time, ...
    ["command1", "command2", "command3", "command4", "command5", "command6", ...
    "command7", "command8", "command9", "command10", "command11", "command12"], ...
    ["Synergy" "Activations"]);
end
% plot joint angles
plotResultsWithComparison(values.statePositions, values.time, ...
    inputs.experimentalJointAngles, inputs.experimentalTime, ...
    strcat(inputs.coordinateNames, ' [rad]'), ["Joint" "Angles [rad]"]);
% plot joint moments
plotResultsWithComparison(solution.inverseDynamicMoments, values.time, ...
    inputs.experimentalJointMoments, inputs.experimentalTime, ...
    strcat(inputs.inverseDynamicMomentLabels, ' [Nm]'), ["Joint" "Moments"]);
% plot ground reactions
for i = 1:length(inputs.contactSurfaces)
plotResultsWithComparison(solution.groundReactionsLab.forces{i}, values.time, ...
    inputs.contactSurfaces{i}.experimentalGroundReactionForces, inputs.experimentalTime, ...
    ["GRFx", "GRFy", "GRFz"], ["Ground" "Reaction Forces"]);
plotResultsWithComparison(solution.groundReactionsLab.moments{i}, values.time, ...
    inputs.contactSurfaces{i}.experimentalGroundReactionMoments, inputs.experimentalTime, ...
    ["GRTx", "GRTy", "GRTz"], ["Ground" "Reaction Moments"]);
end
end
function plotMuscleActivations(muscleActivations, time, ...
    experimentalMuscleActivations, experimentalTime, muscleLabels)

figure('name', 'Muscle Activations')
nplots = ceil(sqrt(size(muscleActivations, 2)));
for i = 1 : size(muscleActivations,2)
subplot(nplots, nplots, i)
plot(time, muscleActivations(:, i)); hold on
plot(experimentalTime, experimentalMuscleActivations(:, i), 'r')
axis([0 1 0 experimentalTime(end)])
title(muscleLabels(i))
figureXLabels(numel(muscleLabels), nplots, i, "Time")
figureYLabels(numel(muscleLabels), nplots, i, ["Muscle" "Activation"])
end
end
function plotResultsWithComparison(solutionData, solutionTime, ...
    experimentalData, experimentalTime, labels, figureTitle)

figure('name', strjoin(figureTitle))
nplots = ceil(sqrt(numel(labels)));
for i = 1 : size(solutionData,2)
subplot(nplots, nplots, i)
plot(solutionTime, solutionData(:, i)); hold on
plot(experimentalTime, experimentalData(:, i), 'r')
xlim([0 experimentalTime(end)])
title(labels(i))
figureXLabels(numel(labels), nplots, i, "Time")
end
end
function plotResultsWithOutComparison(solutionData, solutionTime, ...
    labels, figureTitle)

figure('name', strjoin(figureTitle))
for i = 1 : size(solutionData,2)
subplot(numel(labels), 1, i)
plot(solutionTime, solutionData(:, i)); hold on
xlim([0 solutionTime(end)])
title(labels(i))
figureXLabels(numel(labels), 1, i, "Time")
end
end
function figureXLabels(numTotalPlots, numColumnPlots, plotIndex, xLabel)

if plotIndex > numTotalPlots - numColumnPlots
    xlabel(xLabel); 
else 
    xticklabels(''); 
end
end
function figureYLabels(numTotalPlots, numColumnPlots, plotIndex, yLabel)

if ismember(plotIndex, 1 : numColumnPlots : numTotalPlots)
    ylabel({yLabel(1); yLabel(2)});
else 
    yticklabels(''); 
end
end