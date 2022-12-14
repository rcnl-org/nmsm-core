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

function inputs = initializeRestingSpringLengthAndSpringConstants(...
    inputs, params)
[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    ones(25, 7));
springHeights = zeros(size(modeledJointPositions, 2), ...
    length(inputs.springConstants));
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

% TODO: Pick frames with all springs in contact
verticalForce = inputs.experimentalGroundReactionForces(2, :)';
% verticalForce = verticalForce(verticalForce > 0.70 * max(verticalForce));
verticalForce = verticalForce(21:40);
includeOffset = find(inputs.experimentalGroundReactionForces(2, :)' == ...
    verticalForce(1)) - 1;
deflectionMatrix = zeros(length(verticalForce), 2);
for i = 1:length(verticalForce)
    for j = 1:length(inputs.springConstants)
        deflectionMatrix(i, 1) = deflectionMatrix(i, 1) - ...
            springHeights(i + includeOffset, j) - 0.001;
    end
    deflectionMatrix(i, 2) = 1 * length(inputs.springConstants);
end

initialGuesses = lsqlin(deflectionMatrix, verticalForce, [-1 10], [0], ...
    [], [], [0 0], [Inf Inf]);

inputs.springConstants = ones(1, length(inputs.springConstants)) * ...
    initialGuesses(1);
inputs.restingSpringLength = initialGuesses(2) / initialGuesses(1);
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
