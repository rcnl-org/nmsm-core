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

function phaseout = calcTrackingOptimizationTorqueBasedModeledValues(values, params)

[springPositions, springVelocities] = getSpringLocations(values.time, ....
    values.statePositions, values.stateVelocities, params);
phaseout.bodyLocations = getBodyLocations(values.time, ....
    values.statePositions, values.stateVelocities, params);
groundReactions = calcFootGroundReactions(springPositions, springVelocities, ...
    params, phaseout.bodyLocations);
groundReactionsBody = tranferGroundReactionMoments( ...
    phaseout.bodyLocations, groundReactions);
[phaseout.rightGroundReactionsLab, phaseout.leftGroundReactionsLab] = ...
    calcGroundReactionsLab(groundReactions);

appliedLoads = [zeros(length(values.time), params.numTotalMuscles) groundReactionsBody];
phaseout.inverseDynamicMoments = inverseDynamics(values.time, ...
    values.statePositions, values.stateVelocities, ...
    values.stateAccelerations, params.coordinateNames, appliedLoads);
phaseout = parseInverseDynamicMoments(phaseout, params);
end
function [springPositions, springVelocities] = getSpringLocations(time, ....
    statePositions, stateVelocities, params)

[springPositions.rightHeel, springVelocities.rightHeel] = ...
    pointKinematics(time, statePositions, stateVelocities, ...
    params.rightHeelSpringPositionOnBody', params.rightHeelBody * ones(1, ...
    size(params.rightHeelSpringPositionOnBody, 1)), params.coordinateNames);
[springPositions.rightToe, springVelocities.rightToe] = ...
    pointKinematics(time, statePositions, stateVelocities, ...
    params.rightToeSpringPositionOnBody', params.rightToeBody * ones(1, ...
    size(params.rightToeSpringPositionOnBody, 1)), params.coordinateNames);
[springPositions.leftHeel, springVelocities.leftHeel] = ...
    pointKinematics(time, statePositions, stateVelocities, ...
    params.leftHeelSpringPositionOnBody', params.leftHeelBody * ones(1, ...
    size(params.leftHeelSpringPositionOnBody, 1)), params.coordinateNames);
[springPositions.leftToe, springVelocities.leftToe] = ...
    pointKinematics(time, statePositions, stateVelocities, ...
    params.leftToeSpringPositionOnBody', params.leftToeBody * ones(1, ...
    size(params.leftToeSpringPositionOnBody, 1)), params.coordinateNames);
end
function bodyLocations = getBodyLocations(time, statePositions, ...
    stateVelocities, params)

bodyLocations.rightMidfootSuperior = pointKinematics(time, statePositions, ...
    stateVelocities, params.rightMidfootSuperiorPointOnBody', ...
    params.rightMidfootSuperiorBody, params.coordinateNames);
bodyLocations.rightMidfootSuperior(:, 2) = 0;
bodyLocations.leftMidfootSuperior = pointKinematics(time, statePositions, ...
    stateVelocities, params.leftMidfootSuperiorPointOnBody', ...
    params.leftMidfootSuperiorBody, params.coordinateNames);
bodyLocations.leftMidfootSuperior(:, 2) = 0;

bodyLocations.rightHeel = pointKinematics(time, statePositions, ...
    stateVelocities, [0 0 0]', params.rightHeelBody, params.coordinateNames);
bodyLocations.leftHeel = pointKinematics(time, statePositions, ...
    stateVelocities, [0 0 0]', params.leftHeelBody, params.coordinateNames);

bodyLocations.rightToe = pointKinematics(time, statePositions, ...
    stateVelocities, [0 0 0]', params.rightToeBody, params.coordinateNames);
bodyLocations.leftToe = pointKinematics(time, statePositions, ...
    stateVelocities, [0 0 0]', params.leftToeBody, params.coordinateNames);
end
function groundReactionsBody = tranferGroundReactionMoments( ...
    bodyLocations, groundReactions)

rightHeelMoment = transferMoments(...
    bodyLocations.rightMidfootSuperior, bodyLocations.rightHeel, ...
    groundReactions.rightHeelMoment, groundReactions.rightHeelForce);
leftHeelMoment = transferMoments( ...
    bodyLocations.leftMidfootSuperior, bodyLocations.leftHeel, ...
    groundReactions.leftHeelMoment, groundReactions.leftHeelForce);
rightToeMoment = transferMoments( ...
    bodyLocations.rightMidfootSuperior, bodyLocations.rightToe, ...
    groundReactions.rightToeMoment, groundReactions.rightToeForce);
leftToeMoment = transferMoments( ...
    bodyLocations.leftMidfootSuperior, bodyLocations.leftToe, ...
    groundReactions.leftToeMoment, groundReactions.leftToeForce);

groundReactionsBody = [groundReactions.rightHeelForce  ...
    groundReactions.rightToeForce groundReactions.leftHeelForce ...
    groundReactions.leftToeForce rightHeelMoment rightToeMoment ...
    leftHeelMoment leftToeMoment];
end
function moment = transferMoments(newPosition, oldPosition, moment, force)

moment = cross(newPosition - oldPosition, force, 2) + moment;
end
function [rightGroundReactionsLab, leftGroundReactionsLab] = ...
    calcGroundReactionsLab(groundReactions)

rightGroundReactionsLab = [ ...
    groundReactions.rightHeelForce + groundReactions.rightToeForce ...
    groundReactions.rightHeelMoment + groundReactions.rightToeMoment];
leftGroundReactionsLab = [ ...
    groundReactions.leftHeelForce + groundReactions.leftToeForce ...
    groundReactions.leftHeelMoment + groundReactions.leftToeMoment];
end
function phaseout = parseInverseDynamicMoments(phaseout, params)

phaseout.rootSegmentResiduals = ...
    phaseout.inverseDynamicMoments(:, params.rootSegmentResidualsIndex);
if strcmp(params.controllerType, 'synergy_driven') 
phaseout.muscleActuatedMoments = ...
    phaseout.inverseDynamicMoments(:, params.muscleActuatedMomentsIndex);
elseif strcmp(params.controllerType, 'torque_driven') 
phaseout.torqueActuatedMoments = ...
    phaseout.inverseDynamicMoments(:, params.torqueActuatedMomentsIndex);
end
end