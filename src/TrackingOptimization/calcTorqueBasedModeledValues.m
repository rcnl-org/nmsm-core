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

function phaseout = calcTorqueBasedModeledValues(values, params)

[springPositions, springVelocities] = getSpringLocations(values.time, ....
    values.statePositions, values.stateVelocities, params);
phaseout.bodyLocations = getBodyLocations(values.time, ....
    values.statePositions, values.stateVelocities, params);
groundReactions = calcFootGroundReactions(springPositions, springVelocities, ...
    params, phaseout.bodyLocations);
groundReactionsBody = tranferGroundReactionMoments( ...
    phaseout.bodyLocations, groundReactions, params);
phaseout.groundReactionsLab = calcGroundReactionsLab(groundReactions);

appliedLoads = [zeros(length(values.time), params.numTotalMuscles) groundReactionsBody];
phaseout.inverseDynamicMoments = inverseDynamics(values.time, ...
    values.statePositions, values.stateVelocities, ...
    values.stateAccelerations, params.coordinateNames, appliedLoads);
end
function [springPositions, springVelocities] = getSpringLocations(time, ....
    statePositions, stateVelocities, params)

for i = 1:length(params.contactSurfaces)
    [springPositions.parent{i}, springVelocities.parent{i}] = ...
        pointKinematics(time, statePositions, stateVelocities, ...
        params.contactSurfaces{i}.parentSpringPointsOnBody', ...
        params.contactSurfaces{i}.parentBody * ones(1, ...
        size(params.contactSurfaces{i}.parentSpringPointsOnBody, 1)), ...
        params.coordinateNames);
    [springPositions.child{i}, springVelocities.child{i}] = ...
        pointKinematics(time, statePositions, stateVelocities, ...
        params.contactSurfaces{i}.childSpringPointsOnBody', ...
        params.contactSurfaces{i}.childBody * ones(1, ...
        size(params.contactSurfaces{i}.childSpringPointsOnBody, 1)), ...
        params.coordinateNames);
end
end
function bodyLocations = getBodyLocations(time, statePositions, ...
    stateVelocities, params)

for i = 1:length(params.contactSurfaces)
    bodyLocations.midfootSuperior{i} = pointKinematics(time, statePositions, ...
        stateVelocities, params.contactSurfaces{i}.midfootSuperiorPointOnBody', ...
        params.contactSurfaces{i}.midfootSuperiorBody, params.coordinateNames);
    bodyLocations.midfootSuperior{i}(:, 2) = 0;
    bodyLocations.parent{i} = pointKinematics(time, statePositions, ...
        stateVelocities, [0 0 0]', params.contactSurfaces{i}.parentBody, ...
        params.coordinateNames);
    bodyLocations.child{i} = pointKinematics(time, statePositions, ...
        stateVelocities, [0 0 0]', params.contactSurfaces{i}.childBody, ...
        params.coordinateNames);
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
    groundReactionsBody = [groundReactionsBody groundReactions.parentForces{i} ...
        groundReactions.childForces{i} parentMoment childMoment];
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