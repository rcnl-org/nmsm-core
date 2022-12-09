% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function inputs = optimizeDeflectionAndSpringContants(inputs, params)
optimizerOptions = prepareOptimizerOptions(params); % Prepare optimizer

[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    ones(25, 7));
springHeights = zeros(length(inputs.springConstants), ...
    size(modeledJointPositions, 2));
[model, state] = Model(inputs.model);
for i=1:size(modeledJointPositions, 2)
    [model, state] = updateModelPositionAndVelocity(model, state, ...
        modeledJointPositions(:, i), ...
        modeledJointVelocities(:, i));
    for j = 1:length(inputs.springConstants)
        springHeights(i, j) = model.getMarkerSet().get("spring_marker_" + ...
            num2str(j)).getLocationInGround(state).get(1);
    end
end

restingSpringLength = lsqnonlin(@(restingSpringLength) calcDeflectionAndSpringConstantsCost(restingSpringLength, ...
    springHeights, inputs, params), inputs.restingSpringLength, 0, ...
    Inf, optimizerOptions);

% Solve for K values again here
verticalForce = inputs.experimentalGroundReactionForces(2, :)';
deflectionMatrix = zeros(length(verticalForce), length(inputs.springConstants));
for i = 1:length(verticalForce)
    for j = 1:length(inputs.springConstants)
        deflectionMatrix(i, j) = springHeights(i, j) - ...
            restingSpringLength - 0.001;
    end
end
springConstants = lsqnonneg(deflectionMatrix, verticalForce);

inputs.restingSpringLength = restingSpringLength;
inputs.springConstants = springConstants';
end

% (struct) -> (struct)
% Prepare params for outer optimizer for Kinematic Calibration
function output = prepareOptimizerOptions(params)
output = optimoptions('lsqnonlin', 'UseParallel', true);
% output.DiffMinChange = valueOrAlternate(params, 'diffMinChange', 1e-4);
% output.OptimalityTolerance = valueOrAlternate(params, ...
%     'optimalityTolerance', 1e-6);
% 1e-9 tolerances for levenberg-marquardt
% output.FunctionTolerance = valueOrAlternate(params, ...
%     'functionTolerance', 1e-9);
output.StepTolerance = valueOrAlternate(params, ...
    'stepTolerance', 1e-6);
output.MaxFunctionEvaluations = valueOrAlternate(params, ...
    'maxFunctionEvaluations', 3e6);
output.MaxIterations = valueOrAlternate(params, ...
    'MaxIterations', 1e3);
output.Display = valueOrAlternate(params, ...
    'display','iter');
% output.Algorithm = 'levenberg-marquardt';
end

function [model, state] = updateModelPositionAndVelocity(model, state, ...
    jointPositions, jointVelocities)
for j=1:size(jointPositions, 1)
    model.getCoordinateSet().get(j-1).setValue(state, ...
        jointPositions(j));
    model.getCoordinateSet().get(j-1).setSpeedValue(state, ...
        jointVelocities(j));
end
model.assemble(state)
model.realizeVelocity(state)
end
