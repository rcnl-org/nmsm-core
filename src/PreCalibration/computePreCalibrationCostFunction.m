% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of number, struct) -> (Array of number)
% returns the cost for PreCalibration optimization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function outputCost = computePreCalibrationCostFunction(parameterChange, ...
    experimentalData)

valueStruct = getPreCalibrationValues(parameterChange, experimentalData);
maxIsometricForce = getMaxIsometricForce(experimentalData, valueStruct);

% Calculate passive moments and normalizedFiberLength 
normalizedFiberLength = calcNormalizedMusceFiberLengths(...
    valueStruct.scaledOptimalFiberLength, ...
    valueStruct.scaledTendonSlackLength, ...
    experimentalData.muscleTendonLength, ...
    experimentalData.pennationAngle);

passiveNormalizedFiberLength = calcNormalizedMusceFiberLengths( ...
    valueStruct.scaledOptimalFiberLength, ...
    valueStruct.scaledTendonSlackLength, ...
    experimentalData.passiveMuscleTendonLength, ...
    experimentalData.pennationAngle);

[passiveForce, ~] = ...
    calcPassiveMuscleMomentsAndForces(experimentalData.pennationAngle, ...
    maxIsometricForce, normalizedFiberLength, ...
    experimentalData.muscleTendonLength, ...
    experimentalData.momentArms);

[~, passiveModelMoments] = ...
    calcPassiveMuscleMomentsAndForces(experimentalData.pennationAngle, ...
    maxIsometricForce, passiveNormalizedFiberLength, ...
    experimentalData.passiveMuscleTendonLength, ...
    experimentalData.passiveMomentArms);

minNormalizedFiberLength = min(normalizedFiberLength);
minNormalizedFiberLength = permute(minNormalizedFiberLength, [2 3 1]);

%% Construct cost functions

%---Penalize passive moment tracking error
cost.passiveMomentMatching = calcTrackingCostTerm(...
    experimentalData.experimentalPassiveMoments, passiveModelMoments, ...
    experimentalData.errorCenters(1), experimentalData.maxAllowableErrors(1));

%---Penalize change of lmo and lts values
cost.optimalFiberLengthPenalty = calcPenalizeDifferencesCostTerm(valueStruct.optimalFiberLengthScaleFactors , experimentalData.errorCenters(2), ...
    experimentalData.maxAllowableErrors(2));
cost.tendonSlackLengthPenalty = calcPenalizeDifferencesCostTerm(valueStruct.tendonSlackLengthScaleFactors , ...
    experimentalData.errorCenters(3), experimentalData.maxAllowableErrors(3));
  
%---Penalize normalizedFiberLength lower than 0.5
for i = 1 : size(experimentalData.muscleTendonLength,2)
    for ii = 1 : getNumEnabledMuscles(experimentalData.model)
        if minNormalizedFiberLength(i, ii) < experimentalData.minNormalizedMuscleFiberLength 
            minNormalizedFiberLengthError(i, ii) = minNormalizedFiberLength(i, ii) - ...
            experimentalData.minNormalizedMuscleFiberLength;
        else
            minNormalizedFiberLengthError(i, ii) = 0;
        end
    end 
end
cost.minNormalizedFiberLength = calcPenalizeDifferencesCostTerm(minNormalizedFiberLengthError , ...
    experimentalData.errorCenters(4), experimentalData.maxAllowableErrors(4));

%---Penalize distance of values for maximum normalizedFiberLength penalty from 1
maxNormalizedFiberLengthValues = valueStruct.maxNormalizedFiberLength(experimentalData.groupedMaxNormalizedFiberLength);
cost.lMtildaMaxSetPointPenalty = calcTrackingCostTerm(experimentalData.maxNormalizedMuscleFiberLength, ...
    maxNormalizedFiberLengthValues, experimentalData.errorCenters(10), experimentalData.maxAllowableErrors(10));

%---Penalize maximum normalizedFiberLength bigger than a certain value
maxNormalizedFiberLengthCost = permute(max(normalizedFiberLength),[2 3 1]);
cost.maxNormalizedFiberLength = calcTrackingCostTerm(maxNormalizedFiberLengthCost, maxNormalizedFiberLengthValues, ...
    experimentalData.errorCenters(5), experimentalData.maxAllowableErrors(5));

%---Penalize violation of normalizedFiberLength similarity between paired muscles
Ind = 1;
for i = 1:length(experimentalData.normalizedFiberLengthPairs)
    normalizedFiberLengthPairDeviation = abs(normalizedFiberLength(:,:,experimentalData.normalizedFiberLengthPairs{i}) - ...
        mean(normalizedFiberLength(:,:,experimentalData.normalizedFiberLengthPairs{i}), 3));
    normalizedFiberLengthPairSimilarity(:, :, Ind:Ind + size( ...
        experimentalData.normalizedFiberLengthPairs{i}, 2) - 1) = ...
        log(sum(exp(500*(normalizedFiberLengthPairDeviation)), [1 2]))/500;
    Ind = Ind + size(experimentalData.normalizedFiberLengthPairs{i}, 2);
end
cost.normalizedFiberLengthPairSimilarity = calcPenalizeDifferencesCostTerm(permute(...
    normalizedFiberLengthPairSimilarity, [3 1 2]) , ...
    experimentalData.errorCenters(9), experimentalData.maxAllowableErrors(9));

%---Penalize the change of SigmaScaleFactor
cost.maximumMuscleStressPenalty = calcPenalizeDifferencesCostTerm(valueStruct.maximumMuscleStressScaleFactor , ...
    experimentalData.errorCenters(6), experimentalData.maxAllowableErrors(6));

%---Minimize passive force
cost.minimizePassiveForce = calcPenalizeDifferencesCostTerm(passiveForce, ...
    experimentalData.errorCenters(7), experimentalData.maxAllowableErrors(7));

%---Minimize the change of maxIsometricForce
cost.maxIsometricForcePenalty = calcTrackingCostTerm(maxIsometricForce, experimentalData.maxIsometricForce, ...
    experimentalData.errorCenters(8), experimentalData.maxAllowableErrors(8));

outputCost = combineCostsIntoVector(experimentalData.costWeight, cost);
end

function maxIsometricForce = getMaxIsometricForce(experimentalData, ...
    valueStruct)

if experimentalData.optimizeIsometricMaxForce
    maxIsometricForce = (experimentalData.muscleVolume ./ ...
        valueStruct.scaledOptimalFiberLength) * ...
        valueStruct.scaledMaximumMuscleStress;
else 
    maxIsometricForce = experimentalData.maxIsometricForce;
end
end

function valueStruct = getPreCalibrationValues(parameterChange, experimentalData)
numMuscles = getNumEnabledMuscles(experimentalData.model);
valueStruct.optimalFiberLengthScaleFactors = ...
    parameterChange(:, 1:numMuscles);
valueStruct.scaledOptimalFiberLength = ...
    experimentalData.optimalFiberLength .* ...
    valueStruct.optimalFiberLengthScaleFactors;
valueStruct.tendonSlackLengthScaleFactors = ...
    parameterChange(:, numMuscles + 1:2 * numMuscles);
valueStruct.scaledTendonSlackLength = ...
    experimentalData.tendonSlackLength .* ...
    valueStruct.tendonSlackLengthScaleFactors;
valueStruct.maxNormalizedFiberLength = ...
    parameterChange(:, 2 * numMuscles + 1: 2 * numMuscles + ...
    experimentalData.numMusclePairs + experimentalData.numMusclesIndividual);
if experimentalData.tasks.maximumMuscleStressIsIncluded
    valueStruct.maximumMuscleStressScaleFactor = parameterChange(:, end);
else
    valueStruct.maximumMuscleStressScaleFactor = 1;
end
valueStruct.scaledMaximumMuscleStress = ...
    experimentalData.maximumMuscleStress .* ...
    valueStruct.maximumMuscleStressScaleFactor;
end

function normalizedFiberLength = calcNormalizedMusceFiberLengths(optimalFiberLength, tendonSlackLength, ...
    muscleTendonLength, pennationAngle)

onesCol = ones(size(muscleTendonLength, 1), size(muscleTendonLength, 2));
% Normalized muscle fiber length, equation 2 from Meyer 2017
normalizedFiberLength = ( muscleTendonLength - onesCol .* permute(tendonSlackLength, [1 3 2]) ) ./ (onesCol .* ( ...
    permute(optimalFiberLength, [1 3 2]) .* permute( cos(pennationAngle), [1 3 2]) ) );
end

function [passiveForce, passiveModelMoments] = ...
    calcPassiveMuscleMomentsAndForces(pennationAngle, maxIsometricForce, normalizedFiberLength, ...
    muscleTendonLength, momentArms)

% Preallocation of Memory
passiveMuscleMoments = zeros([size(muscleTendonLength), size(momentArms, 4)]); 
onesCol = ones(size(muscleTendonLength, 1), size(muscleTendonLength, 2));
passiveForce = onesCol .* (permute(maxIsometricForce, [1 3 2])  .* ...
    permute(cos(pennationAngle), [1 3 2]) ) .* ...
    passiveForceLengthCurve(normalizedFiberLength);
    % equation 1 from Meyer 2017
    for i=1:size(momentArms, 4)
        passiveMuscleMoments(:, :, :, i) = momentArms(:, :, :, ...
            i) .* passiveForce;
    end
passiveModelMoments = permute(sum(passiveMuscleMoments, 3), [1 2 4 3]);
end

function output = combineCostsIntoVector(costWeight, costs)
output = [ ...
    %Penalize passive moment tracking error
    sqrt(costWeight(1)).* costs.passiveMomentMatching(:); ...  
    % Penalize change of lmo values
    sqrt(costWeight(2)).* costs.optimalFiberLengthPenalty(:); ...
    % Penalize change of lts values
    sqrt(costWeight(3)).* costs.tendonSlackLengthPenalty(:); ...
    % Penalize normalizedFiberLength lower than set point
    sqrt(costWeight(4)).* costs.minNormalizedFiberLength(:);... 
    % Penalize distance of values for maximum normalizedFiberLength penalty from 1
    sqrt(costWeight(5)).* costs.lMtildaMaxSetPointPenalty(:);...    
    % Penalize maximum normalizedFiberLength bigger than a certain value
    sqrt(costWeight(6)).* costs.maxNormalizedFiberLength(:);... 
    % Penalize violation of normalizedFiberLength similarity between paired muscles
    sqrt(costWeight(7)).* costs.normalizedFiberLengthPairSimilarity(:);...    
    % Penalize the change of SigmaScaleFactor
    sqrt(costWeight(8)).* costs.maximumMuscleStressPenalty(:);...
    % Minimize passive force
    sqrt(costWeight(9)).* costs.minimizePassiveForce(:);...  
    % Minimize the change of maxIsometricForce
    sqrt(costWeight(10)).*costs.maxIsometricForcePenalty(:);...         
    ];
end

function cost = calcPenalizeDifferencesCostTerm(value, ...
    errorCenter, maxAllowableError)

cost = ((value - errorCenter) ./ maxAllowableError) ./ ...
    sqrt(size(value(:), 1));
end

function cost = calcTrackingCostTerm(modelValue, experimentalValue, ...
    errorCenter, maxAllowableError)

errorMatching = modelValue - experimentalValue;
cost = ((errorMatching - errorCenter) ./ maxAllowableError) ./ ...
    sqrt(size(errorMatching(:), 1));
end