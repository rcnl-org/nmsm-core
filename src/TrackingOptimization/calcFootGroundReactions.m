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

for i = 1:size(springPositions.rightHeel, 1)
markerKinematics.xPosition = squeeze(springPositions.rightHeel(i, 1, :))';
markerKinematics.height = squeeze(springPositions.rightHeel(i, 2, :))';
markerKinematics.zPosition = squeeze(springPositions.rightHeel(i, 3, :))';
markerKinematics.xVelocity = squeeze(springVelocities.rightHeel(i, 1, :))';
markerKinematics.yVelocity = squeeze(springVelocities.rightHeel(i, 2, :))';
markerKinematics.zVelocity = squeeze(springVelocities.rightHeel(i, 3, :))';

springForces = zeros(3, size(springPositions.rightHeel, 1));

[groundReactions.rightHeelForce(i, 2), springForces] = ...
    calcModeledVerticalGroundReactionForce(params.springStiffness.rightHeel, ...
    params.springDamping, params.restingSpringLength, ...
    markerKinematics, springForces);

values.springConstants = params.springStiffness.rightHeel;
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
markerKinematics.xPosition = squeeze(springPositions.rightToe(i, 1, :))';
markerKinematics.height = squeeze(springPositions.rightToe(i, 2, :))';
markerKinematics.zPosition = squeeze(springPositions.rightToe(i, 3, :))';
markerKinematics.xVelocity = squeeze(springVelocities.rightToe(i, 1, :))';
markerKinematics.yVelocity = squeeze(springVelocities.rightToe(i, 2, :))';
markerKinematics.zVelocity = squeeze(springVelocities.rightToe(i, 3, :))';

springForces = zeros(3, size(springPositions.rightToe, 1));

[groundReactions.rightToeForce(i, 2), springForces] = ...
    calcModeledVerticalGroundReactionForce(params.springStiffness.rightToe, ...
    params.springDamping, params.restingSpringLength, ...
    markerKinematics, springForces);

values.springConstants = params.springStiffness.rightToe;
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
markerKinematics.xPosition = squeeze(springPositions.leftHeel(i, 1, :))';
markerKinematics.height = squeeze(springPositions.leftHeel(i, 2, :))';
markerKinematics.zPosition = squeeze(springPositions.leftHeel(i, 3, :))';
markerKinematics.xVelocity = squeeze(springVelocities.leftHeel(i, 1, :))';
markerKinematics.yVelocity = squeeze(springVelocities.leftHeel(i, 2, :))';
markerKinematics.zVelocity = squeeze(springVelocities.leftHeel(i, 3, :))';

springForces = zeros(3, size(springPositions.leftHeel, 1));

[groundReactions.leftHeelForce(i, 2), springForces] = ...
    calcModeledVerticalGroundReactionForce(params.springStiffness.leftHeel, ...
    params.springDamping, params.restingSpringLength, ...
    markerKinematics, springForces);

values.springConstants = params.springStiffness.leftHeel;
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
markerKinematics.xPosition = squeeze(springPositions.leftToe(i, 1, :))';
markerKinematics.height = squeeze(springPositions.leftToe(i, 2, :))';
markerKinematics.zPosition = squeeze(springPositions.leftToe(i, 3, :))';
markerKinematics.xVelocity = squeeze(springVelocities.leftToe(i, 1, :))';
markerKinematics.yVelocity = squeeze(springVelocities.leftToe(i, 2, :))';
markerKinematics.zVelocity = squeeze(springVelocities.leftToe(i, 3, :))';

springForces = zeros(3, size(springPositions.leftHeel, 1));

[groundReactions.leftToeForce(i, 2), springForces] = ...
    calcModeledVerticalGroundReactionForce(params.springStiffness.leftToe, ...
    params.springDamping, params.restingSpringLength, ...
    markerKinematics, springForces);

values.springConstants = params.springStiffness.leftToe;
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