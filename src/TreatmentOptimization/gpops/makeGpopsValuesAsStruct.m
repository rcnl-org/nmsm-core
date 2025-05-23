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
[values.positions, values.velocities] = recombineFullState(values, inputs);
values.accelerations = recombineFullAccelerations(values, inputs);
if strcmp(inputs.controllerType, 'synergy')
    values.controlSynergyActivations = control(:, ...
        length(inputs.statesCoordinateNames) + 1 : ...
        length(inputs.statesCoordinateNames) + inputs.numSynergies);
end
values.torqueControls = control(:, ...
    length(inputs.statesCoordinateNames) + 1 + inputs.numSynergies : ...
    length(inputs.statesCoordinateNames) + inputs.numSynergies + ...
    length(inputs.torqueControllerCoordinateNames));

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
elseif size(values.time) == [2, 1]
    positions = inputs.experimentalJointAngles([1 end], :);
    velocities = inputs.experimentalJointVelocities([1 end], :);
else
    positions = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.coordinateNames, values.time);
    velocities = evaluateGcvSplines(inputs.splineJointAngles, ...
        inputs.coordinateNames, values.time, 1);
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
accelerations(:, inputs.statesCoordinateIndices) = ...
    values.controlAccelerations;
end
