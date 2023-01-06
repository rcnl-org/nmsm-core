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

function phaseout = calcTrackingOptimizationModeledValues(values, params)

[springPositions, springVelocities] = pointKinematics(values.time, ...
    values.statePositions, values.stateVelocities, ...
    params.springPointsOnBody', params.springBody, params.coordinateNames);
phaseout.bodyLocations = getBodyLocations(values.time, ....
    values.statePositions, values.stateVelocities, params);
groundReactions = calcGroundReactions(springPositions, springVelocities, ...
    params, phaseout.bodyLocations);
groundReactionsBody = tranferGroundReactionMoments( ...
    phaseout.bodyLocations, groundReactions);
[phaseout.rightGroundReactionsLab, phaseout.lefttGroundReactionsLab] = ...
    calcGroundReactionsLab(groundReactions);

jointAngles = getMuscleActuatedDOFs(values, params);
[params.muscleTendonLength, params.momentArms] = calcSurrogateModel( ...
    params, jointAngles);
params.muscleTendonVelocities = calcMuscleTendonVelocities(values.time, ...
    params.muscleTendonLength, params.smoothingParam);
[phaseout.normalizedFiberLength, phaseout.normalizedFiberVelocity] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(params, ...
    ones(1, params.numMuscles), ones(1, params.numMuscles));
phaseout.muscleActivations = calcMuscleActivationFromSynergies(values, params);
phaseout.muscleJointMoments = calcMuscleJointMoments(params, ...
    phaseout.muscleActivations, phaseout.normalizedFiberLength, ...
    phaseout.normalizedFiberVelocity);
phaseout.muscleJointMoments(:, all(~phaseout.muscleJointMoments, 1)) = [];

appliedLoads = [zeros(length(values.time), params.numActuators) ...
    groundReactionsBody];
phaseout.inverseDynamicMoments = inverseDynamics(values.time, ...
    values.statePositions, values.stateVelocities, ...
    values.stateAccelerations, params.coordinateNames, appliedLoads);
phaseout = parseInverseDynamicMoments(phaseout, params);
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
    stateVelocities, params.rightHeelPointOnBody', ...
    params.rightHeelBody, params.coordinateNames);
bodyLocations.leftHeel = pointKinematics(time, statePositions, ...
    stateVelocities, params.leftHeelPointOnBody', ...
    params.leftHeelBody, params.coordinateNames);

bodyLocations.rightToe = pointKinematics(time, statePositions, ...
    stateVelocities, params.rightToePointOnBody', ...
    params.rightToeBody, params.coordinateNames);
bodyLocations.leftToe = pointKinematics(time, statePositions, ...
    stateVelocities, params.leftToePointOnBody', ...
    params.leftToeBody, params.coordinateNames);
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
function muscleActivations = calcMuscleActivationFromSynergies(values, params)

rightMuscleActivations = values.controlNeuralCommandsRight * ...
    values.synergyWeights(1 : params.numRightSynergies, :);
leftMuscleActivations = values.controlNeuralCommandsLeft * ...
    values.synergyWeights(params.numRightSynergies + 1 : end, :);
muscleActivations = [rightMuscleActivations leftMuscleActivations];
end
function jointAngles = getMuscleActuatedDOFs(values, params)

for i = 1:params.numMuscles
    index = 1;
    for j = 1:size(params.dofsActuated, 1)
        if params.dofsActuated(j, i) > params.epsilon
            jointAngles{i}(:, index) = values.statePositions(:, j);
            index = index + 1;
        end
    end
end
end
function [muscleTendonLength, momentArms] = calcSurrogateModel( ...
    params, jointAngles)

for i = 1 : size(jointAngles, 2)
    % Initialize symbolic thetas
    theta = sym('theta', [1 size(jointAngles{i}, 2)]);
    % Get A matrix
    matrix = getDataMatrix(params.polynomialExpressionMuscleTendonLengths{i}, ...
        params.polynomialExpressionMomentArms{i}, jointAngles{i}, theta);
    % Caculate new muscle tendon lengths and moment arms
    vector = matrix * params.coefficients{i};
    muscleTendonLength(:, i) = vector(1 : size(jointAngles{i}, 1));
    index = 1;
    for j = 1 : size(params.dofsActuated, 1)
        if params.dofsActuated(j, i) > params.epsilon
            momentArms(:, j, i) = vector(size(jointAngles{i}, 1) * ...
                index + 1 : size(jointAngles{i}, 1) * (index + 1));
            index = index + 1;
        else
            momentArms(:, j, i) = zeros(size(jointAngles{i}, 1), 1);
        end
    end
end
end
function muscleTendonVelocities = calcMuscleTendonVelocities(time, ...
    muscleTendonLength, smoothingParam)

for i = 1 : size(muscleTendonLength, 2)
    muscleTendonVelocities(:, i) = calcDerivative(time, ...
        muscleTendonLength(:, i), smoothingParam);
end
end
function phaseout = parseInverseDynamicMoments(phaseout, params)

phaseout.pelvisResiduals = ...
    phaseout.inverseDynamicMoments(:, params.pelvisResidualsIndex);
phaseout.inverseDynamicMoments(:, params.inverseDynamicMomentsIndex) = [];
phaseout.muscleActuatedMoments = ...
    phaseout.inverseDynamicMoments(:, params.muscleActuatedMomentsIndex);
end