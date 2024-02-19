% This function is part of the NMSM Pipeline, see file for full license.
%
% This function saves and prints the unscaled results from all
% treatment optimization modules (tracking, verification, and design
% optimization.
%
% (struct, struct) -> (None)
% Prints treatment optimization results

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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

function saveTreatmentOptimizationResults(solution, inputs, values)
if ~exist(inputs.resultsDirectory, 'dir')
    mkdir(inputs.resultsDirectory)
end

saveInverseKinematicsResults(inputs, values, inputs.resultsDirectory);
saveInverseDynamicsResults(solution, inputs, values, inputs.resultsDirectory);
saveGroundReactionResults(solution, inputs, values, inputs.resultsDirectory);

stateLabels = inputs.statesCoordinateNames;
for i = 1 : length(inputs.statesCoordinateNames)
    stateLabels{end + 1} = strcat(inputs.statesCoordinateNames{i}, '_u');
end
% for i = 1 : length(inputs.statesCoordinateNames)
%     stateLabels{end + 1} = strcat(inputs.statesCoordinateNames{i}, '_dudt');
% end
[time, data] = splineToEvenlySpaced(values.time, [values.statePositions ...
    values.stateVelocities]);
writeToSto(stateLabels, time, data, ...
    fullfile(inputs.resultsDirectory, strcat(inputs.trialName, "_states.sto")));
[time, accelerations] = splineToEvenlySpaced(values.time, values.controlAccelerations);
writeToSto(inputs.statesCoordinateNames, time, accelerations, ...
    fullfile(inputs.resultsDirectory, strcat(inputs.trialName, "_accelerations.sto")));
if strcmp(inputs.controllerType, 'synergy')
    controlLabels = {};
    for i = 1 : length(inputs.osimx.synergyGroups)
        for j = 1 : inputs.osimx.synergyGroups{i}.numSynergies
            controlLabels{end + 1} = convertStringsToChars( ...
                strcat(inputs.osimx.synergyGroups{i}.muscleGroupName, ...
                "_", num2str(j)));
        end
    end
    [time, controls] = splineToEvenlySpaced( ...
        values.time, values.controlSynergyActivations);
    writeToSto(controlLabels, time, controls, ...
        fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_synergyCommands.sto")));
end
if ~isempty(valueOrAlternate(inputs, "torqueControllerCoordinateNames", []))
    controlLabels = {};
    for i = 1 : length(inputs.torqueControllerCoordinateNames)
        controlLabels{end + 1} = inputs.torqueControllerCoordinateNames{i};
    end
    [time, controls] = splineToEvenlySpaced( ...
        values.time, values.torqueControls);
    writeToSto(controlLabels, time, controls, ...
        fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_torqueControls.sto")));
end
if strcmp(inputs.controllerType, 'synergy')
    writeToSto(inputs.muscleLabels, linspace(1, inputs.numSynergies, ...
        inputs.numSynergies), [values.synergyWeights], ...
        fullfile(inputs.resultsDirectory, "synergyWeights.sto"));
    [time, activations] = splineToEvenlySpaced(values.time, ...
        solution.muscleActivations);
    writeToSto(inputs.muscleLabels, time, ...
        activations, fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_combinedActivations.sto")));
end
delete(inputs.mexModel);
end

function saveInverseKinematicsResults(inputs, values, outputDirectory)
if ~exist(fullfile(outputDirectory, "IKData"), "dir")
    mkdir(fullfile(outputDirectory, "IKData"))
end
[time, positions] = splineToEvenlySpaced(values.time, values.positions);
writeToSto(inputs.coordinateNames, time, positions, ...
    fullfile(outputDirectory, "IKData", strcat(inputs.trialName, ".sto")));
end

function saveInverseDynamicsResults(solution, inputs, values, outputDirectory)
if ~exist(fullfile(outputDirectory, "IDData"), "dir")
    mkdir(fullfile(outputDirectory, "IDData"))
end
[time, moments] = splineToEvenlySpaced(values.time, ...
    solution.inverseDynamicsMoments);
writeToSto(inputs.inverseDynamicsMomentLabels, time, ...
    moments, fullfile(outputDirectory, "IDData", ...
    strcat(inputs.trialName, ".sto")));
end

function saveGroundReactionResults(solution, inputs, values, outputDirectory)
groundContactLabels = [];
groundContactData = [];
for i = 1:length(inputs.contactSurfaces)
    groundContactLabels = cat(2, groundContactLabels, ...
        [inputs.contactSurfaces{i}.forceColumns, ...
        inputs.contactSurfaces{i}.momentColumns, ...
        inputs.contactSurfaces{i}.electricalCenterColumns]);
    midfootSuperiorLocation = pointKinematics(values.time, ...
        values.statePositions, values.stateVelocities, ...
        inputs.contactSurfaces{i}.midfootSuperiorPointOnBody, ...
        inputs.contactSurfaces{i}.midfootSuperiorBody, inputs.modelFileName, ...
        inputs.coordinateNames);
    midfootSuperiorLocation(:, 2) = inputs.contactSurfaces{i}.restingSpringLength;
    groundContactData = [groundContactData, ...
        solution.groundReactionsLab.forces{i}, ...
        solution.groundReactionsLab.moments{i}, ...
        midfootSuperiorLocation];
end
if ~isempty(groundContactData)
    if ~exist(fullfile(outputDirectory, "GRFData"), "dir")
        mkdir(fullfile(outputDirectory, "GRFData"))
    end
    [time, splinedGroundContactData] = splineToEvenlySpaced(values.time, ...
        groundContactData);
    writeToSto(groundContactLabels, time, splinedGroundContactData, ...
    fullfile(inputs.resultsDirectory, "GRFData", ...
        strcat(inputs.trialName, ".sto")));
end
end
