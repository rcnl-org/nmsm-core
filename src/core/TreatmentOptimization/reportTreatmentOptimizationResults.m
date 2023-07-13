% This function is part of the NMSM Pipeline, see file for full license.
%
% This function plots the results from all three treatment optimization
% tools (tracking, verification, and design optimization).
%
% (struct, struct) -> (None)
% Plots results from treatment optimization
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

function reportTreatmentOptimizationResults(output, inputs)
if isfield(inputs, 'userDefinedVariables')
    for i = 1:length(inputs.userDefinedVariables)
        parameterResults = scaleToOriginal( ...
            output.solution.phase.parameter(i, 1), ...
            inputs.userDefinedVariables{i}.upper_bounds, ...
            inputs.userDefinedVariables{i}.lower_bounds)
    end
end
values = getTreatmentOptimizationValueStruct(output.solution.phase, inputs);
if strcmp(inputs.controllerType, 'synergy_driven')
    % plot Muscle Activations
    plotMuscleActivations(output.muscleActivations, values.time, ...
        inputs.experimentalMuscleActivations, inputs.experimentalTime, ...
        inputs.muscleLabels);
    % plot synergy activations
    synergyTitles = {};
    for i = 1 : inputs.numSynergies
        synergyTitles{end + 1} = strcat('synergy activation', num2str(i));
    end
    plotResultsWithOutComparison(values.controlSynergyActivations, values.time, ...
        synergyTitles, ["Synergy" "Activations"]);
else
    % plot torque controls
    plotResultsWithOutComparison(values.controlTorques, values.time, ...
        inputs.controlTorqueNames, ["Torque" "Controls"]);
end
% plot external torque controls
if isfield(inputs, 'enableExternalTorqueControl')
    if inputs.enableExternalTorqueControl
        plotResultsWithOutComparison(values.externalTorqueControls, values.time, ...
            inputs.externalControlTorqueNames, ["External" "Torque Controls"]);
    end
end
% plot joint angles
plotResultsWithComparison(values.statePositions, values.time, ...
    inputs.experimentalJointAngles, inputs.experimentalTime, ...
    strcat(inputs.coordinateNames, ' [rad]'), ["Joint" "Angles [rad]"]);
% plot joint moments
plotResultsWithComparison(output.inverseDynamicMoments, values.time, ...
    inputs.experimentalJointMoments, inputs.experimentalTime, ...
    strcat(inputs.inverseDynamicMomentLabels, ' [Nm]'), ["Joint" "Moments"]);
% plot ground reactions
for i = 1:length(inputs.contactSurfaces)
    plotResultsWithComparison(output.groundReactionsLab.forces{i}, values.time, ...
        inputs.contactSurfaces{i}.experimentalGroundReactionForces, inputs.experimentalTime, ...
        ["GRFx", "GRFy", "GRFz"], ["Ground" "Reaction Forces"]);
    plotResultsWithComparison(output.groundReactionsLab.moments{i}, values.time, ...
        inputs.contactSurfaces{i}.experimentalGroundReactionMoments, inputs.experimentalTime, ...
        ["GRTx", "GRTy", "GRTz"], ["Ground" "Reaction Moments"]);
end

% if strcmp(inputs.toolName, 'DesignOptimization')
%     gait = input('Print gait specific measurements (yes or no): ', 's');
%     if strcmp(gait, 'yes')
%         reportingGaitSpecificMeasurements(values, solution, inputs);
%     end
% end
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
