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
values.stateAccelerations = getCorrectStates( ...
    state, 3, length(inputs.statesCoordinateNames));
values.controlJerks = control(:, 1 : length(inputs.statesCoordinateNames));
[values.positions, values.velocities, ...
    values.accelerations] = recombineFullState(values, inputs);
if strcmp(inputs.controllerType, 'torque')
    values.controlTorques = control(:, inputs.numCoordinates + 1 : ...
        inputs.numCoordinates + length(inputs.torqueControllerCoordinateNames));
else
    values.controlSynergyActivations = control(:, ...
        length(inputs.statesCoordinateNames) + 1 : ...
        length(inputs.statesCoordinateNames) + inputs.numSynergies);
end

if strcmp(inputs.toolName, "TrackingOptimization")
    if strcmp(inputs.controllerType, 'synergy')
        if inputs.optimizeSynergyVectors
            synergyWeights = scaleToOriginal(phase.parameter(1,:), ...
                inputs.maxParameter, inputs.minParameter);
            values.synergyWeights = synergyWeights;
        else
            values.synergyWeights = inputs.synergyWeights;
        end
    end
end
if strcmp(inputs.toolName, "VerificationOptimization")
    if strcmp(inputs.controllerType, 'synergy')
        values.synergyWeights = inputs.synergyWeights;
    end
end
if strcmp(inputs.toolName, "DesignOptimization")
    numParameters = 0;
    if strcmp(inputs.controllerType, 'synergy')
        if inputs.optimizeSynergyVectors
            values.synergyWeights = scaleToOriginal(phase.parameter(1, ...
                1 : inputs.numSynergyWeights), ...
                inputs.maxParameter, inputs.minParameter);
            numParameters = inputs.numSynergyWeights;
        else
            values.synergyWeights = inputs.synergyWeights;
        end
        %         if inputs.splineSynergyActivations.dim > 1
        %             values.controlSynergyActivations = ...
        %                 fnval(inputs.splineSynergyActivations, values.time)';
        %         else
        %             values.controlSynergyActivations = ...
        %                 fnval(inputs.splineSynergyActivations, values.time);
        %         end
        %         if inputs.enableExternalTorqueControl
        %             controls = scaleToOriginal(phase.control, ones(size( ...
        %                 phase.control, 1), 1) .* inputs.maxControl, ...
        %                 ones(size(phase.control, 1), 1) .* inputs.minControl);
        %             values.externalTorqueControls = controls(:, inputs.numCoordinates + ...
        %                 inputs.numSynergies + 1 : end);
        %         end
        %     else
        %         if isfield(inputs, "enableExternalTorqueControl") && ...
        %                 inputs.enableExternalTorqueControl
        %             controls = scaleToOriginal(phase.control, ones(size( ...
        %                 phase.control, 1), 1) .* inputs.maxControl, ...
        %                 ones(size(phase.control, 1), 1) .* inputs.minControl);
        %             values.externalTorqueControls = controls(:, inputs.numCoordinates + ...
        %                 length(inputs.torqueControllerCoordinateNames) + 1 : end);
        %         end
    end
    if isfield(inputs, 'userDefinedVariables')
        counter = 1;
        for i = 1:length(inputs.userDefinedVariables)
            numParameters = length(inputs.userDefinedVariables{i}.initial_values);
            values.parameters.(inputs.userDefinedVariables{i}.type) ...
                = scaleToOriginal( ...
                phase.parameter(counter : counter + numParameters - 1), ...
                inputs.userDefinedVariables{i}.upper_bounds, ...
                inputs.userDefinedVariables{i}.lower_bounds);
            counter = counter + numParameters;
        end
    end
end
end

function [positions, velocities, accelerations] = recombineFullState( ...
    values, inputs)
positions = fnval(inputs.splineJointAngles, values.time)';
velocities = fnval(inputs.splineJointVelocities, values.time)';
accelerations = fnval(inputs.splineJointAccelerations, values.time)';
if length(inputs.statesCoordinateNames) == 1
    positions = positions';
    velocities = velocities';
    accelerations = accelerations';
end
for i = 1:length(inputs.coordinateNames)
    index = find(ismember( ...
        inputs.statesCoordinateNames, inputs.coordinateNames{i}));
    if ~isempty(index)
        positions(:, i) = values.statePositions(:, index);
        velocities(:, i) = values.stateVelocities(:, index);
        accelerations(:, i) = values.stateAccelerations(:, index);
    end
end
end
