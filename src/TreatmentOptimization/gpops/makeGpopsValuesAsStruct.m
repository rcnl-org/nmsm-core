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
if isfield(phase, 'time')
    values.time = scaleToOriginal(phase.time, inputs.maxTime, ...
        inputs.minTime);
else
    values.time = inputs.collocationTimeOriginalWithEnd;
end
state = scaleToOriginal(phase.state, ones(size(phase.state, 1), 1) .* ...
    inputs.maxState, ones(size(phase.state, 1), 1) .* inputs.minState);
control = scaleToOriginal(phase.control, ones(size(phase.control, 1), 1) .* ...
    inputs.maxControl, ones(size(phase.control, 1), 1) .* inputs.minControl);
values.statePositions = getCorrectStates( ...
    state, 1, length(inputs.statesCoordinateNames));
values.stateVelocities = getCorrectStates( ...
    state, 2, length(inputs.statesCoordinateNames));
values.controlAccelerations = control(:, 1 : length(inputs.statesCoordinateNames));
[values.positions, values.velocities] = recombineFullState(values, inputs);
values.accelerations = recombineFullAccelerations(values, inputs);
controlIndex = length(inputs.statesCoordinateNames) + 1;
if inputs.controllerTypes(4)
    values.userDefinedControls = control(:, ...
        controlIndex : controlIndex - 1 + inputs.numUserDefinedControls);
    controlIndex = controlIndex + inputs.numUserDefinedControls;
end
if inputs.controllerTypes(3)
    values.controlMuscleActivations = control(:, ...
        controlIndex : controlIndex - 1 + inputs.numIndividualMuscles);
    controlIndex = controlIndex + inputs.numIndividualMuscles;
end
if inputs.controllerTypes(2)
    values.controlSynergyActivations = control(:, ...
        controlIndex : controlIndex - 1 + inputs.numSynergies);
    controlIndex = controlIndex + inputs.numSynergies;
end
values.torqueControls = control(:, ...
    controlIndex : ...
    controlIndex - 1 + length(inputs.torqueControllerCoordinateNames));

if strcmp(inputs.toolName, "TrackingOptimization")
    if inputs.controllerTypes(2)
        values.synergyWeights = inputs.synergyWeights;
        if inputs.optimizeSynergyVectors
            if isa(phase.parameter, 'casadi.MX')
                values.synergyWeights = casadi.MX.zeros( ...
                    size(inputs.synergyWeights, 1), ...
                    size(inputs.synergyWeights, 2));
            end
            parameters = scaleToOriginal(phase.parameter(1,:), ...
                inputs.maxParameter, inputs.minParameter);
            values.synergyWeights(inputs.synergyWeightsIndices) = ...
                parameters(1 : length(inputs.synergyWeightsIndices));
        end
    end
end
if strcmp(inputs.toolName, "VerificationOptimization")
    if inputs.controllerTypes(2)
        values.synergyWeights = inputs.synergyWeights;
    end
end
if strcmp(inputs.toolName, "DesignOptimization")
    counter = 1;
    if inputs.controllerTypes(2)
        values.synergyWeights = inputs.synergyWeights;
        if inputs.optimizeSynergyVectors
            if isa(phase.parameter, 'casadi.MX')
                values.synergyWeights = casadi.MX.zeros( ...
                    size(inputs.synergyWeights, 1), ...
                    size(inputs.synergyWeights, 2));
            end
            parameters = scaleToOriginal(phase.parameter(1,:), ...
                inputs.maxParameter, inputs.minParameter);
            values.synergyWeights(inputs.synergyWeightsIndices) = ...
                parameters(1 : length(inputs.synergyWeightsIndices));
            counter = length(inputs.synergyWeightsIndices) + 1;
        end
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
elseif size(values.time) == [2, 1]
    positions = inputs.experimentalJointAngles([1 end], :);
    velocities = inputs.experimentalJointVelocities([1 end], :);
else
    positions = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.coordinateNames, values.time);
    velocities = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.coordinateNames, values.time, 1);
end
if isa(values.statePositions, 'casadi.MX')
    positions = casadi.MX(positions);
    velocities = casadi.MX(velocities);
end
positions(:, inputs.statesCoordinateIndices) = values.statePositions;
velocities(:, inputs.statesCoordinateIndices) = values.stateVelocities;
end

function accelerations = recombineFullAccelerations(values, inputs)
if size(values.time) == size(inputs.collocationTimeOriginal)
    accelerations = inputs.splinedJointAccelerations;
elseif size(values.time) == size(inputs.collocationTimeOriginal) + [1, 0]
    accelerations = inputs.splinedJointAccelerations;
    accelerations(end+1, :) = inputs.experimentalJointAccelerations(end, :);
elseif size(values.time) == [2, 1]
    accelerations = inputs.experimentalJointAccelerations([1 end], :);
else
    accelerations = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.coordinateNames, values.time, 2);
end
if isa(values.controlAccelerations, 'casadi.MX')
    accelerations = casadi.MX(accelerations);
end
accelerations(:, inputs.statesCoordinateIndices) = ...
    values.controlAccelerations;
end
