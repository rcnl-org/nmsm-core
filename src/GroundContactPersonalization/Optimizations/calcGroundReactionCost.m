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

function cost = calcGroundReactionCost(values, fieldNameOrder, inputs, ...
    params)
valuesStruct = unpackValues(values, inputs, fieldNameOrder);
if ~params.stageTwo.bSplineCoefficients.isEnabled
        valuesStruct.bSplineCoefficients = inputs.bSplineCoefficients;
end
valuesBSplineCoefficients = ...
    reshape(valuesStruct.bSplineCoefficients, [], 7);
[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    valuesBSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, valuesStruct, ...
    modeledJointPositions, modeledJointVelocities, [1, 1, 1, 0], params);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;

cost = calcCost(inputs, params, modeledValues, valuesStruct);
end

function valuesStruct = unpackValues(values, inputs, fieldNameOrder)
valuesStruct = struct();
start = 1;
for i=1:length(fieldNameOrder)
    valuesStruct.(fieldNameOrder(i)) = values(start:start + ...
        numel(inputs.(fieldNameOrder(i))) - 1);
    start = start + numel(inputs.(fieldNameOrder(i)));
end
end

function cost = calcCost(inputs, params, modeledValues, valuesStruct)
cost = [];
if (params.stageTwoCosts.markerPositionError.isEnabled || ...
        params.stageTwoCosts.markerSlopeError.isEnabled)
    [footMarkerPositionError, footMarkerSlopeError] = ...
        calcFootMarkerPositionAndSlopeError(inputs, modeledValues);
end
if (params.stageTwoCosts.markerPositionError.isEnabled)
    maxAllowableError = ...
        params.stageTwoCosts.markerPositionError.maxAllowableError;
    cost = [cost sqrt(1 / (12 * 101)) * (1 / maxAllowableError * ...
        footMarkerPositionError)];
end
if (params.stageTwoCosts.markerSlopeError.isEnabled)
    maxAllowableError = ...
        params.stageTwoCosts.markerSlopeError.maxAllowableError;
    cost = [cost sqrt(1 / (12 * 101)) * (1 / maxAllowableError * ...
        footMarkerSlopeError)];
end
if (params.stageTwoCosts.coordinateCoefficientError.isEnabled)
    maxAllowableError = ...
        params.stageTwoCosts.coordinateCoefficientError.maxAllowableError;
    cost = [cost sqrt(1 / (25 * 7)) * (1 / maxAllowableError * ...
        calcKinematicsBSplineCoefficientError(...
        valuesStruct.bSplineCoefficients))];
end
if (params.stageTwoCosts.verticalGrfError.isEnabled || ...
        params.stageTwoCosts.verticalGrfSlopeError.isEnabled || ...
        params.stageTwoCosts.horizontalGrfError.isEnabled || ...
        params.stageTwoCosts.horizontalGrfSlopeError.isEnabled)
    [groundReactionForceValueErrors, groundReactionForceSlopeErrors] = ...
        calcGroundReactionForceAndSlopeError(inputs, modeledValues);
end
if (params.stageTwoCosts.verticalGrfError.isEnabled)
    maxAllowableError = ...
        params.stageTwoCosts.verticalGrfError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceValueErrors(2, :)];
end
if (params.stageTwoCosts.verticalGrfSlopeError.isEnabled)
    maxAllowableError = ...
        params.stageTwoCosts.verticalGrfSlopeError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceSlopeErrors(2, :)];
end
if (params.stageTwoCosts.horizontalGrfError.isEnabled)
    maxAllowableError = ...
        params.stageTwoCosts.horizontalGrfError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceValueErrors(1, :)];
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceValueErrors(3, :)];
end
if (params.stageTwoCosts.horizontalGrfSlopeError.isEnabled)
    maxAllowableError = ...
        params.stageTwoCosts.horizontalGrfSlopeError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceSlopeErrors(1, :)];
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceSlopeErrors(3, :)];
end
if (params.stageTwoCosts.springConstantErrorFromMean.isEnabled)
    maxAllowableError = ...
        params.stageTwoCosts.springConstantErrorFromMean.maxAllowableError;
    cost = [cost sqrt(1 / length(valuesStruct.springConstants)) * ...
        (1 / maxAllowableError) * ...
        calcSpringConstantsErrorFromMean(valuesStruct.springConstants)];
end
if (params.stageTwoCosts.dampingFactorErrorFromMean.isEnabled)
    maxAllowableError = ...
        params.stageTwoCosts.dampingFactorErrorFromMean.maxAllowableError;
    cost = [cost (1 / maxAllowableError) * ...
        calcDampingFactorsErrorFromMean(valuesStruct.dampingFactors)];
end
end
