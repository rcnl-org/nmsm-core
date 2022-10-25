%% Core Cost Function Testing
clear

load('CoreCostFunctionTestingWithoutSynx.mat')
valuesStruct.electromechanicalDelays = electromechanicalDelays; 
valuesStruct.activationTimeConstants = activationTimeConstants;
valuesStruct.activationNonlinearityConstants = activationNonlinearityConstants;
valuesStruct.emgScaleFactors = emgScaleFactors; 
valuesStruct.optimalFiberLengthScaleFactors = optimalFiberLengthScaleFactors; 
valuesStruct.tendonSlackLengthScaleFactors = tendonSlackLengthScaleFactors;

% Muscle Excitation Calculation
muscleExcitations = calcMuscleExcitations(inputData.emgTime, ...
    inputData.emgSplines, valuesStruct.electromechanicalDelays, ...
    valuesStruct.emgScaleFactors);

muscleExcitationsExpected = load('muscleExcitationsExpected.mat').muscleExcitationsExpected;
muscleExcitationsExpected = permute(muscleExcitationsExpected, [2, 3, 1]);
assertWithinRange(muscleExcitations, muscleExcitationsExpected, 1e-15)

% Neural Activation Calculation
neuralActivations = calcNeuralActivations(muscleExcitations, ...
    valuesStruct.activationTimeConstants, inputData.emgTime, inputData.numPaddingFrames);

neuralActivationsExpected = load('neuralActivationsExpected.mat').neuralActivationsExpected;
neuralActivationsExpected = permute(neuralActivationsExpected, [2, 3, 1]);
assertWithinRange(neuralActivations, neuralActivationsExpected, 1e-15)

% Muscle Activation Calculation
muscleActivations = calcMuscleActivations(neuralActivations, valuesStruct.activationNonlinearityConstants);

muscleActivationsExpected = load('muscleActivationsExpected.mat').muscleActivationsExpected;
muscleActivationsExpected = permute(muscleActivationsExpected, [2, 3, 1]);
assertWithinRange(muscleActivations, muscleActivationsExpected, 1e-15)

% Normalized Muscle Fiber Lengths and Velocities Calculation
[normalizedFiberLength, normalizedFiberVelocity] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(inputData, ...
    valuesStruct.optimalFiberLengthScaleFactors, ...
    valuesStruct.tendonSlackLengthScaleFactors);

lMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').lMtildaExpected;
lMtildaExpected = permute(lMtildaExpected, [2, 3, 1]);
vMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').vMtildaExpected;
vMtildaExpected = permute(vMtildaExpected, [2, 3, 1]);
assertWithinRange(normalizedFiberLength, lMtildaExpected, 1e-15)
assertWithinRange(normalizedFiberVelocity, vMtildaExpected, 1e-15)

% Muscle Moments and Forces
passiveForce = calcPassiveForceLengthCurve(normalizedFiberLength, inputData.maxIsometricForce, inputData.pennationAngle);

muscleJointMoments = calcMuscleJointMoments(inputData, ...
    muscleActivations, normalizedFiberLength, ...
    normalizedFiberVelocity);

load('muscleMomentsAndForcesExpected.mat')
passiveForceExpected = permute(passiveForceExpected, [2, 3, 1]);
assertWithinRange(passiveForce, passiveForceExpected, 1e-12)
modelMomentsExpected = permute(modelMomentsExpected, [2, 3, 1]);
assertWithinRange(muscleJointMoments, modelMomentsExpected, 1e-13)

%%%%%%%%%%%%%%%%%%%%%%%% COST FN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modeledValues = calcMtpModeledValues(valuesStruct, inputData, struct());
inputData.costWeight = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
inputData.maxAllowableErrors = [2, 0.02, 0.1, 0.1, 0.1, 0.2, 0.1, 50, ...
    0.05, 0.1, 0.2, 2.5, 0.3, 0.3];
inputData.errorCenters = [0, 0.015, 0, 0, 0, 0.3, 0, 0, 0, 0, 0, 0, 0, 0];

expectedCost = load('individualCostsExpected.mat').individualCostsExpected;

momentTrackingCost = calcMomentTrackingCost(modeledValues, inputData, struct());
assertWithinRange(momentTrackingCost, sum(expectedCost.momentMatching .^ 2, "all"), 1e-13)

normalizedFiberLengthCost = calcNormalizedFiberLengthDeviationCost(modeledValues, inputData, struct());
assertWithinRange(normalizedFiberLengthCost, sum(expectedCost.lMtildaPenalty .^ 2, "all"), 0.001)

individualCosts = [];
individualCosts = calcAllDeviationPenaltyCosts(valuesStruct, inputData,  ...
    passiveForce, individualCosts);

assertWithinRange(individualCosts.activationTimePenalty, sum(expectedCost.activationTimePenalty .^ 2, "all"), 1e-13)
assertWithinRange(individualCosts.activationNonlinearityPenalty, sum(expectedCost.activationNonlinearityPenalty .^ 2, "all"), 1e-13)
assertWithinRange(individualCosts.optimalFiberLengthPenalty, sum(expectedCost.lMoPenalty .^ 2, "all"), 1e-13)
assertWithinRange(individualCosts.tendonSlackLengthPenalty, sum(expectedCost.lTsPenalty .^ 2, "all"), 1e-13)
assertWithinRange(individualCosts.emgScalePenalty, sum(expectedCost.emgScalePenalty .^ 2, "all"), 1e-13)
assertWithinRange(individualCosts.minPassiveForce, sum(expectedCost.minPassiveForce .^ 2, "all"), 1e-13)

individualCosts = calcLmTildaCurveChangesCost(normalizedFiberLength, ...
    inputData.normalizedFiberLength, inputData.lmtildaPairs, ...
    inputData.errorCenters, inputData.maxAllowableErrors, individualCosts);
% 
% assertWithinRange(individualCosts.lmtildaPairedSimilarity, ...
%     individualCostsExpected.lmtildaPairedSimilarity, 0.001)
% 
% individualCosts = calcPairedMusclePenalties(valuesStruct, ...
%     inputData.activationPairs, inputData.errorCenters, ...
%     inputData.maxAllowableErrors, individualCosts);
% 
% assertWithinRange(individualCosts.emgScalePairedSimilarity, ...
%     individualCostsExpected.emgScalePairedSimilarity, 0.001)
% assertWithinRange(individualCosts.tdelayPairedSimilarity, ...
%     individualCostsExpected.tdelayPairedSimilarity, 0.001)
% 




% %% Mtp Cost Calculation
% load('costFunctionTestingRound1.mat')
% 
% valuesStruct.isIncluded(1) = 0;
% valuesStruct.isIncluded(2) = 0;
% valuesStruct.isIncluded(3) = 0;
% valuesStruct.isIncluded(4) = 0;
% valuesStruct.isIncluded(5) = 1;
% valuesStruct.isIncluded(6) = 1;
% 
% numMuscles = inputData.nMusc;
% valuesStruct.primaryValues = zeros(6, numMuscles);
% valuesStruct.primaryValues(1, :) = 0.5; % electromechanical delay
% valuesStruct.primaryValues(2, :) = 1.5; % activation time
% valuesStruct.primaryValues(3, :) = 0.05; % activation nonlinearity
% valuesStruct.primaryValues(4, :) = 0.5; % EMG scale factors
% valuesStruct.primaryValues(5, :) = guess.Round1(1,1:numMuscles); % lmo scale factor
% valuesStruct.primaryValues(6, :) = guess.Round1(1,numMuscles+1:end); % lts scale factor
% 
% valuesStruct.secondaryValues = [];
% for i = 1:length(valuesStruct.isIncluded)
%    if(valuesStruct.isIncluded(i))
%        valuesStruct.secondaryValues = [valuesStruct.secondaryValues ...
%            valuesStruct.primaryValues(i, :)];
%    end
% end
% 
% [cost] = computeMuscleTendonCostFunction(valuesStruct, inputData, params);
% 
% load('costExpected.mat')
% assertWithinRange(cost, costExpected, 0.001)