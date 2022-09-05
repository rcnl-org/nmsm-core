% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the cost associated to joint moment matching   %
% while penalizing muscle parameter differences and violations.           %
%
% data:
%   emgTime - 2D Array of double - frames+buffer x trials
%   emgSplines - 2D Array of double - trials x muscles
%   numPaddingFrames - double
%   momentArms - 4D Array of double - joints x frames x trials x muscles
%   muscleTendonLength - 3D Array of double - frames x trials x muscles
%   muscleTendonVelocity - 3D Array of double - frames x trials x muscles
%   maxVelocityFactor - double
%   pennationAngle - 3D Array of double - 1 x 1 x muscles
%   maxMuscleForce - 3D Array of double - 1 x 1 x muscles
%   optimalMuscleLength - 3D Array of double - 1 x 1 x muscles
%   tendonSlackLength - 3D Array of double - 1 x 1 x muscles
%
% (Array of number, struct) -> (Array of number)
% returns the cost for all rounds of the Muscle Tendon optimization

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

function cost = computeMuscleTendonCostFunction(secondaryValues, ...
    primaryValues, isIncluded, experimentalData, params)

values = makeValuesAsStruct(secondaryValues, primaryValues, isIncluded);
modeledValues = calcMtpModeledValues(values, experimentalData, params);
cost = calcMtpCost(values, modeledValues, experimentalData, params);

end

function values = makeValuesAsStruct(secondaryValues, primaryValues, isIncluded)
valuesHelper.secondaryValues = secondaryValues;
valuesHelper.primaryValues = primaryValues;
valuesHelper.isIncluded = isIncluded;
values.electromechanicalDelays = findCorrectMtpValues(1, valuesHelper);
values.activationTimeConstants = findCorrectMtpValues(2, valuesHelper);
values.activationNonlinearityConstants = findCorrectMtpValues(3, valuesHelper);
values.emgScaleFactors = findCorrectMtpValues(4, valuesHelper);
values.optimalFiberLengthScaleFactors = findCorrectMtpValues(5, valuesHelper);
values.tendonSlackLengthScaleFactors = findCorrectMtpValues(6, valuesHelper);
end

function output = findCorrectMtpValues(index, valuesStruct)
if (valuesStruct.isIncluded(index))
    [startIndex, endIndex] = findIsIncludedStartAndEndIndex( ...
        valuesStruct.primaryValues, valuesStruct.isIncluded, index);
    output = valuesStruct.secondaryValues(startIndex:endIndex);
else
    output = valuesStruct.primaryValues(index, :);
end
end

function totalCost = calcMtpCost(values, modeledValues, ...
    experimentalData, params)
totalCost = calcMomentTrackingCost(modeledValues, experimentalData, ...
    params);
totalCost = totalCost + calcActivationTimeConstantDeviationCost(values, ...
    modeledValues, experimentalData, params);
totalCost = totalCost + calcActivationNonlinearityDeviationCost(values, ...
    modeledValues, experimentalData, params);
totalCost = totalCost + calcOptimalFiberLengthDeviationCost(values, ...
    modeledValues, experimentalData, params);
totalCost = totalCost + calcTendonSlackLengthDeviationCost(values, ...
    modeledValues, experimentalData, params);
totalCost = totalCost + calcEmgScaleFactorDevationCost(values, ...
    modeledValues, experimentalData, params);
totalCost = totalCost + calcNormalizedFiberLengthDeviationCost(values, ...
    modeledValues, experimentalData, params);
totalCost = totalCost + calcNormalizedFiberLengthPairedSimilarityCost( ...
    values, modeledValues, experimentalData, params);
totalCost = totalCost + calcEmgScaleFactorPairedSimilarityCost( ...
    values, modeledValues, experimentalData, params);
totalCost = totalCost + calcElectromechanicalDelayPairedSimilarityCost( ...
    values, modeledValues, experimentalData, params);
totalCost = totalCost + calcPassiveForceCost(values, modeledValues, ...
    experimentalData, params);

end

function cost = calcMomentTrackingCost(modeledValues, ...
    experimentalData, params)
costWeight = valueOrAlternate(params, "momentTrackingCostWeight", 1);
errorCenter = valueOrAlternate(params, "momentTrackingErrorCenter", 0);
maximumAllowableError = valueOrAlternate(params, ...
    "momentTrackingMaximumAllowableError", 2);
cost = costWeight * calcTrackingCostTerm( ...
    modeledValues.muscleJointMoments, ...
    experimentalData.muscleJointMoments, errorCenter, ...
    maximumAllowableError);
end

function cost = calcActivationTimeConstantDeviationCost(values, params)
costWeight = valueOrAlternate(params, ...
    "activationTimeConstantDeviationCostWeight", 1);
errorCenter = valueOrAlternate(params, ...
    "activationTimeConstantDeviationErrorCenter", 0.15);
maximumAllowableError = valueOrAlternate(params, ...
    "activationTimeConstantDeviationMaximumAllowableError", 0.002);
cost = costWeight * calcDeviationCostTerm( ...
    values.activationTimeConstants, errorCenter, maximumAllowableError);
end

function cost = calcActivationNonlinearityDeviationCost(values, params)
costWeight = valueOrAlternate(params, ...
    "activationNonlinearityDeviationCostWeight", 1);
errorCenter = valueOrAlternate(params, ...
    "activationNonlinearityDeviationErrorCenter", 0);
maximumAllowableError = valueOrAlternate(params, ...
    "activationNonlinearityDeviationMaximumAllowableError", 0.1);
cost = costWeight * calcDeviationCostTerm( ...
    values.activationNonlinearityConstants, errorCenter, ...
    maximumAllowableError);
end

function cost = calcOptimalFiberLengthDeviationCost(values, params)
costWeight = valueOrAlternate(params, ...
    "optimalFiberLengthDeviationCostWeight", 1);
errorCenter = valueOrAlternate(params, ...
    "optimalFiberLengthDeviationErrorCenter", 0);
maximumAllowableError = valueOrAlternate(params, ...
    "optimalFiberLengthDeviationMaximumAllowableError", 0.1);
cost = costWeight * calcDeviationCostTerm( ...
    experimentalData.optimalFiberLength .* ...
    values.optimalFiberLengthScaleFactors, errorCenter, ...
    maximumAllowableError);
end

function cost = calcTendonSlackLengthDeviationCost(values, ...
    experimentalData, params)
costWeight = valueOrAlternate(params, ...
    "tendonSlackLengthDeviationCostWeight", 1);
errorCenter = valueOrAlternate(params, ...
    "tendonSlackLengthDeviationErrorCenter", 0);
maximumAllowableError = valueOrAlternate(params, ...
    "tendonSlackLengthDeviationMaximumAllowableError", 0.1);
cost = costWeight * calcDeviationCostTerm( ...
    experimentalData.tendonSlackLength .* ...
    values.tendonSlackLengthScaleFactors, errorCenter, ...
    maximumAllowableError);
end

function cost = calcEmgScaleFactorDevationCost(values, params)
costWeight = valueOrAlternate(params, ...
    "emgScaleFactorDeviationCostWeight", 1);
errorCenter = valueOrAlternate(params, ...
    "emgScaleFactorDeviationErrorCenter", 0.5);
maximumAllowableError = valueOrAlternate(params, ...
    "emgScaleFactorDeviationMaximumAllowableError", 0.3);

cost = costWeight * calcDeviationCostTerm(values.emgScaleFactors, ...
    errorCenter, maximumAllowableError);
end

function cost = calcNormalizedFiberLengthDeviationCost(values, ...
    modeledValues, experimentalData, params)
costWeight = valueOrAlternate(params, ...
    "normalizedFiberLengthDeviationCostWeight", 1);
errorCenter = valueOrAlternate(params, ...
    "normalizedFiberLengthDeviationErrorCenter", 0);
maximumAllowableError = valueOrAlternate(params, ...
    "normalizedFiberLengthDeviationMaximumAllowableError", 0.1);
[normalizedFiberLengthMagnitudeDeviation, ...
    normalizedFiberLengthShapeDeviation] = ...
    calcChangesInNormalizedMuscleFiberLengthCurves( ...
    modeledValues.normalizedFiberLength, ...
    experimentalData.normalizedFiberLengthExprimental, ...
    experimentalData.normalizedFiberLengthPairs);
normalizedFiberLengthMagnitudeDeviationCost = calcDeviationCostTerm( ...
    normalizedFiberLengthMagnitudeDeviation, errorCenter, ...
    maximumAllowableError);
normalizedFiberLengthShapeDeviationCost = calcDeviationCostTerm( ...
    normalizedFiberLengthShapeDeviation, errorCenter, ...
    maximumAllowableError);
cost = costWeight * (normalizedFiberLengthMagnitudeDeviationCost + ...
    normalizedFiberLengthShapeDeviationCost);
end

function cost = calcNormalizedFiberLengthPairedSimilarityCost( ...
    values, modeledValues, experimentalData, params)
costWeight = valueOrAlternate(params, "", 1);
errorCenter = valueOrAlternate(params, "", 0);
maximumAllowableError = valueOrAlternate(params, "", 0.05);
end

function cost = calcEmgScaleFactorPairedSimilarityCost( ...
    values, modeledValues, experimentalData, params)
costWeight = valueOrAlternate(params, "", 1);
errorCenter = valueOrAlternate(params, "", 0);
maximumAllowableError = valueOrAlternate(params, "", 0.1);
end

function cost = calcElectromechanicalDelayPairedSimilarityCost( ...
    values, modeledValues, experimentalData, params)
costWeight = valueOrAlternate(params, "", 1);
errorCenter = valueOrAlternate(params, "", 0);
maximumAllowableError = valueOrAlternate(params, "", 0.1);
end

function cost = calcPassiveForceCost(values, modeledValues, ...
    experimentalData, params)
costWeight = valueOrAlternate(params, "", 1);
errorCenter = valueOrAlternate(params, "", 0);
maximumAllowableError = valueOrAlternate(params, "", 30);
end