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

function computeTrackingOptimizationContinuousFunction(inputs, params)

load('inputData.mat')
params.modelName = 'optModel_GPOPS.osim';
pointKinematics(params.modelName);
inverseDynamics(params.modelName);

% persistent experimentalJointAngles experimentalJointMoments ...
%     experimentalMuscleActivations experimentalRightGroundReactionForces ...
%     experimentalLeftGroundReactionForces

values = getTrackingOptimizationValueStruct(inputs, params);
assignPersistentVariable(params, values.time);
phaseout = calcTrackingOptimizationModeledValues(values, params);
phaseout.dynamics = calcTrackingOptimizationDynamicsConstraint(values, params);
phaseout.path = calcTrackingOptimizationPathConstraint(phaseout, params);
phaseout.integrand = calcTrackingOptimizationIntegrand(values, params, ...
    phaseout);
end
function values = getTrackingOptimizationValueStruct(input, params)

values.time = scaleToOriginal(input.time, params.maxTime, ...
    params.minTime);
values.synergyWeights = scaleToOriginal(input.parameter(1,:), ...
    params.maxParameter, params.minParameter);
values.synergyWeights = reshape(values.synergyWeights, ...
    params.numRightSynergies + params.numLeftSynergies, []);
state = scaleToOriginal(input.state, ones(length(values.time), 1) .* ...
    params.maxState, ones(length(values.time), 1) .* params.minState);
control = scaleToOriginal(input.control, ones(length(values.time), 1) .* ...
    params.maxControl, ones(length(values.time), 1) .* params.minControl);
values.statePositions = getCorrectStates(state, 1, params.numCoordinates);
values.stateVelocities = getCorrectStates(state, 2, params.numCoordinates);
values.stateAccelerations = getCorrectStates(state, 3, params.numCoordinates);
values.controlJerks = control(:, 1 : params.numCoordinates);
values.controlNeuralCommandsRight = control(:, params.numCoordinates + 1 : ...
    params.numCoordinates + params.numRightSynergies);
values.controlNeuralCommandsLeft = control(:, params.numCoordinates + ...
    params.numRightSynergies + 1 : end);
end
% function assignPersistentVariable(params, time)
% 
% if ~exist('experimentalJointAngles', 'var') || ...
%         size(experimentalJointAngles, 1) ~= length(time)
% assignin('caller', 'experimentalJointAngles', ...
%     fnval(params.splineJointAngles, time)');
% assignin('caller', 'experimentalJointMoments', ...
%     fnval(params.splineJointMoments, time)');
% assignin('caller', 'experimentalMuscleActivations', ...
%     fnval(params.splineMuscleActivations, time)');
% assignin('caller', 'experimentalRightGroundReactionForces', ...
%     fnval(params.splineRightGroundReactionForces, time)');
% assignin('caller', 'experimentalLeftGroundReactionForces', ...
%     fnval(params.splineLeftGroundReactionForces, time)');
% end
% end
function output = getCorrectStates(state, index, numCoordinates)

startIndex = (numCoordinates * (index - 1)) + 1;
endIndex = numCoordinates * index;
output = state(:, startIndex:endIndex);
end
function value = scaleToOriginal(value, maximum, minimum)

value = value .* (maximum - minimum) + (maximum + minimum) / 2;
end