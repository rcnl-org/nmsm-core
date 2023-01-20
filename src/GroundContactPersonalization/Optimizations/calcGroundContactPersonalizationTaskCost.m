% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (Array of double, struct, struct) -> (struct)
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

function cost = calcGroundContactPersonalizationTaskCost( ...
    values, fieldNameOrder, inputs, params, task)
valuesStruct = unpackValues(values, inputs, fieldNameOrder);
if ~params.tasks{task}.designVariables(1)
        valuesStruct.springConstants = inputs.springConstants;
end
if ~params.tasks{task}.designVariables(2)
        valuesStruct.dampingFactors = inputs.dampingFactors;
end
if ~params.tasks{task}.designVariables(3)
        valuesStruct.bSplineCoefficients = inputs.bSplineCoefficients;
end
if ~params.tasks{task}.designVariables(4)
        valuesStruct.dynamicFrictionCoefficient = ...
            inputs.dynamicFrictionCoefficient;
end
if ~params.tasks{task}.designVariables(5)
        valuesStruct.restingSpringLength = ...
            inputs.restingSpringLength;
end
valuesBSplineCoefficients = ...
    reshape(valuesStruct.bSplineCoefficients, [], 7);
[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    valuesBSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, valuesStruct, ...
    modeledJointPositions, modeledJointVelocities, params, task);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;

cost = calcCost(inputs, params, modeledValues, valuesStruct, task);
end

function valuesStruct = unpackValues(values, inputs, fieldNameOrder)
valuesStruct = struct();
start = 1;
for i=1:length(fieldNameOrder)
    valuesStruct.(fieldNameOrder(i)) = values(start:start + ...
        numel(inputs.(fieldNameOrder(i))) - 1);
    if fieldNameOrder(i) == "springConstants"
        valuesStruct.(fieldNameOrder(i)) = ...
            1000 * valuesStruct.(fieldNameOrder(i));
    end
    start = start + numel(inputs.(fieldNameOrder(i)));
end
end

function cost = calcCost(inputs, params, modeledValues, valuesStruct, task)
cost = [];
if (params.tasks{task}.costTerms.markerPositionError.isEnabled || ...
        params.tasks{task}.costTerms.markerSlopeError.isEnabled)
    [footMarkerPositionError, footMarkerSlopeError] = ...
        calcFootMarkerPositionAndSlopeError(inputs, modeledValues);
end
if (params.tasks{task}.costTerms.markerPositionError.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.markerPositionError.maxAllowableError;
    cost = [cost sqrt(1 / (12 * 101)) * (1 / maxAllowableError * ...
        footMarkerPositionError)];
end
if (params.tasks{task}.costTerms.markerSlopeError.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.markerSlopeError.maxAllowableError;
    cost = [cost sqrt(1 / (12 * 101)) * (1 / maxAllowableError * ...
        footMarkerSlopeError)];
end
if (params.tasks{task}.costTerms.coordinateCoefficientError.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.coordinateCoefficientError.maxAllowableError;
    cost = [cost sqrt(1 / (params.splineNodes * 7)) * (1 / ...
        maxAllowableError * calcKinematicsBSplineCoefficientError(...
        valuesStruct.bSplineCoefficients))];
end
if (params.tasks{task}.costTerms.verticalGrfError.isEnabled || ...
        params.tasks{task}.costTerms.verticalGrfSlopeError.isEnabled || ...
        params.tasks{task}.costTerms.horizontalGrfError.isEnabled || ...
        params.tasks{task}.costTerms.horizontalGrfSlopeError.isEnabled || ...
        params.tasks{task}.costTerms.groundReactionMomentError.isEnabled || ...
        params.tasks{task}.costTerms.groundReactionMomentSlopeError.isEnabled)
    if ~isfield(modeledValues, 'anteriorGrf')
        modeledValues.anteriorGrf = zeros(size(modeledValues.verticalGrf));
        modeledValues.lateralGrf = zeros(size(modeledValues.verticalGrf));
    end
    [groundReactionForceValueErrors, groundReactionForceSlopeErrors] = ...
        calcGroundReactionForceAndSlopeError(inputs, modeledValues);
end
if (params.tasks{task}.costTerms.verticalGrfError.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.verticalGrfError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceValueErrors(2, :)];
end
if (params.tasks{task}.costTerms.verticalGrfSlopeError.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.verticalGrfSlopeError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceSlopeErrors(2, :)];
end
if (params.tasks{task}.costTerms.horizontalGrfError.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.horizontalGrfError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceValueErrors(1, :)];
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceValueErrors(3, :)];
end
if (params.tasks{task}.costTerms.horizontalGrfSlopeError.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.horizontalGrfSlopeError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceSlopeErrors(1, :)];
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceSlopeErrors(3, :)];
end
if (params.tasks{task}.costTerms.groundReactionMomentError.isEnabled || ...
        params.tasks{task}.costTerms.groundReactionMomentSlopeError.isEnabled)
    [groundReactionMomentErrors, groundReactionMomentSlopeErrors] = ...
        calcGroundReactionMomentAndSlopeError(inputs, modeledValues); 
end
if (params.tasks{task}.costTerms.groundReactionMomentError.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.groundReactionMomentError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionMomentErrors(1, :)];
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionMomentErrors(2, :)];
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionMomentErrors(3, :)];
end
if (params.tasks{task}.costTerms.groundReactionMomentSlopeError.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.groundReactionMomentSlopeError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionMomentSlopeErrors(1, :)];
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionMomentSlopeErrors(2, :)];
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionMomentSlopeErrors(3, :)];
end
if (params.tasks{task}.costTerms.springConstantErrorFromMean.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.springConstantErrorFromMean.maxAllowableError;
    cost = [cost sqrt(1 / length(valuesStruct.springConstants)) * ...
        (1 / maxAllowableError) * ...
        calcSpringConstantsErrorFromMean(valuesStruct.springConstants)];
end
if (params.tasks{task}.costTerms.springConstantErrorFromNeighbors.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.springConstantErrorFromNeighbors.maxAllowableError;
    cost = [cost sqrt(1 / numel(inputs.nearestSpringMarkers)) * ...
        (1 / maxAllowableError) * ...
        calcSpringConstantsErrorFromNeighbors( ...
        valuesStruct.springConstants, modeledValues.gaussianWeights)];
end
if (params.tasks{task}.costTerms.dampingFactorErrorFromMean.isEnabled)
    maxAllowableError = ...
        params.tasks{task}.costTerms.dampingFactorErrorFromMean.maxAllowableError;
    cost = [cost (1 / maxAllowableError) * ...
        calcDampingFactorsErrorFromMean(valuesStruct.dampingFactors)];
end
end
