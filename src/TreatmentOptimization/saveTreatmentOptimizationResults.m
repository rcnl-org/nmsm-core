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
saveExperimentalGroundReactions(inputs, inputs.resultsDirectory);

stateLabels = inputs.statesCoordinateNames;
for i = 1 : length(inputs.statesCoordinateNames)
    stateLabels{end + 1} = strcat(inputs.statesCoordinateNames{i}, '_u');
end
% for i = 1 : length(inputs.statesCoordinateNames)
%     stateLabels{end + 1} = strcat(inputs.statesCoordinateNames{i}, '_dudt');
% end
data = splineToExperimentalTime(values.time, [values.statePositions ...
    values.stateVelocities], inputs.experimentalTime);
writeToSto(stateLabels, inputs.experimentalTime, data, ...
    fullfile(inputs.resultsDirectory, strcat(inputs.trialName, "_states.sto")));
accelerations = splineToExperimentalTime(values.time, ...
    values.controlAccelerations, inputs.experimentalTime);
writeToSto(inputs.statesCoordinateNames, inputs.experimentalTime, accelerations, ...
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
    controls = splineToExperimentalTime( ...
        values.time, values.controlSynergyActivations, inputs.experimentalTime);
    writeToSto(controlLabels, inputs.experimentalTime, controls, ...
        fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_synergyCommands.sto")));
end
if ~isempty(valueOrAlternate(inputs, "torqueControllerCoordinateNames", []))
    controlLabels = {};
    for i = 1 : length(inputs.torqueControllerCoordinateNames)
        controlLabels{end + 1} = inputs.torqueControllerCoordinateNames{i};
    end
    controls = splineToExperimentalTime( ...
        values.time, values.torqueControls, inputs.experimentalTime);
    writeToSto(controlLabels, inputs.experimentalTime, controls, ...
        fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_torqueControls.sto")));
end
if strcmp(inputs.controllerType, 'synergy')
    writeToSto(inputs.muscleLabels, linspace(1, inputs.numSynergies, ...
        inputs.numSynergies), [values.synergyWeights], ...
        fullfile(inputs.resultsDirectory, "synergyWeights.sto"));
    activations = splineToExperimentalTime(values.time, ...
        solution.muscleActivations, inputs.experimentalTime);
    writeToSto(inputs.muscleLabels, inputs.experimentalTime, ...
        activations, fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_combinedActivations.sto")));
end
delete(inputs.mexModel);
end

function saveInverseKinematicsResults(inputs, values, outputDirectory)
if ~exist(fullfile(outputDirectory, "IKData"), "dir")
    mkdir(fullfile(outputDirectory, "IKData"))
end
positions = splineToExperimentalTime(values.time, ...
    values.positions, inputs.experimentalTime);
writeToSto(inputs.coordinateNames, inputs.experimentalTime, positions, ...
    fullfile(outputDirectory, "IKData", strcat(inputs.trialName, ".sto")));
end

function saveInverseDynamicsResults(solution, inputs, values, outputDirectory)
if ~exist(fullfile(outputDirectory, "IDData"), "dir")
    mkdir(fullfile(outputDirectory, "IDData"))
end
moments = splineToExperimentalTime(values.time, ...
    solution.inverseDynamicsMoments, inputs.experimentalTime);
writeToSto(inputs.inverseDynamicsMomentLabels, inputs.experimentalTime, ...
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
        values.positions, values.velocities, ...
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
    splinedGroundContactData = splineToExperimentalTime(values.time, ...
        groundContactData, inputs.experimentalTime);
    writeToSto(groundContactLabels, inputs.experimentalTime, splinedGroundContactData, ...
    fullfile(inputs.resultsDirectory, "GRFData", ...
        strcat(inputs.trialName, ".sto")));
end
end

function saveExperimentalGroundReactions(inputs, resultsDirectory)
if isempty(inputs.contactSurfaces)
    return
end
columnLabels = strings(1, 9*numel(inputs.contactSurfaces));
dataToSave = zeros(size(inputs.experimentalTime, 1), numel(columnLabels));
for surface = 1 : numel(inputs.contactSurfaces)
    contactSurface = inputs.contactSurfaces{surface};
    columnLabels((surface-1)*9+1:surface*9) = ...
        [contactSurface.forceColumns', ...
        contactSurface.momentColumns', ...
        contactSurface.electricalCenterColumns'];
    dataToSave(:, (surface-1)*9+1:surface*9) = ...
        [contactSurface.experimentalGroundReactionForces, ...
        contactSurface.experimentalGroundReactionMoments, ...
        contactSurface.electricalCenter];    
end
writeToSto(columnLabels, inputs.experimentalTime, dataToSave, ...
    fullfile(resultsDirectory, ...
        strcat(inputs.trialName, "_replacedExperimentalGroundReactions.sto")));
end