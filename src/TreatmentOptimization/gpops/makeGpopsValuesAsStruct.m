% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the raw values from gpops and turns them into a
% struct that can be interacted with more easily during calculations
%
% (struct, struct) -> (struct)
%

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

function values = makeGpopsValuesAsStruct(phase, inputs)
values.time = scaleToOriginal(phase.time, inputs.maxTime, ...
    inputs.minTime);
state = scaleToOriginal(phase.state, ones(size(phase.state, 1), 1) .* ...
    inputs.maxState, ones(size(phase.state, 1), 1) .* inputs.minState);
control = scaleToOriginal(phase.control, ones(size(phase.control, 1), 1) .* ...
    inputs.maxControl, ones(size(phase.control, 1), 1) .* inputs.minControl);
values.statePositions = getCorrectStates( ...
    state, 1, length(inputs.statesCoordinateNames));
values.stateVelocities = getCorrectStates( ...
    state, 2, length(inputs.statesCoordinateNames));
values.controlAccelerations = control(:, 1 : length(inputs.statesCoordinateNames));
if inputs.useDeviationKinematics
    [values.statePositions, values.stateVelocities, ...
        values.controlAccelerations] = ...
        applyDeviationKinematics(values, inputs);
end
[values.positions, values.velocities] = recombineFullState(values, inputs);
values.accelerations = recombineFullAccelerations(values, inputs);
if strcmp(inputs.controllerType, 'synergy')
    values.controlSynergyActivations = control(:, ...
        length(inputs.statesCoordinateNames) + 1 : ...
        length(inputs.statesCoordinateNames) + inputs.numSynergies);
    if inputs.useDeviationControls
        values.controlSynergyActivations = ...
            applyDeviationSynergyControls(values, inputs);
    end
end
values.torqueControls = control(:, ...
    length(inputs.statesCoordinateNames) + 1 + inputs.numSynergies : ...
    length(inputs.statesCoordinateNames) + inputs.numSynergies + ...
    length(inputs.torqueControllerCoordinateNames));
if inputs.useDeviationControls && ~isempty(values.torqueControls)
    values.torqueControls = applyDeviationTorqueControls(values, inputs);
end

if strcmp(inputs.toolName, "TrackingOptimization")
    if strcmp(inputs.controllerType, 'synergy')
        values.synergyWeights = inputs.synergyWeights;
        if inputs.optimizeSynergyVectors
            parameters = scaleToOriginal(phase.parameter(1,:), ...
                inputs.maxParameter, inputs.minParameter);
            values.synergyWeights(inputs.synergyWeightsIndices) = ...
                parameters(1 : length(inputs.synergyWeightsIndices));
        end
    end
end
if strcmp(inputs.toolName, "VerificationOptimization")
    if strcmp(inputs.controllerType, 'synergy')
        values.synergyWeights = inputs.synergyWeights;
    end
end
if strcmp(inputs.toolName, "DesignOptimization")
    counter = 1;
    if strcmp(inputs.controllerType, 'synergy')
        values.synergyWeights = inputs.synergyWeights;
        if inputs.optimizeSynergyVectors
            parameters = scaleToOriginal(phase.parameter(1,:), ...
                inputs.maxParameter, inputs.minParameter);
            values.synergyWeights(inputs.synergyWeightsIndices) = ...
                parameters(1 : length(inputs.synergyWeightsIndices));
            counter = length(inputs.synergyWeightsIndices) + 1;
        end
    end
    if isfield(inputs, 'userDefinedVariables') && ...
            ~isempty(inputs.userDefinedVariables)
        parameters = scaleToOriginal(phase.parameter(1,:), ...
            inputs.maxParameter, inputs.minParameter);
        for i = 1:length(inputs.userDefinedVariables)
            values.parameters.(inputs.userDefinedVariables{i}.type) ...
                = parameters(counter : counter + ...
                length(inputs.userDefinedVariables{i}.initial_values) - 1);
            counter = counter + ...
                length(inputs.userDefinedVariables{i}.initial_values);
        end
    end
end
end

function [positions, velocities] = recombineFullState( ...
    values, inputs)
if size(values.time) == size(inputs.collocationTimeOriginal)
    positions = inputs.splinedJointAngles;
    velocities = inputs.splinedJointSpeeds;
elseif size(values.time) == size(inputs.collocationTimeOriginal) + [1, 0]
    positions = inputs.splinedJointAngles;
    velocities = inputs.splinedJointSpeeds;
    positions(end+1, :) = inputs.experimentalJointAngles(end, :);
    velocities(end+1, :) = inputs.experimentalJointVelocities(end, :);
else
    positions = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.coordinateNames, values.time);
    velocities = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.coordinateNames, values.time, 1);
end
for i = 1:length(inputs.coordinateNames)
    index = find(ismember( ...
        inputs.statesCoordinateNames, inputs.coordinateNames{i}));
    if ~isempty(index)
        positions(:, i) = values.statePositions(:, index);
        velocities(:, i) = values.stateVelocities(:, index);
    end
end
end

function accelerations = recombineFullAccelerations(values, inputs)
if size(values.time) == size(inputs.collocationTimeOriginal)
    accelerations = inputs.splinedJointAccelerations;
elseif size(values.time) == size(inputs.collocationTimeOriginal) + [1, 0]
    accelerations = inputs.splinedJointAccelerations;
    accelerations(end+1, :) = inputs.experimentalJointAccelerations(end, :);
else
    accelerations = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.coordinateNames, values.time, 2);
end
for i = 1:length(inputs.coordinateNames)
    index = find(ismember( ...
        inputs.statesCoordinateNames, inputs.coordinateNames{i}));
    if ~isempty(index)
        accelerations(:, i) = values.controlAccelerations(:, index);
    end
end
end

% This function should only be used with deviation spline kinematics
function [statePositions, stateVelocities, controlAccelerations] = ...
        applyDeviationKinematics(values, inputs)
indices = find(ismember(inputs.coordinateNamesStrings, ...
    inputs.statesCoordinateNames));

if size(values.time) == size(inputs.collocationTimeOriginal)
    statePositions = values.statePositions + ...
        inputs.splinedJointAngles(:, indices);
    stateVelocities = values.stateVelocities + ...
        inputs.splinedJointSpeeds(:, indices);
    controlAccelerations = values.controlAccelerations + ...
        inputs.splinedJointAccelerations(:, indices);
elseif size(values.time) == size(inputs.collocationTimeOriginal) + [1, 0]
    statePositions = values.statePositions;
    stateVelocities = values.stateVelocities;
    controlAccelerations = values.controlAccelerations;
    statePositions(1:end-1, :) = statePositions(1:end-1, :) + ...
        inputs.splinedJointAngles(:, indices);
    stateVelocities(1:end-1, :) = stateVelocities(1:end-1, :) + ...
        inputs.splinedJointSpeeds(:, indices);
    controlAccelerations(1:end-1, :) = controlAccelerations(1:end-1, :) + ...
        inputs.splinedJointAccelerations(:, indices);
    statePositions(end, :) = statePositions(end, :) + ...
        inputs.initialJointAngles(end, indices);
    stateVelocities(end, :) = stateVelocities(end, :) + ...
        inputs.initialJointVelocities(end, indices);
    controlAccelerations(end, :) = controlAccelerations(end, :) + ...
        inputs.initialJointAccelerations(end, indices);
else
    statePositions = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.statesCoordinateNames, values.time) + values.statePositions;
    stateVelocities = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.statesCoordinateNames, values.time, 1) + values.stateVelocities;
    controlAccelerations = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.statesCoordinateNames, values.time, 2) + values.controlAccelerations;
end
end

% This function should only be used with deviation spline synergy controls
function controlSynergyActivations = ...
        applyDeviationSynergyControls(values, inputs)
if size(values.time) == size(inputs.collocationTimeOriginal)
    controlSynergyActivations = values.controlSynergyActivations + ...
        inputs.splinedSynergyActivations;
elseif size(values.time) == size(inputs.collocationTimeOriginal) + [1, 0]
    controlSynergyActivations = values.controlSynergyActivations;
    controlSynergyActivations(1:end-1, :) = ...
        controlSynergyActivations(1:end-1, :) + ...
        inputs.splinedSynergyActivations;
    controlSynergyActivations(end, :) = ...
        controlSynergyActivations(end, :) + ...
        inputs.initialSynergyControls(end, :);
else
    controlSynergyActivations = evaluateGcvSplines(inputs.splineSynergyActivations, ...
        inputs.synergyLabels, values.time) + values.controlSynergyActivations;
end
end

% This function should only be used with deviation spline torque controls
function torqueControls = ...
        applyDeviationTorqueControls(values, inputs)
if size(values.time) == size(inputs.collocationTimeOriginal)
    torqueControls = values.torqueControls + inputs.splinedTorqueControls;
elseif size(values.time) == size(inputs.collocationTimeOriginal) + [1, 0]
    torqueControls = values.torqueControls;
    torqueControls(1:end-1, :) = torqueControls(1:end-1, :) + ...
        inputs.splinedTorqueControls;
    torqueControls(end, :) = torqueControls(end, :) + ...
        inputs.initialTorqueControls(end, :);
else
    torqueControls = evaluateGcvSplines(inputs.splineTorqueControls, ...
        inputs.initialTorqueControlsLabels, values.time) + values.torqueControls;
end
end
