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
if inputs.useJerk
    for i = 1 : length(inputs.statesCoordinateNames)
        stateLabels{end + 1} = strcat(inputs.statesCoordinateNames{i}, '_dudt');
    end
    [time, data] = splineToEvenlySpaced(values.time, [values.statePositions ...
        values.stateVelocities values.controlAccelerations], length(inputs.experimentalTime));
else
    [time, data] = splineToEvenlySpaced(values.time, [values.statePositions ...
        values.stateVelocities], length(inputs.experimentalTime));
end
writeToSto(stateLabels, time, data, ...
    fullfile(inputs.resultsDirectory, strcat(inputs.trialName, "_states.sto")));
[time, accelerations] = splineToEvenlySpaced(values.time, ...
    values.controlAccelerations, length(inputs.experimentalTime));
writeToSto(inputs.statesCoordinateNames, time, accelerations, ...
    fullfile(inputs.resultsDirectory, strcat(inputs.trialName, "_accelerations.sto")));
if inputs.useJerk
    [time, jerks] = splineToEvenlySpaced(values.time, ...
        values.controlJerks, length(inputs.experimentalTime));
    writeToSto(inputs.statesCoordinateNames, time, jerks, ...
        fullfile(inputs.resultsDirectory, strcat(inputs.trialName, "_jerks.sto")));
end
if inputs.controllerTypes(4)
    [time, controls] = splineToEvenlySpaced(values.time, ...
        values.userDefinedControls, length(inputs.experimentalTime));
    writeToSto(inputs.userDefinedControlLabels, time, controls, ...
        fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_userDefinedControls.sto")));
end
if inputs.controllerTypes(3)
    [time, controls] = splineToEvenlySpaced(values.time, ...
        values.controlMuscleActivations, length(inputs.experimentalTime));
    writeToSto(inputs.individualMuscleNames, time, controls, ...
        fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_muscleControls.sto")));
end
if inputs.controllerTypes(2)
    controlLabels = {};
    for i = 1 : length(inputs.osimx.synergyGroups)
        for j = 1 : inputs.osimx.synergyGroups{i}.numSynergies
            controlLabels{end + 1} = convertStringsToChars( ...
                strcat(inputs.osimx.synergyGroups{i}.muscleGroupName, ...
                "_", num2str(j)));
        end
    end
    [time, controls] = splineToEvenlySpaced(values.time, ...
        values.controlSynergyActivations, length(inputs.experimentalTime));
    writeToSto(controlLabels, time, controls, ...
        fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_synergyCommands.sto")));
end
if ~isempty(valueOrAlternate(inputs, "torqueControllerCoordinateNames", []))
    controlLabels = {};
    for i = 1 : length(inputs.torqueControllerCoordinateNames)
        controlLabels{end + 1} = inputs.torqueControllerCoordinateNames{i};
    end
    [time, controls] = splineToEvenlySpaced(values.time, values.torqueControls, ...
        length(inputs.experimentalTime));
    for i = 1:size(controls, 2)
inverseDynamicsIndex = find(strcmp(replace(replace(convertCharsToStrings(inputs.inverseDynamicsMomentLabels), '_moment', ''), '_force', ''), ...
    inputs.torqueControllerCoordinateNames(i)));
controls(end, i) = solution.inverseDynamicsMoments(end, inverseDynamicsIndex);
    end
    writeToSto(controlLabels, time, controls, ...
        fullfile(inputs.resultsDirectory, ...
        strcat(inputs.trialName, "_torqueControls.sto")));
end
if inputs.useControlDynamicsFilter
    if inputs.controllerTypes(4)
        [time, controls] = splineToEvenlySpaced(values.time, ...
            values.userDefinedControlDerivatives, length(inputs.experimentalTime));
        writeToSto(inputs.userDefinedControlLabels, time, controls, ...
            fullfile(inputs.resultsDirectory, ...
            strcat(inputs.trialName, "_userDefinedControlDerivatives.sto")));
    end
    if inputs.controllerTypes(3)
        [time, controls] = splineToEvenlySpaced(values.time, ...
            values.controlMuscleActivationDerivatives, length(inputs.experimentalTime));
        writeToSto(inputs.individualMuscleNames, time, controls, ...
            fullfile(inputs.resultsDirectory, ...
            strcat(inputs.trialName, "_muscleControlDerivatives.sto")));
    end
    if inputs.controllerTypes(2)
        controlLabels = {};
        for i = 1 : length(inputs.osimx.synergyGroups)
            for j = 1 : inputs.osimx.synergyGroups{i}.numSynergies
                controlLabels{end + 1} = convertStringsToChars( ...
                    strcat(inputs.osimx.synergyGroups{i}.muscleGroupName, ...
                    "_", num2str(j)));
            end
        end
        [time, controls] = splineToEvenlySpaced(values.time, ...
            values.controlSynergyActivationDerivatives, length(inputs.experimentalTime));
        writeToSto(controlLabels, time, controls, ...
            fullfile(inputs.resultsDirectory, ...
            strcat(inputs.trialName, "_synergyCommandDerivatives.sto")));
    end
    if ~isempty(valueOrAlternate(inputs, "torqueControllerCoordinateNames", []))
        controlLabels = {};
        for i = 1 : length(inputs.torqueControllerCoordinateNames)
            controlLabels{end + 1} = inputs.torqueControllerCoordinateNames{i};
        end
        [time, controls] = splineToEvenlySpaced(values.time, values.torqueControlDerivatives, ...
            length(inputs.experimentalTime));
        writeToSto(controlLabels, time, controls, ...
            fullfile(inputs.resultsDirectory, ...
            strcat(inputs.trialName, "_torqueControlDerivatives.sto")));
    end
end
if inputs.controllerTypes(2)
    writeToSto(inputs.synergyWeightsLabels, linspace(1, inputs.numSynergies, ...
        inputs.numSynergies), [values.synergyWeights], ...
        fullfile(inputs.resultsDirectory, "synergyWeights.sto"));
end
if any(inputs.controllerTypes(2:3))
    [time, activations] = splineToEvenlySpaced(values.time, ...
        solution.muscleActivations, length(inputs.experimentalTime));
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
[time, positions] = splineToEvenlySpaced(values.time, ...
    values.positions, length(inputs.experimentalTime));
writeToSto(inputs.coordinateNames, time, positions, ...
    fullfile(outputDirectory, "IKData", strcat(inputs.trialName, ".sto")));
end

function saveInverseDynamicsResults(solution, inputs, values, outputDirectory)
if ~exist(fullfile(outputDirectory, "IDData"), "dir")
    mkdir(fullfile(outputDirectory, "IDData"))
end
[time, moments] = splineToEvenlySpaced(values.time, ...
    solution.inverseDynamicsMoments, length(inputs.experimentalTime));
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
        inputs.contactSurfaces{i}.electricalCenterColumns, ...
        inputs.contactSurfaces{i}.momentColumns]);
    midfootSuperiorLocation = pointKinematics(values.time, ...
        values.positions, values.velocities, ...
        inputs.contactSurfaces{i}.midfootSuperiorPointOnBody, ...
        inputs.contactSurfaces{i}.midfootSuperiorBody, inputs.modelFileName, ...
        inputs.coordinateNames, inputs.osimVersion);
    midfootSuperiorLocation(:, 2) = inputs.contactSurfaces{i}.restingSpringLength;
    groundContactData = [groundContactData, ...
        solution.groundReactionsLab.forces{i}, ...
        midfootSuperiorLocation, ...
        solution.groundReactionsLab.moments{i}];
end
if ~isempty(groundContactData)
    if ~exist(fullfile(outputDirectory, "GRFData"), "dir")
        mkdir(fullfile(outputDirectory, "GRFData"))
    end
    [time, splinedGroundContactData] = splineToEvenlySpaced(values.time, ...
        groundContactData, length(inputs.experimentalTime));
    writeToSto(groundContactLabels, time, splinedGroundContactData, ...
        fullfile(inputs.resultsDirectory, "GRFData", ...
        strcat(inputs.trialName, ".sto")));
    dataCoP = zeros(size(splinedGroundContactData));
    for i = 1 : (size(dataCoP, 2) / 9)
        dataCoP(:, (9 * (i - 1)) + (1:9)) = ...
            makeCoPData(splinedGroundContactData(:, (9 * (i - 1)) + (1:9)));
    end
    writeToSto(groundContactLabels, time, dataCoP, ...
        fullfile(inputs.resultsDirectory, "GRFData", "CoP.sto"));
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