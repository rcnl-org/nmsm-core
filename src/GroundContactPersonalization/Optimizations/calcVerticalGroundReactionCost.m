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
bSplineCoefficients = makeFullBSplineSet( ...
    valuesStruct.bSplineCoefficientsVerticalSubset, ...
    inputs.bSplineCoefficients);
[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    bSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, valuesStruct, ...
    modeledJointPositions, modeledJointVelocities, [1, 1, 0, 0]);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;

cost = calcCost(inputs, modeledValues, valuesStruct);

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

function cost = calcCost(inputs, modeledValues, valuesStruct)
[footMarkerPositionError, footMarkerSlopeError] = ...
    calcFootMarkerPositionAndSlopeError(inputs, modeledValues);
cost = 1 / 0.05 * footMarkerPositionError;
% cost = [];
% cost = [cost 1000 * footMarkerSlopeError]; %12.8
% cost = [cost 1000 * calcKinematicCurveSlopeError(inputs, modeledValues, [1:4, 6])]; %27.3
[groundReactionForceValueError, groundReactionForceSlopeError] = ...
    calcVerticalGroundReactionForceAndSlopeError(inputs, modeledValues);
cost = [cost 1 / 1 * groundReactionForceValueError]; % 1 N
% cost = [cost 1 / 100 * groundReactionForceSlopeError]; %375970
cost = [cost 1 / 2000 * calcSpringConstantsErrorFromMean(valuesStruct.springConstants)]; % 10 N/m, try making looser bounds
cost = [cost 1 / 1e-6 * calcDampingFactorsErrorFromMean(valuesStruct.dampingFactors)]; % Allowable error to be determined, 1e-8?
% cost = [cost calcSpringConstantDeviationFromInitialValueError(inputs.springConstants, valuesStruct.springConstants)]; % Can remove these potentially redundant costs
% cost = [cost calcDampingFactorDeviationFromInitialValueError(inputs.dampingFactors, valuesStruct.dampingFactors)]; %
% cost = [cost calcSpringRestingLengthError(inputs.initialRestingSpringLength, valuesStruct.restingSpringLength)]; %

cost = cost / numel(cost);
end

