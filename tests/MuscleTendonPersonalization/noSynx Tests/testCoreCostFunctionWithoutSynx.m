%% Core Cost Function Testing
clear

load('CoreCostFunctionTestingWithoutSynx.mat')
values.electromechanicalDelays = electromechanicalDelays; 
values.activationTimeConstants = activationTimeConstants;
values.activationNonlinearityConstants = activationNonlinearityConstants;
values.emgScaleFactors = emgScaleFactors; 
values.optimalFiberLengthScaleFactors = optimalFiberLengthScaleFactors; 
values.tendonSlackLengthScaleFactors = tendonSlackLengthScaleFactors;

experimentalData = inputData;
% Muscle Excitation Calculation
muscleExcitations = calcMuscleExcitations(experimentalData.emgTime, ...
    experimentalData.emgSplines, values.electromechanicalDelays, ...
    values.emgScaleFactors);

eps

muscleExcitationsExpected = load('muscleExcitationsExpected.mat').muscleExcitationsExpected;
muscleExcitationsExpected = permute(muscleExcitationsExpected, [2, 3, 1]);
assertWithinRange(muscleExcitations, muscleExcitationsExpected, 1e-12)

% Neural Activation Calculation
neuralActivations = calcNeuralActivations(muscleExcitations, ...
    values.activationTimeConstants, experimentalData.emgTime, ...
    experimentalData.numPaddingFrames);

neuralActivationsExpected = load('neuralActivationsExpected.mat').neuralActivationsExpected;
neuralActivationsExpected = permute(neuralActivationsExpected, [2, 3, 1]);
assertWithinRange(neuralActivations, neuralActivationsExpected, 1e-12)

% Muscle Activation Calculation
muscleActivations = calcMuscleActivations( ...
    neuralActivations, values.activationNonlinearityConstants);

muscleActivationsExpected = load('muscleActivationsExpected.mat').muscleActivationsExpected;
muscleActivationsExpected = permute(muscleActivationsExpected, [2, 3, 1]);
assertWithinRange(muscleActivations, muscleActivationsExpected, 1e-12)

% Normalized Muscle Fiber Lengths and Velocities Calculation
[normalizedFiberLength, normalizedFiberVelocity] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(experimentalData, ...
    values.optimalFiberLengthScaleFactors, ...
    values.tendonSlackLengthScaleFactors);

lMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').lMtildaExpected;
lMtildaExpected = permute(lMtildaExpected, [2, 3, 1]);
vMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').vMtildaExpected;
vMtildaExpected = permute(vMtildaExpected, [2, 3, 1]);
assertWithinRange(normalizedFiberLength, lMtildaExpected, 1e-12)
assertWithinRange(normalizedFiberVelocity, vMtildaExpected, 1e-12)

% Muscle Moments and Forces
passiveForce = calcPassiveForceLengthCurve( ...
    normalizedFiberLength, ...
    experimentalData.maxIsometricForce, ...
    experimentalData.pennationAngle);
muscleJointMoments = calcMuscleJointMoments(inputData, ...
    muscleActivations, normalizedFiberLength, ...
    normalizedFiberVelocity);

load('muscleMomentsAndForcesExpected.mat')
passiveForceExpected = permute(passiveForceExpected, [2, 3, 1]);
assertWithinRange(passiveForce, passiveForceExpected, 1e-12)
modelMomentsExpected = permute(modelMomentsExpected, [2, 3, 1]);
assertWithinRange(muscleJointMoments, modelMomentsExpected, 1e-13)

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cost Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experimentalData.costWeight = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
experimentalData.maxAllowableErrors = [2, 0.02, 0.1, 0.1, 0.1, 0.2, 0.1, 50, ...
    0.05, 0.1, 0.2, 2.5, 0.3, 0.3];
experimentalData.errorCenters = [0, 0.015, 0, 0, 0, 0.3, 0, 0, 0, 0, 0, 0, 0, 0];
modeledValues = calcMtpModeledValues(values, experimentalData, struct());

expectedCost = load('individualCostsExpected.mat').individualCostsExpected;

momentTrackingCost = calcMomentTrackingCost(modeledValues, experimentalData, struct());
assertWithinRange(momentTrackingCost, sum(expectedCost.momentMatching .^ 2, "all"), 1e-13)

activationTimePenalty = calcActivationTimeConstantDeviationCost(values, struct());
assertWithinRange(activationTimePenalty, sum(expectedCost.activationTimePenalty .^ 2, "all"), 1e-13)

activationNonlinearityPenalty = calcActivationNonlinearityDeviationCost(values, struct());
assertWithinRange(activationNonlinearityPenalty, sum(expectedCost.activationNonlinearityPenalty .^ 2, "all"), 1e-13)

optimalFiberLengthPenalty = calcOptimalFiberLengthDeviationCost(values, experimentalData, struct());
assertWithinRange(optimalFiberLengthPenalty, sum(expectedCost.lMoPenalty .^ 2, "all"), 1e-13)

tendonSlackLengthPenalty = calcTendonSlackLengthDeviationCost(values, experimentalData, struct());
assertWithinRange(tendonSlackLengthPenalty, sum(expectedCost.lTsPenalty .^ 2, "all"), 1e-13)

emgScalePenalty = calcEmgScaleFactorDevationCost(values, struct());
assertWithinRange(emgScalePenalty, sum(expectedCost.emgScalePenalty .^ 2, "all"), 1e-13)

normalizedFiberLengthCost = calcNormalizedFiberLengthDeviationCost(modeledValues, inputData, struct());
assertWithinRange(normalizedFiberLengthCost, sum(expectedCost.lMtildaPenalty .^ 2, "all"), 1e-13)

lmtildaPairedSimilarity = calcNormalizedFiberLengthPairedSimilarityCost( ...
    modeledValues, experimentalData, struct());
assertWithinRange(lmtildaPairedSimilarity, sum(expectedCost.lmtildaPairedSimilarity .^ 2, "all"), 1e-13)

emgScalePairedSimilarity = calcEmgScaleFactorPairedSimilarityCost(values, experimentalData, struct());
assertWithinRange(emgScalePairedSimilarity, sum(expectedCost.emgScalePairedSimilarity .^ 2, "all"), 1e-13)

tdelayPairedSimilarity = calcElectromechanicalDelayPairedSimilarityCost(values, experimentalData, struct());
assertWithinRange(tdelayPairedSimilarity, sum(expectedCost.tdelayPairedSimilarity .^ 2, "all"), 1e-13)

minPassiveForce = calcPassiveForceCost(modeledValues, struct());
assertWithinRange(minPassiveForce, sum(expectedCost.minPassiveForce .^ 2, "all"), 1e-13)

%%%%%%%%%%%%%%%%%%%%%%%% Total Cost function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params = struct();
totalCost = calcMomentTrackingCost(modeledValues, experimentalData, ...
    params);
totalCost = totalCost + calcActivationTimeConstantDeviationCost(values, ...
    params);
totalCost = totalCost + calcActivationNonlinearityDeviationCost(values, ...
    params);
totalCost = totalCost + calcOptimalFiberLengthDeviationCost(values, ...
    experimentalData, params);
totalCost = totalCost + calcTendonSlackLengthDeviationCost(values, ...
    experimentalData, params);
totalCost = totalCost + calcEmgScaleFactorDevationCost(values, params);
totalCost = totalCost + calcNormalizedFiberLengthDeviationCost( ...
    modeledValues, experimentalData, params);
totalCost = totalCost + calcNormalizedFiberLengthPairedSimilarityCost( ...
    modeledValues, experimentalData, params);
totalCost = totalCost + calcEmgScaleFactorPairedSimilarityCost( ...
    values, experimentalData, params);
totalCost = totalCost + calcElectromechanicalDelayPairedSimilarityCost( ...
    values, experimentalData, params);
totalCost = totalCost + calcPassiveForceCost(modeledValues, params);

load('costExpected.mat')
assertWithinRange(totalCost, costExpected, 0.001)