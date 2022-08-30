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

% outputCost = combineCostsIntoVector(experimentalData.costWeight, costs);
% outputCost(isnan(outputCost))=0;
% sumSquaredOutputCost = sum(outputCost.^2);
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

function cost = calcMtpCost(values, modeledValues, experimentalData, params)
cost = calcAllTrackingCosts(experimentalData, modeledValues.muscleMoments, modeledValues.normalizedFiberLength);
cost = cost + calcAllDeviationPenaltyCosts(values, experimentalData,  ...
    passiveForce);
cost = cost + calcNormalizedFiberLengthCurveChangesCost(modeledValues.normalizedFiberLength, ...
    experimentalData.normalizedFiberLength, experimentalData.normalizedFiberLengthPairs, ...
    experimentalData.errorCenters, experimentalData.maxAllowableErrors);
cost = cost + calcPairedMusclePenalties(values, ...
    experimentalData.activationPairs, experimentalData.errorCenters, ...
    experimentalData.maxAllowableErrors);
end