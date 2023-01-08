% This function is part of the NMSM Pipeline, see file for full license.
%
% This function steps through each modeledJointKinematics position and
% calculates the necessary values based on the true values in the
% isCalculated boolean array.
%
% isCalculated indices (in order);
%   -
%   -
%   -
%
% (Model, 2D array of double, struct, array of boolean) -> (struct)
% calculate modeled values for the GCP cost function

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

function modeledValues = calcGCPModeledValues(inputs, values, ...
    modeledJointPositions, modeledJointVelocities, isCalculated, params)
[model, state] = Model(inputs.model);
markerNamesFields = fieldnames(inputs.markerNames);
if isCalculated(4)
    if ~params.stageThree.springConstants.isEnabled
        values.springConstants = inputs.springConstants;
    end
    if ~params.stageThree.dampingFactors.isEnabled
        values.dampingFactors = inputs.dampingFactors;
    end
    if ~params.stageThree.dynamicFrictionCoefficient.isEnabled
        values.dynamicFrictionCoefficient = ...
            inputs.dynamicFrictionCoefficient;
    end
elseif isCalculated(3)
    if ~params.stageTwo.springConstants.isEnabled
        values.springConstants = inputs.springConstants;
    end
    if ~params.stageTwo.dampingFactors.isEnabled
        values.dampingFactors = inputs.dampingFactors;
    end
    if ~params.stageTwo.dynamicFrictionCoefficient.isEnabled
        values.dynamicFrictionCoefficient = ...
            inputs.dynamicFrictionCoefficient;
    end
else
    if ~params.stageOne.springConstants.isEnabled
        values.springConstants = inputs.springConstants;
    end
    if ~params.stageOne.dampingFactors.isEnabled
        values.dampingFactors = inputs.dampingFactors;
    end
end
for i=1:length(markerNamesFields)
    modeledValues.markerPositions.(markerNamesFields{i}) = ...
        zeros(3, size(modeledJointPositions, 2));
    modeledValues.markerVelocities.(markerNamesFields{i}) = ...
        zeros(3, size(modeledJointPositions, 2));
end
modeledValues.verticalGrf = zeros(1, size(modeledJointPositions, 2));
for i=1:size(modeledJointPositions, 2)
    [model, state] = updateModelPositionAndVelocity(model, state, ...
        modeledJointPositions(:, i), ...
        modeledJointVelocities(:, i));
    if isCalculated(1)
        [modeledValues.markerPositions, modeledValues.markerVelocities] ...
            = findModeledMarkerCoordinates(model, state, ...
            modeledValues.markerPositions, inputs.markerNames, i);
    end
    if isCalculated(2)
        modelMarkerPosition = zeros(3, length(values.springConstants));
        modelMarkerVelocity = zeros(3, length(values.springConstants));
        markerKinematics.height = zeros(size(values.springConstants));
        markerKinematics.yVelocity = zeros(size(values.springConstants));
        springForces = zeros(3, length(values.springConstants));
        for j = 1:length(values.springConstants)
            modelMarkerPosition = model.getMarkerSet().get(...
                "spring_marker_" + num2str(j)).getLocationInGround(state);
            modelMarkerVelocity = model.getMarkerSet().get(...
                "spring_marker_" + num2str(j)).getVelocityInGround(state);
            markerKinematics.height(j) = modelMarkerPosition.get(1);
            markerKinematics.yVelocity(j) = modelMarkerVelocity.get(1);
        end
        [modeledValues.verticalGrf(i), springForces] = ...
            calcModeledVerticalGroundReactionForce(...
            values.springConstants, values.dampingFactors, ...
            inputs.restingSpringLength, markerKinematics, springForces);
    end
    if isCalculated(3)
        markerKinematics.xVelocity = zeros(size(values.springConstants));
        markerKinematics.zVelocity = zeros(size(values.springConstants));
        for j = 1:length(values.springConstants)
            markerKinematics.xVelocity(j) = modelMarkerVelocity.get(0);
            markerKinematics.zVelocity(j) = modelMarkerVelocity.get(2);
        end
        [modeledValues.anteriorGrf(i), ...
            modeledValues.lateralGrf(i), springForces] = ...
            calcModeledHorizontalGroundReactionForces(values, ...
            inputs.beltSpeed, markerKinematics, springForces);
    end
    if isCalculated(4)
        markerKinematics.xPosition = zeros(size(values.springConstants));
        markerKinematics.zPosition = zeros(size(values.springConstants));
        inputs.midfootSuperiorPosition(:, i) = ...
            Model(inputs.model).getMarkerSet().get(inputs.markerNames.midfootSuperior ...
            ).getLocationInGround(state).getAsMat()';
        for j = 1:length(values.springConstants)
            markerKinematics.xPosition(j) = modelMarkerPosition.get(0);
            markerKinematics.zPosition(j) = modelMarkerPosition.get(2);
        end
        [modeledValues.xGrfMoment(i), modeledValues.yGrfMoment(i), ...
            modeledValues.zGrfMoment(i)] = ...
            calcModeledGroundReactionMoments(values, ...
            inputs, markerKinematics, springForces, i);
    end
end
% if isCalculated(1)
%     for i=1:length(markerNamesFields)
%         modeledValues.markerVelocities.(markerNamesFields{i}) = ...
%             calcBSplineDerivative(inputs.time, ...
%             modeledValues.markerPositions.(markerNamesFields{i}), 4, 25);
%     end
% end
end

function [model, state] = updateModelPositionAndVelocity(model, state, ...
    jointPositions, jointVelocities)
for j=1:size(jointPositions, 1)
    model.getCoordinateSet().get(j-1).setValue(state, ...
        jointPositions(j));
    model.getCoordinateSet().get(j-1).setSpeedValue(state, ...
        jointVelocities(j));
end
model.assemble(state)
model.realizeVelocity(state)
end


