% This function is part of the NMSM Pipeline, see file for full license.
%
% This function loads the appropriate spring position and velocity
% directions to calculate the corresponding ground reaction forces and
% moments. The ground reaction forces and moments are calculated for both
% the parent (ex. calcaneus) and child body (ex. toes).
%
% (struct, struct, struct, struct) -> (struct)
% Returns ground reaction forces and moments at the parent and child body 

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
    springVelocities, params, bodyLocations, reshapeSpringPositions)
if nargin < 5
    reshapeSpringPositions = true;
end
    
for i = 1:length(params.contactSurfaces)
    [groundReactions.parentForces{i}, groundReactions.parentMoments{i}] = ...
        calcGroundReactionForcesAndMoments(springPositions.parent{i}, ...
        springVelocities.parent{i}, params.contactSurfaces{i}.parentSpringConstants, ...
        bodyLocations.midfootSuperior{i}, params.contactSurfaces{i}, ...
        reshapeSpringPositions);
    [groundReactions.childForces{i}, groundReactions.childMoments{i}] = ...
        calcGroundReactionForcesAndMoments(springPositions.child{i}, ...
        springVelocities.child{i}, params.contactSurfaces{i}.childSpringConstants, ...
        bodyLocations.midfootSuperior{i}, params.contactSurfaces{i}, ...
        reshapeSpringPositions);
end
end
function [forces, moments] = calcGroundReactionForcesAndMoments(markerPositions, ...
    markerVelocities, springConstants, midfootSuperiorPosition, contactSurface, ...
    reshapeSpringPositions)

if reshapeSpringPositions
    markerPositions = reshape(markerPositions, [], 3, size(springConstants, 2));
    markerVelocities = reshape(markerVelocities, [], 3, size(springConstants, 2));
end

for i = 1:size(markerPositions, 1)
markerKinematics.xPosition = squeeze(markerPositions(i, 1, :))';
markerKinematics.height = squeeze(markerPositions(i, 2, :))';
markerKinematics.zPosition = squeeze(markerPositions(i, 3, :))';
markerKinematics.xVelocity = squeeze(markerVelocities(i, 1, :))';
markerKinematics.yVelocity = squeeze(markerVelocities(i, 2, :))';
markerKinematics.zVelocity = squeeze(markerVelocities(i, 3, :))';

springForces = zeros(3, size(markerPositions, 3));

[forces(i, 2), springForces] = calcModeledVerticalGroundReactionForce( ...
    springConstants, contactSurface.dampingFactor, contactSurface.restingSpringLength, ...
    markerKinematics, springForces);

contactSurface.springConstants = springConstants;

[forces(i, 1), forces(i, 3), springForces] = ...
    calcModeledHorizontalGroundReactionForces(contactSurface, ...
    contactSurface.beltSpeed, contactSurface.latchingVelocity, markerKinematics, springForces);

if reshapeSpringPositions
    task.midfootSuperiorPosition = midfootSuperiorPosition';
else
    task.midfootSuperiorPosition = midfootSuperiorPosition;
end
[moments(i, 1), moments(i, 2), moments(i, 3)] = ...
    calcModeledGroundReactionMoments(contactSurface, task, markerKinematics, ...
    springForces, i);
end
end