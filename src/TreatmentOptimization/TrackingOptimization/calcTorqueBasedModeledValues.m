% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the position and velocities of the spring
% locations and corresponding ground reaction forces and moments if
% contact surfaces are present. This function also calculates inverse
% dynamic moments.
%
% (struct, struct) -> (struct)
% returns body locations, ground reactions, and inverse dynamic moments

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function modeledValues = calcTorqueBasedModeledValues(values, inputs, ...
    modeledValues)
[appliedLoads, modeledValues] = setupAppliedLoads(values, inputs, ...
    modeledValues);
modeledValues.markerPositions = calcTrackedMarkerPositions(values, inputs);
[modeledValues.inverseDynamicsMoments, modeledValues.angularMomentum, ....
    modeledValues.metabolicCost, massCenterPositons] = ...
    inverseDynamics(values.time, ...
    values.positions, values.velocities, ...
    values.accelerations, inputs.coordinateNames, appliedLoads, ...
    inputs.mexModel, modeledValues.muscleActivations, ...
    sum(valueOrAlternate(inputs, 'calculateAngularMomentum', false)), ...
    sum(valueOrAlternate(inputs, 'calculateMetabolicCost', false)));
modeledValues.massCenterVelocity = (massCenterPositons(2) - ...
    massCenterPositons(1)) / values.time(end);
end

function [appliedLoads, modeledValues] = setupAppliedLoads(values, ...
    inputs, modeledValues)
appliedLoads = [];
numCoordinateLoads = inputs.model.getForceSet().getSize() - ...
    inputs.model.getForceSet().getMuscles().getSize() - ...
    (12 * length(inputs.contactSurfaces));
coordinateLoads = zeros(length(values.time), numCoordinateLoads);
appliedLoads = [zeros(length(values.time), ...
    inputs.model.getForceSet().getMuscles().getSize()) ...
    coordinateLoads];
if ~isempty(inputs.contactSurfaces)
    clear pointKinematics
    [springPositions, springVelocities] = getSpringLocations( ...
        values.time, values.positions, values.velocities, inputs);
    modeledValues.bodyLocations = getBodyLocations(values.time, ....
        values.positions, values.velocities, inputs);
    groundReactions = calcFootGroundReactions(springPositions, ...
        springVelocities, inputs, modeledValues.bodyLocations);
    % modeledValues.bodyLocations.child = modeledValues.bodyLocations.parent;
    groundReactionsBody = tranferGroundReactionMoments( ...
        modeledValues.bodyLocations, groundReactions, inputs);
    modeledValues.groundReactionsLab = calcGroundReactionsLab(groundReactions);
    appliedLoads = [appliedLoads groundReactionsBody];
end
end

function [springPositions, springVelocities] = getSpringLocations(time, ....
    positions, velocities, inputs)

for i = 1:length(inputs.contactSurfaces)
    [springPositions.parent{i}, springVelocities.parent{i}] = ...
        pointKinematics(time, positions, velocities, ...
        inputs.contactSurfaces{i}.parentSpringPointsOnBody, ...
        inputs.contactSurfaces{i}.parentBody * ones(1, ...
        size(inputs.contactSurfaces{i}.parentSpringPointsOnBody, 1)), ...
        inputs.mexModel, inputs.coordinateNames);
    [springPositions.child{i}, springVelocities.child{i}] = ...
        pointKinematics(time, positions, velocities, ...
        inputs.contactSurfaces{i}.childSpringPointsOnBody, ...
        inputs.contactSurfaces{i}.childBody * ones(1, ...
        size(inputs.contactSurfaces{i}.childSpringPointsOnBody, 1)), ...
        inputs.mexModel, inputs.coordinateNames);
end
end

function bodyLocations = getBodyLocations(time, positions, ...
    velocities, inputs)

for i = 1:length(inputs.contactSurfaces)
    bodyLocations.midfootSuperior{i} = pointKinematics(time, ...
        positions, velocities, ...
        inputs.contactSurfaces{i}.midfootSuperiorPointOnBody, ...
        inputs.contactSurfaces{i}.midfootSuperiorBody, ...
        inputs.mexModel, inputs.coordinateNames);
    bodyLocations.midfootSuperior{i}(:, 2) = ...
        inputs.contactSurfaces{i}.restingSpringLength;
    bodyLocations.parent{i} = pointKinematics(time, positions, ...
        velocities, [0 0 0], inputs.contactSurfaces{i}.parentBody, ...
        inputs.mexModel, inputs.coordinateNames);
    bodyLocations.child{i} = pointKinematics(time, positions, ...
        velocities, [0 0 0], inputs.contactSurfaces{i}.childBody, ...
        inputs.mexModel, inputs.coordinateNames);
end
end

function groundReactionsBody = tranferGroundReactionMoments( ...
    bodyLocations, groundReactions, params)

groundReactionsBody = [];
for i = 1:length(params.contactSurfaces)
    parentMoment = transferMoments(bodyLocations.midfootSuperior{i}, ...
        bodyLocations.parent{i}, groundReactions.parentMoments{i}, ...
        groundReactions.parentForces{i});
    childMoment = transferMoments(bodyLocations.midfootSuperior{i}, ...
        bodyLocations.child{i}, groundReactions.childMoments{i}, ...
        groundReactions.childForces{i});
    % parentMoment = parentMoment + childMoment;
    % childMoment(:) = 0;
    groundReactionsBody = [groundReactionsBody, ...
        groundReactions.parentForces{i}, groundReactions.childForces{i}, ...
        ... zeros(size(groundReactions.childForces{i})) ...
        parentMoment, childMoment];
end
end

function groundReactionsInLab = calcGroundReactionsLab(groundReactions)

for i = 1:length(groundReactions.parentForces)
    groundReactionsInLab.forces{i} = ...
        groundReactions.parentForces{i} + groundReactions.childForces{i};
    groundReactionsInLab.moments{i} = ...
        groundReactions.parentMoments{i} + groundReactions.childMoments{i};
end
end

function markerPositions = calcTrackedMarkerPositions(values, inputs)
markerPositions = [];
if isfield(inputs, 'trackedMarkerNames') ...
        && ~isempty(inputs.trackedMarkerNames)
    clear pointKinematics
    markerPositions = pointKinematics(values.time, values.positions, ...
        values.velocities, inputs.trackedMarkerLocations, ...
        inputs.trackedMarkerBodyIndices, inputs.mexModel, ...
        inputs.coordinateNames);
end
end
