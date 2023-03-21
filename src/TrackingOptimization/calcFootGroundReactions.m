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

function groundReactions = calcFootGroundReactions(springPositions, ...
    springVelocities, params, bodyLocations)

Rhsprings = 1:params.numSpringsRightHeel;
Rtsprings = params.numSpringsRightHeel+1:params.numSpringsRightHeel+params.numSpringsRightToe;
Lhsprings = params.numSpringsRightHeel+params.numSpringsRightToe+1:params.numSpringsRightHeel+params.numSpringsRightToe+params.numSpringsLeftHeel;
Ltsprings = params.numSpringsRightHeel+params.numSpringsRightToe+params.numSpringsLeftHeel+1:params.numSpringsRightHeel+params.numSpringsRightToe+params.numSpringsLeftHeel+params.numSpringsLeftToe;

for i = 1:101
%%
markerKinematics.xPosition = springPositions(i,1:3:end);
markerKinematics.height = springPositions(i,2:3:end);
markerKinematics.zPosition = springPositions(i,3:3:end);
markerKinematics.xVelocity = springVelocities(i,1:3:end);
markerKinematics.yVelocity = springVelocities(i,2:3:end);
markerKinematics.zVelocity = springVelocities(i,3:3:end);

markerKinematics.xPosition = markerKinematics.xPosition(Rhsprings);
markerKinematics.height = markerKinematics.height(Rhsprings);
markerKinematics.zPosition = markerKinematics.zPosition(Rhsprings);
markerKinematics.xVelocity = markerKinematics.xVelocity(Rhsprings);
markerKinematics.yVelocity = markerKinematics.yVelocity(Rhsprings);
markerKinematics.zVelocity = markerKinematics.zVelocity(Rhsprings);

springForces = zeros(3, length(Rhsprings));

[groundReactions.rightHeelForce(i, 2), springForces] = ...
    calcModeledVerticalGroundReactionForce(params.springStiffness(Rhsprings), ...
    params.springDamping, params.restingSpringLength, ...
    markerKinematics, springForces);

values.springConstants = params.springStiffness(Rhsprings);
values.dynamicFrictionCoefficient = params.dynamicFriction;

[groundReactions.rightHeelForce(i, 1), ...
    groundReactions.rightHeelForce(i, 3), springForces] = ...
    calcModeledHorizontalGroundReactionForces(values, ...
    params.beltSpeed, markerKinematics, springForces);

task.midfootSuperiorPosition = bodyLocations.rightMidfootSuperior';
[groundReactions.rightHeelMoment(i, 1), groundReactions.rightHeelMoment(i, 2), ...
    groundReactions.rightHeelMoment(i, 3)] = ...
    calcModeledGroundReactionMoments(values, ...
    task, markerKinematics, springForces, i);

%%
markerKinematics.xPosition = springPositions(i,1:3:end);
markerKinematics.height = springPositions(i,2:3:end);
markerKinematics.zPosition = springPositions(i,3:3:end);
markerKinematics.xVelocity = springVelocities(i,1:3:end);
markerKinematics.yVelocity = springVelocities(i,2:3:end);
markerKinematics.zVelocity = springVelocities(i,3:3:end);

markerKinematics.xPosition = markerKinematics.xPosition(Rtsprings);
markerKinematics.height = markerKinematics.height(Rtsprings);
markerKinematics.zPosition = markerKinematics.zPosition(Rtsprings);
markerKinematics.xVelocity = markerKinematics.xVelocity(Rtsprings);
markerKinematics.yVelocity = markerKinematics.yVelocity(Rtsprings);
markerKinematics.zVelocity = markerKinematics.zVelocity(Rtsprings);

springForces = zeros(3, length(Rtsprings));

[groundReactions.rightToeForce(i, 2), springForces] = ...
    calcModeledVerticalGroundReactionForce(params.springStiffness(Rtsprings), ...
    params.springDamping, params.restingSpringLength, ...
    markerKinematics, springForces);

values.springConstants = params.springStiffness(Rtsprings);
values.dynamicFrictionCoefficient = params.dynamicFriction;

[groundReactions.rightToeForce(i, 1), ...
    groundReactions.rightToeForce(i, 3), springForces] = ...
    calcModeledHorizontalGroundReactionForces(values, ...
    params.beltSpeed, markerKinematics, springForces);

task.midfootSuperiorPosition = bodyLocations.rightMidfootSuperior';
[groundReactions.rightToeMoment(i, 1), groundReactions.rightToeMoment(i, 2), ...
    groundReactions.rightToeMoment(i, 3)] = ...
    calcModeledGroundReactionMoments(values, ...
    task, markerKinematics, springForces, i);

%%
markerKinematics.xPosition = springPositions(i,1:3:end);
markerKinematics.height = springPositions(i,2:3:end);
markerKinematics.zPosition = springPositions(i,3:3:end);
markerKinematics.xVelocity = springVelocities(i,1:3:end);
markerKinematics.yVelocity = springVelocities(i,2:3:end);
markerKinematics.zVelocity = springVelocities(i,3:3:end);

markerKinematics.xPosition = markerKinematics.xPosition(Lhsprings);
markerKinematics.height = markerKinematics.height(Lhsprings);
markerKinematics.zPosition = markerKinematics.zPosition(Lhsprings);
markerKinematics.xVelocity = markerKinematics.xVelocity(Lhsprings);
markerKinematics.yVelocity = markerKinematics.yVelocity(Lhsprings);
markerKinematics.zVelocity = markerKinematics.zVelocity(Lhsprings);

springForces = zeros(3, length(Lhsprings));

[groundReactions.leftHeelForce(i, 2), springForces] = ...
    calcModeledVerticalGroundReactionForce(params.springStiffness(Lhsprings), ...
    params.springDamping, params.restingSpringLength, ...
    markerKinematics, springForces);

values.springConstants = params.springStiffness(Lhsprings);
values.dynamicFrictionCoefficient = params.dynamicFriction;

[groundReactions.leftHeelForce(i, 1), ...
    groundReactions.leftHeelForce(i, 3), springForces] = ...
    calcModeledHorizontalGroundReactionForces(values, ...
    params.beltSpeed, markerKinematics, springForces);

task.midfootSuperiorPosition = bodyLocations.leftMidfootSuperior';
[groundReactions.leftHeelMoment(i, 1), groundReactions.leftHeelMoment(i, 2), ...
    groundReactions.leftHeelMoment(i, 3)] = ...
    calcModeledGroundReactionMoments(values, ...
    task, markerKinematics, springForces, i);

%%
markerKinematics.xPosition = springPositions(i,1:3:end);
markerKinematics.height = springPositions(i,2:3:end);
markerKinematics.zPosition = springPositions(i,3:3:end);
markerKinematics.xVelocity = springVelocities(i,1:3:end);
markerKinematics.yVelocity = springVelocities(i,2:3:end);
markerKinematics.zVelocity = springVelocities(i,3:3:end);

markerKinematics.xPosition = markerKinematics.xPosition(Ltsprings);
markerKinematics.height = markerKinematics.height(Ltsprings);
markerKinematics.zPosition = markerKinematics.zPosition(Ltsprings);
markerKinematics.xVelocity = markerKinematics.xVelocity(Ltsprings);
markerKinematics.yVelocity = markerKinematics.yVelocity(Ltsprings);
markerKinematics.zVelocity = markerKinematics.zVelocity(Ltsprings);

springForces = zeros(3, length(Ltsprings));

[groundReactions.leftToeForce(i, 2), springForces] = ...
    calcModeledVerticalGroundReactionForce(params.springStiffness(Ltsprings), ...
    params.springDamping, params.restingSpringLength, ...
    markerKinematics, springForces);

values.springConstants = params.springStiffness(Ltsprings);
values.dynamicFrictionCoefficient = params.dynamicFriction;

[groundReactions.leftToeForce(i, 1), ...
    groundReactions.leftToeForce(i, 3), springForces] = ...
    calcModeledHorizontalGroundReactionForces(values, ...
    params.beltSpeed, markerKinematics, springForces);

task.midfootSuperiorPosition = bodyLocations.leftMidfootSuperior';
[groundReactions.leftToeMoment(i, 1), groundReactions.leftToeMoment(i, 2), ...
    groundReactions.leftToeMoment(i, 3)] = ...
    calcModeledGroundReactionMoments(values, ...
    task, markerKinematics, springForces, i);
end

end