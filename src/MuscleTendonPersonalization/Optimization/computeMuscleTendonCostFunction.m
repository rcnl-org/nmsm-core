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

function sumSquaredOutputCost = computeMuscleTendonCostFunction(values, ...
    primaryValues, isIncluded, experimentalData, params)

valuesStruct = makeValuesStruct(values, primaryValues, isIncluded);
modeledValues = calcMtpModeledValues(valuesStruct, experimentalData, params);
cost = calcMtpCost(modeledValues, experimentalData, params);

outputCost = combineCostsIntoVector(experimentalData.costWeight, costs);
outputCost(isnan(outputCost))=0;
sumSquaredOutputCost = sum(outputCost.^2);
end

function valuesStruct = makeValuesStruct(values, primaryValues, isIncluded)
valuesStruct.secondaryValues = values;
valuesStruct.primaryValues = primaryValues;
valuesStruct.isIncluded = isIncluded;
end

function modeledValues = calcMtpModeledValues(valuesStruct, experimentalData, params)

end

function calcMtpCost(modeledValues, experimentalData, params);
costs = calcAllTrackingCosts(experimentalData, modelMoments, normalizedFiberLength);
costs = calcAllDeviationPenaltyCosts(valuesStruct, experimentalData,  ...
    passiveForce, costs);
costs = calcNormalizedFiberLengthCurveChangesCost(normalizedFiberLength, ...
    experimentalData.normalizedFiberLength, experimentalData.normalizedFiberLengthPairs, ...
    experimentalData.errorCenters, experimentalData.maxAllowableErrors, costs);
costs = calcPairedMusclePenalties(valuesStruct, ...
    experimentalData.activationPairs, experimentalData.errorCenters, ...
    experimentalData.maxAllowableErrors, costs);
end