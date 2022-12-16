% This function is part of the NMSM Pipeline, see file for full license.
%
% inputs:
%   model - Model
%   experimentalJointKinematics - 2D Array of double
%   coordinateColumns - 1D array of int of coordinate indexes
%
% (Array of double, Array of string, struct, struct) -> (struct)
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

function cost = calcVerticalGroundReactionCost(values, fieldNameOrder, ...
    inputs, params)
valuesStruct = unpackValues(values, inputs, fieldNameOrder);
if ~params.stageOne.bSplineCoefficients.isEnabled
        valuesStruct.bSplineCoefficientsVerticalSubset = ...
            inputs.bSplineCoefficientsVerticalSubset;
end
bSplineCoefficients = makeFullBSplineSet( ...
    valuesStruct.bSplineCoefficientsVerticalSubset, ...
    inputs.bSplineCoefficients);
[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    bSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, valuesStruct, ...
    modeledJointPositions, modeledJointVelocities, [1, 1, 0, 0], params);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;

cost = calcCost(inputs, modeledValues, valuesStruct, params);

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

function bSplineCoefficients = makeFullBSplineSet( ...
    valuesBSplineCoefficientsSubset, inputBSplineCoefficients)
bSplineCoefficients = inputBSplineCoefficients;
bSplineCoefficients(:, [1:4, 6]) = reshape( ...
    valuesBSplineCoefficientsSubset, [], 5);
end

function cost = calcCost(inputs, modeledValues, valuesStruct, params)
cost = [];
if (params.stageOneCosts.markerPositionError.isEnabled || ...
        params.stageOneCosts.markerSlopeError.isEnabled)
    [footMarkerPositionError, footMarkerSlopeError] = ...
        calcFootMarkerPositionAndSlopeError(inputs, modeledValues);
end
if (params.stageOneCosts.markerPositionError.isEnabled)
    maxAllowableError = ...
        params.stageOneCosts.markerPositionError.maxAllowableError;
    cost = [cost sqrt(1 / (12 * 101)) * (1 / maxAllowableError * ...
        footMarkerPositionError)];
end
if (params.stageOneCosts.markerSlopeError.isEnabled)
    maxAllowableError = ...
        params.stageOneCosts.markerSlopeError.maxAllowableError;
    cost = [cost sqrt(1 / (12 * 101)) * (1 / maxAllowableError * ...
        footMarkerSlopeError)];
end
if (params.stageOneCosts.coordinateCoefficientError.isEnabled)
    maxAllowableError = ...
        params.stageOneCosts.coordinateCoefficientError.maxAllowableError;
    cost = [cost sqrt(1 / (25 * 5)) * (1 / maxAllowableError * ...
        calcKinematicsBSplineCoefficientError(...
        valuesStruct.bSplineCoefficientsVerticalSubset))];
end
if (params.stageOneCosts.verticalGrfError.isEnabled || ...
        params.stageOneCosts.verticalGrfSlopeError.isEnabled)
    [groundReactionForceValueError, groundReactionForceSlopeError] = ...
        calcVerticalGroundReactionForceAndSlopeError(inputs, ...
        modeledValues);
end
if (params.stageOneCosts.verticalGrfError.isEnabled)
    maxAllowableError = ...
        params.stageOneCosts.verticalGrfError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceValueError];
end
if (params.stageOneCosts.verticalGrfSlopeError.isEnabled)
    maxAllowableError = ...
        params.stageOneCosts.verticalGrfSlopeError.maxAllowableError;
    cost = [cost sqrt(1 / 101) * (1 / maxAllowableError) * ...
        groundReactionForceSlopeError];
end
if (params.stageOneCosts.springConstantErrorFromMean.isEnabled)
    maxAllowableError = ...
        params.stageOneCosts.springConstantErrorFromMean.maxAllowableError;
    cost = [cost sqrt(1 / length(valuesStruct.springConstants)) * ...
        (1 / maxAllowableError) * ...
        calcSpringConstantsErrorFromMean(valuesStruct.springConstants)];
end
if (params.stageOneCosts.dampingFactorErrorFromMean.isEnabled)
    maxAllowableError = ...
        params.stageOneCosts.dampingFactorErrorFromMean.maxAllowableError;
    cost = [cost (1 / maxAllowableError) * ...
        calcDampingFactorsErrorFromMean(valuesStruct.dampingFactors)];
end
end

