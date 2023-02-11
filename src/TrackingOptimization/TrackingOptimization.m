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

function [output, inputs] = TrackingOptimization(inputs, params)
pointKinematics(inputs.model);
inverseDynamics(inputs.model);
inputs = getDesignVariableInputBounds(inputs);
output = computeTrackingOptimizationMainFunction(inputs, params);
end

function inputs = getDesignVariableInputBounds(inputs)
inputs.maxTime = max(inputs.experimentalTime);
inputs.minTime = min(inputs.experimentalTime);

maxStatePositions = max(inputs.experimentalJointAngles) + ...
    inputs.statePositionsMultiple * range(inputs.experimentalJointAngles);
minStatePositions = min(inputs.experimentalJointAngles) - ...
    inputs.statePositionsMultiple * range(inputs.experimentalJointAngles);
maxStateVelocities = max(inputs.experimentalJointVelocities) + ...
    inputs.stateVelocitiesMultiple * range(inputs.experimentalJointVelocities);
minStateVelocities = min(inputs.experimentalJointVelocities) - ...
    inputs.stateVelocitiesMultiple * range(inputs.experimentalJointVelocities);
maxStateAccelerations = max(inputs.experimentalJointAccelerations) + ...
    inputs.stateAccelerationsMultiple * range(inputs.experimentalJointAccelerations);
minStateAccelerations = min(inputs.experimentalJointAccelerations) - ...
    inputs.stateAccelerationsMultiple * range(inputs.experimentalJointAccelerations);

inputs.maxState = [maxStatePositions maxStateVelocities maxStateAccelerations];
inputs.minState = [minStatePositions minStateVelocities minStateAccelerations];

maxControlJerks = max(inputs.experimentalJointJerks) + ...
    inputs.controlJerksMultiple * range(inputs.experimentalJointJerks);
minControlJerks = min(inputs.experimentalJointJerks) - ...
    inputs.controlJerksMultiple * range(inputs.experimentalJointJerks);

maxControlNeuralCommands = inputs.maxControlNeuralCommands * ...
    ones(1, inputs.numSynergies);
inputs.maxControl = [maxControlJerks maxControlNeuralCommands];
inputs.minControl = [minControlJerks zeros(1, inputs.numSynergies)];

inputs.maxParameter = inputs.maxParameterSynergyWeights * ...
    ones(1, inputs.numSynergyWeights);
inputs.minParameter = zeros(1, inputs.numSynergyWeights);
end