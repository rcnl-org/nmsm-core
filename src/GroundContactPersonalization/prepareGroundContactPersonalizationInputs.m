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

function inputs = prepareGroundContactPersonalizationInputs(inputs, params)
inputs.gridWidth = 5;
inputs.gridHeight = 15;

if inputs.right.isEnabled
    % Potentially refactor to use inputs.right if allowing multiple sides
    inputs = prepareInputsForSide(inputs, inputs, params);
end
if inputs.left.isEnabled
    inputs.left = prepareInputsForSide(inputs.left, inputs, params);
end

inputs.restingSpringLength = inputs.initialRestingSpringLength;
inputs.dynamicFrictionCoefficient = ...
    inputs.initialDynamicFrictionCoefficient;
end

% (struct, struct) -> (struct)
% prepares optimization values specific to a side
function inputs = prepareInputsForSide(inputs, sharedInputs, params)
inputs.toesJointName = char(Model(sharedInputs.bodyModel ...
    ).getCoordinateSet().get(inputs.toesCoordinateName).getJoint(...
    ).getName());
[inputs.hindfootBodyName, inputs.toesBodyName] = ...
    getJointBodyNames(Model(sharedInputs.bodyModel), inputs.toesJointName);
inputs.coordinatesOfInterest = findGCPFreeCoordinates(...
    Model(sharedInputs.bodyModel), string(inputs.toesBodyName));

[footPosition, markerPositions] = ...
    makeFootKinematics(sharedInputs.bodyModel, ...
    sharedInputs.motionFileName, inputs.coordinatesOfInterest, ...
    inputs.hindfootBodyName, inputs.toesCoordinateName, ...
    inputs.markerNames);

footVelocity = calcBSplineDerivative(inputs.time, footPosition, ...
    4, params.splineNodes);
markerNamesFields = fieldnames(inputs.markerNames);
for i=1:length(markerNamesFields)
markerVelocities.(markerNamesFields{i}) = ...
    calcBSplineDerivative(inputs.time, markerPositions.(...
    markerNamesFields{i}), 4, params.splineNodes);
end

% inputs.model = makeFootModel(sharedInputs.bodyModel, inputs.toesJointName);
% inputs.model = addSpringsToModel(inputs.model, inputs.markerNames, ...
%     sharedInputs.gridWidth, sharedInputs.gridHeight, ...
%     inputs.hindfootBodyName, inputs.toesBodyName, inputs.isLeftFoot); % change isLeftFoot?
% inputs.model.print("footModel.osim");
% inputs.model = Model("footModel.osim");
inputs.numSpringMarkers = findNumSpringMarkers(inputs.model);

inputs.experimentalMarkerPositions = markerPositions;
inputs.experimentalMarkerVelocities = markerVelocities;
inputs.experimentalJointPositions = footPosition;
inputs.experimentalJointVelocities = footVelocity;
inputs.midfootSuperiorPosition = markerPositions.midfootSuperior;
inputs.experimentalGroundReactionMoments = ...
    replaceMomentsAboutMidfootSuperior(inputs);

initialSpringConstants = 2596; % Jackson et al 2016 Table 2
initialDampingFactors = 10;
initialSpringRestingLength = 0.05;
inputs.springConstants = initialSpringConstants * ones(1, ...
    inputs.numSpringMarkers);
inputs.dampingFactors = initialDampingFactors * ones(1, ...
    inputs.numSpringMarkers);
inputs.springRestingLength = initialSpringRestingLength;

inputs.experimentalGroundReactionForcesSlope = calcBSplineDerivative( ...
    inputs.time, inputs.experimentalGroundReactionForces, 2, ...
    params.splineNodes);
inputs.experimentalGroundReactionMomentsSlope = calcBSplineDerivative( ...
    inputs.time, inputs.experimentalGroundReactionMoments, 2, ...
    params.splineNodes);
inputs.jointKinematicsBSplines = makeJointKinematicsBSplines(...
    inputs.time, 4, params.splineNodes);
inputs.bSplineCoefficients = ones(params.splineNodes, 7);
inputs.springRestingLength = initialSpringRestingLength;
end

% (struct) -> (2D Array of double)
% Replace parsed experimental ground reaction moments about midfoot
% superior marker projected onto floor
function replacedMoments = replaceMomentsAboutMidfootSuperior(inputs)
    replacedMoments = ...
        zeros(size(inputs.experimentalGroundReactionMoments));
    for i = 1:size(replacedMoments, 2)
        newCenter = inputs.midfootSuperiorPosition(:, i);
        newCenter(2) = 0;
        replacedMoments(:, i) = ...
            inputs.experimentalGroundReactionMoments(:, i) + ...
            cross((inputs.electricalCenter(:, i) - newCenter), ...
            inputs.experimentalGroundReactionForces(:, i));
    end
end