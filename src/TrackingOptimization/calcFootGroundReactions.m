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
    
[groundReactions.rightHeelForce, groundReactions.rightHeelMoment] = ...
    calcGroundReactionForcesAndMoments(springPositions.rightHeel, ...
    springVelocities.rightHeel, params.springStiffness.rightHeel, ...
    params, bodyLocations.rightMidfootSuperior);

[groundReactions.rightToeForce, groundReactions.rightToeMoment] = ...
    calcGroundReactionForcesAndMoments(springPositions.rightToe, ...
    springVelocities.rightToe, params.springStiffness.rightToe, ...
    params, bodyLocations.rightMidfootSuperior);

[groundReactions.leftHeelForce, groundReactions.leftHeelMoment] = ...
    calcGroundReactionForcesAndMoments(springPositions.leftHeel, ...
    springVelocities.leftHeel, params.springStiffness.leftHeel, ...
    params, bodyLocations.leftMidfootSuperior);

[groundReactions.leftToeForce, groundReactions.leftToeMoment] = ...
    calcGroundReactionForcesAndMoments(springPositions.leftToe, ...
    springVelocities.leftToe, params.springStiffness.leftToe, ...
    params, bodyLocations.leftMidfootSuperior);
end
function [forces, moments] = calcGroundReactionForcesAndMoments(markerPositions, ...
    markerVelocities, springConstants, params, midfootSuperiorPosition)

for i = 1:size(markerPositions, 1)
markerKinematics.xPosition = squeeze(markerPositions(i, 1, :))';
markerKinematics.height = squeeze(markerPositions(i, 2, :))';
markerKinematics.zPosition = squeeze(markerPositions(i, 3, :))';
markerKinematics.xVelocity = squeeze(markerVelocities(i, 1, :))';
markerKinematics.yVelocity = squeeze(markerVelocities(i, 2, :))';
markerKinematics.zVelocity = squeeze(markerVelocities(i, 3, :))';

springForces = zeros(3, size(markerPositions, 1));

[forces(i, 2), springForces] = calcModeledVerticalGroundReactionForce( ...
    springConstants, params.springDamping, params.restingSpringLength, ...
    markerKinematics, springForces);

values.springConstants = springConstants;
values.dynamicFrictionCoefficient = params.dynamicFriction;

[forces(i, 1), forces(i, 3), springForces] = ...
    calcModeledHorizontalGroundReactionForces(values, ...
    params.beltSpeed, markerKinematics, springForces);

task.midfootSuperiorPosition = midfootSuperiorPosition';
[moments(i, 1), moments(i, 2), moments(i, 3)] = ...
    calcModeledGroundReactionMoments(values, task, markerKinematics, ...
    springForces, i);
end
end