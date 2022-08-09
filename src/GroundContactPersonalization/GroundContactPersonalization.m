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
% Author(s): Claire V. Hammond                                            %
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

function results = GroundContactPersonalization(inputs, params)
verifyInputs(inputs); % (struct) -> (None)
verifyParams(params); % (struct) -> (None)
inputs = prepareInputs(inputs, params);
inputs = optimizeByVerticalGroundReactionForce(inputs, params);
inputs = optimizeByGroundReactionForces(inputs, params);
results = optimizeByGroundReactionAndCenterOfPressureAndFreeMoment( ...
    inputs, params);

end

% (struct) -> (None)
% throws an error if any of the inputs are invalid
function verifyInputs(inputs)

end

% (struct) -> (None)
% throws an error if the parameter is included but is not of valid type
function verifyParams(params)

end

% (struct, struct) -> (struct)
% prepares optimization values from inputs
function inputs = prepareInputs(inputs, params)
inputs.right.markerNames.toe = "R.Toe";
inputs.right.markerNames.medial = "R.Toe.Medial";
inputs.right.markerNames.lateral = "R.Toe.Lateral";
inputs.right.markerNames.heel = "R.Heel";
inputs.left.markerNames.toe = "L.Toe";
inputs.left.markerNames.medial = "L.Toe.Medial";
inputs.left.markerNames.lateral = "L.Toe.Lateral";
inputs.left.markerNames.heel = "L.Heel";
inputs.gridWidth = 5;
inputs.gridHeight = 15;
inputs.left.isLeftFoot = true;
inputs.right.isLeftFoot = false;

if inputs.right.isEnabled
    inputs.right = prepareInputsForSide(inputs.right, inputs);
end
if inputs.left.isEnabled
    inputs.left = prepareInputsForSide(inputs.left, inputs);
end

% inputs.rightKinematicCurveCoefficients = []; % 25 x 7 matrix
% inputs.leftKinematicCurveCoefficients = []; % 25 x 7 matrix
% inputs.rightFootVerticalPosition = []; % 1 val
% inputs.leftFootVerticalPosition = []; % 1 val

inputs.staticFrictionCoefficient = ... 
    inputs.errorCenters.staticFrictionCoefficient;
inputs.dynamicFrictionCoefficient = ...
    inputs.errorCenters.dynamicFrictionCoefficient;
inputs.viscousFrictionCoefficient = ...
    inputs.errorCenters.viscousFrictionCoefficient;
end

function inputs = prepareInputsForSide(inputs, sharedInputs)
inputs.toesJointName = char(Model(sharedInputs.bodyModel ...
    ).getCoordinateSet().get(inputs.toesCoordinateName).getJoint(...
    ).getName());
[inputs.hindfootBodyName, inputs.toesBodyName] = ...
    getJointBodyNames(Model(sharedInputs.bodyModel), inputs.toesJointName);
inputs.coordinatesOfInterest = findGCPFreeCoordinates(...
    Model(sharedInputs.bodyModel), inputs.toesBodyName);

[footPosition, markerPositions] = makeFootKinematics(...
    sharedInputs.bodyModel, sharedInputs.motionFileName, ...
    inputs.coordinatesOfInterest, inputs.hindfootBodyName, ...
    inputs.toesCoordinateName, inputs.markerNames);

footVelocity = calcBSplineDerivative(sharedInputs.time, footPosition, ...
    4, 21);
markerNamesFields = fieldnames(inputs.markerNames);
for i=1:length(inputs.markerNamesFields)
markerVelocities.(inputs.markerNamesFields{i}) = ...
    calcBSplineDerivative(time, markerPositions.(...
    markerNamesFields{i}), 4, 21);
end

inputs.model = makeFootModel(sharedInputs.bodyModel, inputs.toesJointName);
inputs.model = addSpringsToModel(inputs.model, inputs.markerNames, ...
    sharedInputs.gridWidth, sharedInputs.gridHeight, ...
    inputs.hindfootBodyName, inputs.toesBodyName, inputs.isLeftFoot); % change isLeftFoot?
inputs.model.print("footModel.osim");
inputs.model = Model("footModel.osim");
inputs.numSpringMarkers = findNumSpringMarkers(inputs.model);

inputs.experimentalMarkerPositions = markerPositions;
inputs.experimentalMarkerVelocities = markerVelocities;
inputs.experimentalJointPositions = footPosition;
inputs.experimentalJointVelocities = footVelocity;

initialSpringConstants = 2596; % Jackson et al 2016 Table 2
initialDampingFactors = 10;
initialSpringRestingLength = 0.05;
inputs.springConstants = initialSpringConstants * ones(1, ...
    inputs.numSpringMarkers);
inputs.dampingFactors = initialDampingFactors * ones(1, ...
    inputs.numSpringMarkers);
inputs.springRestingLength = initialSpringRestingLength;

inputs.experimentalGroundReactionForcesSlope = calcBSplineDerivative( ...
    sharedInputs.time, inputs.experimentalGroundReactionForces, 2, 25);
inputs.jointKinematicsBSplines = makeJointKinematicsBSplines(...
    sharedInputs.time, 4, 25);
inputs.bSplineCoefficients = calcInitialDeviationNodes(...
    sharedInputs.time, 4, 25, 7);
inputs.springRestingLength = initialSpringRestingLength;
end