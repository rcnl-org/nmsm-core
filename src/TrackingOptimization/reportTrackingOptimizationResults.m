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

function reportTrackingOptimizationResults(solution, inputs)

values = getTrackingOptimizationValueStruct(solution.solution.phase, inputs);
% plot Muscle Activations
plotMuscleActivations(solution.rightMuscleActivations, values.time, ...
    inputs.experimentalRightMuscleActivations, inputs.experimentalTime, ...
    inputs.muscleLabels(1 : 74));
plotMuscleActivations(solution.leftMuscleActivations, values.time, ...
    inputs.experimentalLeftMuscleActivations, inputs.experimentalTime, ...
    inputs.muscleLabels(1 : 74));
% plot joint angles
plotResultsWithComparison(values.statePositions, values.time, ...
    inputs.experimentalJointAngles, inputs.experimentalTime, ...
    strcat(inputs.jointAnglesLabels, ' [rad]'), ["Joint" "Angles [rad]"]);
% plot joint moments
plotResultsWithComparison(solution.inverseDynamicMoments, values.time, ...
    inputs.experimentalJointMoments, inputs.experimentalTime, ...
    strcat(inputs.inverseDynamicMomentLabels, ' [Nm]'), ["Joint" "Moments"]);
% plot ground reactions
plotResultsWithComparison(solution.rightGroundReactionsLab, values.time, ...
    inputs.experimentalRightGroundReactions, inputs.experimentalTime, ...
    ["GRFx", "GRFy", "GRFz", "GRTx", "GRTy", "GRTz"], ["Right Ground" "Reactions"]);
plotResultsWithComparison(solution.leftGroundReactionsLab, values.time, ...
    inputs.experimentalLeftGroundReactions, inputs.experimentalTime, ...
    ["GRFx", "GRFy", "GRFz", "GRTx", "GRTy", "GRTz"], ["Left Ground" "Reactions"]);
% plot root segment residuals
%% fix title labels"
plotResultsWithOutComparison(solution.rootSegmentResiduals, values.time, ...
    ["pelvis_tilt", "pelvis_list", "pelvis_rotation", "pelvis_tx", "pelvis_ty", "pelvis_tz"], ["Root Segment" "Residuals"]);
% plot synergy activations
plotResultsWithOutComparison(values.controlNeuralCommandsRight, values.time, ...
    ["command1", "command2", "command3", "command4", "command5", "command6"], ["Right Synergy" "Activations"]);
plotResultsWithOutComparison(values.controlNeuralCommandsLeft, values.time, ...
    ["command1", "command2", "command3", "command4", "command5", "command6"], ["Left Synergy" "Activations"]);
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