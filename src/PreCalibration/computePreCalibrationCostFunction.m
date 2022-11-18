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
% load('preCalibrationCostFunctionTesting.mat')
values = getPreCalibrationValues(parameterChange, experimentalData);
modeledValues = calcPreCalibrationModeledValues(values, experimentalData);
outputCost = calcPreCalibrationCost(values, modeledValues, experimentalData);
end
function outputCost = calcPreCalibrationCost(values, modeledValues, experimentalData)

minNormalizedFiberLength = min(modeledValues.normalizedFiberLength, [], 3);
% minNormalizedFiberLength = permute(minNormalizedFiberLength, [2 3 1]);

%% Construct cost functions

%---Penalize passive moment tracking error
expD(:,1,:) = experimentalData.passiveData.experimentalMoments(1:4,1,:);
expD(:,2,:) = experimentalData.passiveData.experimentalMoments(5:8,4,:);
expD(:,3,:) = experimentalData.passiveData.experimentalMoments(9:12,5,:);
modD(:,1,:) = modeledValues.passiveModelMoments(1:4,1,:);
modD(:,2,:) = modeledValues.passiveModelMoments(5:8,4,:);
modD(:,3,:) = modeledValues.passiveModelMoments(9:12,5,:);

cost.passiveMomentMatching = calcTrackingCostTerm(expD, modD, ...
experimentalData.errorCenters(1), experimentalData.maxAllowableErrors(1));

% cost.passiveMomentMatching = calcTrackingCostTerm(...
%     experimentalData.experimentalPassiveMoments, modeledValues.passiveModelMoments, ...
%     experimentalData.errorCenters(1), experimentalData.maxAllowableErrors(1));

%---Penalize change of lmo and lts values
cost.optimalFiberLengthPenalty = calcPenalizeDifferencesCostTerm(values.optimalFiberLengthScaleFactors , experimentalData.errorCenters(2), ...
    experimentalData.maxAllowableErrors(2));
cost.tendonSlackLengthPenalty = calcPenalizeDifferencesCostTerm(values.tendonSlackLengthScaleFactors , ...
    experimentalData.errorCenters(3), experimentalData.maxAllowableErrors(3));
  
%---Penalize normalizedFiberLength lower than 0.5
for i = 1 : size(experimentalData.gaitData.muscleTendonLength,1)
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
maxNormalizedFiberLengthValues = values.maxNormalizedFiberLength(experimentalData.groupedMaxNormalizedFiberLength);
cost.lMtildaMaxSetPointPenalty = calcTrackingCostTerm(experimentalData.maxNormalizedMuscleFiberLength, ...
    maxNormalizedFiberLengthValues, experimentalData.errorCenters(10), experimentalData.maxAllowableErrors(10));

%---Penalize maximum normalizedFiberLength bigger than a certain value
maxNormalizedFiberLengthCost = max(modeledValues.normalizedFiberLength, [], 3);
cost.maxNormalizedFiberLength = calcTrackingCostTerm(maxNormalizedFiberLengthCost, maxNormalizedFiberLengthValues, ...
    experimentalData.errorCenters(5), experimentalData.maxAllowableErrors(5));

%---Penalize violation of normalizedFiberLength similarity between paired muscles
Ind = 1;
for i = 1:length(experimentalData.normalizedFiberLengthPairs)
    normalizedFiberLengthPairDeviation = abs(modeledValues.normalizedFiberLength(:,experimentalData.normalizedFiberLengthPairs{i},:) - ...
        mean(modeledValues.normalizedFiberLength(:,experimentalData.normalizedFiberLengthPairs{i},:), 2));
    normalizedFiberLengthPairSimilarity(Ind:Ind + size( ...
        experimentalData.normalizedFiberLengthPairs{i}, 2) - 1) = ...
        log(sum(exp(500*(normalizedFiberLengthPairDeviation)), [1 3]))/500;
    Ind = Ind + size(experimentalData.normalizedFiberLengthPairs{i}, 2);
end
cost.normalizedFiberLengthPairSimilarity = calcPenalizeDifferencesCostTerm(...
    normalizedFiberLengthPairSimilarity , ...
    experimentalData.errorCenters(9), experimentalData.maxAllowableErrors(9));

%---Penalize the change of SigmaScaleFactor
cost.maximumMuscleStressPenalty = calcPenalizeDifferencesCostTerm(values.maximumMuscleStressScaleFactor , ...
    experimentalData.errorCenters(6), experimentalData.maxAllowableErrors(6));

%---Minimize passive force
cost.minimizePassiveForce = calcPenalizeDifferencesCostTerm(modeledValues.passiveForce, ...
    experimentalData.errorCenters(7), experimentalData.maxAllowableErrors(7));

%---Minimize the change of maxIsometricForce
cost.maxIsometricForcePenalty = calcTrackingCostTerm(modeledValues.maxIsometricForce, experimentalData.maxIsometricForce, ...
    experimentalData.errorCenters(8), experimentalData.maxAllowableErrors(8));

outputCost = combineCostsIntoVector(experimentalData.costWeight, cost);
end

function modeledValues = calcPreCalibrationModeledValues(values, experimentalData)

modeledValues.maxIsometricForce = getMaxIsometricForce(experimentalData, values);

experimentalData.muscleTendonLength = experimentalData.gaitData.muscleTendonLength;
modeledValues.normalizedFiberLength = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(experimentalData, ...
    values.optimalFiberLengthScaleFactors, ...
    values.tendonSlackLengthScaleFactors);

experimentalData.muscleTendonLength = experimentalData.passiveData.muscleTendonLength;
modeledValues.passiveNormalizedFiberLength = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(experimentalData, ...
    values.optimalFiberLengthScaleFactors, ...
    values.tendonSlackLengthScaleFactors);

modeledValues.passiveForce = calcPassiveForceLengthCurve( ...
    modeledValues.normalizedFiberLength, ...
    modeledValues.maxIsometricForce, ...
    experimentalData.pennationAngle);

experimentalData.momentArms = experimentalData.passiveData.momentArms;
modeledValues.passiveModelMoments = calcPassiveMuscleMoments( ...
    experimentalData, modeledValues.maxIsometricForce, ...
    modeledValues.passiveNormalizedFiberLength);
end

function maxIsometricForce = getMaxIsometricForce(experimentalData, ...
    values)

scaledOptimalFiberLength = experimentalData.optimalFiberLength .* ...
    values.optimalFiberLengthScaleFactors;
scaledMaximumMuscleStress = experimentalData.maximumMuscleStress .* ...
    values.maximumMuscleStressScaleFactor;
if experimentalData.optimizeIsometricMaxForce
    maxIsometricForce = (experimentalData.muscleVolume ./ ...
        scaledOptimalFiberLength) * scaledMaximumMuscleStress;
else 
    maxIsometricForce = experimentalData.maxIsometricForce;
end
end

function values = getPreCalibrationValues(parameterChange, experimentalData)
numMuscles = getNumEnabledMuscles(experimentalData.model);
values.optimalFiberLengthScaleFactors = parameterChange(:, 1:numMuscles);
% values.scaledOptimalFiberLength = experimentalData.optimalFiberLength .* ...
%     values.optimalFiberLengthScaleFactors;
values.tendonSlackLengthScaleFactors = ...
    parameterChange(:, numMuscles + 1:2 * numMuscles);
% values.scaledTendonSlackLength = experimentalData.tendonSlackLength .* ...
%     values.tendonSlackLengthScaleFactors;
values.maxNormalizedFiberLength = ...
    parameterChange(:, 2 * numMuscles + 1: 2 * numMuscles + ...
    experimentalData.numMusclePairs + experimentalData.numMusclesIndividual);
if experimentalData.tasks.maximumMuscleStressIsIncluded
    values.maximumMuscleStressScaleFactor = parameterChange(:, end);
else
    values.maximumMuscleStressScaleFactor = 1;
end
end

% function passiveModelMoments = calcPassiveMuscleMoments(experimentalData, ...
%     maxIsometricForce, normalizedFiberLength)
% 
% expandedMaxIsometricForce = ones(1, 1, length(maxIsometricForce), 1);
% expandedMaxIsometricForce(1, 1, :, 1) = maxIsometricForce;
% 
% passiveForce = passiveForceLengthCurve(normalizedFiberLength);
% expandedPassiveForce = ones(size(passiveForce, 1), 1, ...
%     size(passiveForce, 2), size(passiveForce, 3));
% expandedPassiveForce(:, 1, :, :) = passiveForce;
% 
% parallelComponentOfPennationAngle = cos(experimentalData.pennationAngle);
% expandedParallelComponentOfPennationAngle = ones(1, 1, length( ...
%     parallelComponentOfPennationAngle), 1);
% expandedParallelComponentOfPennationAngle(1, 1, :, 1) = ...
%     parallelComponentOfPennationAngle;
% 
% passiveModelMoments = experimentalData.momentArms .* ...
%     expandedMaxIsometricForce .* expandedPassiveForce .* ...
%     expandedParallelComponentOfPennationAngle;
% 
% passiveModelMoments = permute(sum(passiveModelMoments, 3), [1 2 4 3]);
% end

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