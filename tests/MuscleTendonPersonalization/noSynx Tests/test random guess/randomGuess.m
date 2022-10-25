%% Core Cost Function Testing

% load (load('guess.mat')) and
% run secondaryValues = guess;

%test with calcMtpModeledValues
muscleExcitationsExpected = load('muscleExcitationsExpected.mat').muscleExcitationsExpected;
muscleExcitationsExpected = permute(muscleExcitationsExpected, [2, 3, 1]);
assertWithinRange(muscleExcitations, muscleExcitationsExpected, 1e-15)

neuralActivationsExpected = load('neuralActivationsExpected.mat').neuralActivationsExpected;
neuralActivationsExpected = permute(neuralActivationsExpected, [2, 3, 1]);
assertWithinRange(neuralActivations, neuralActivationsExpected, 1e-15)

muscleActivationsExpected = load('muscleActivationsExpected.mat').muscleActivationsExpected;
muscleActivationsExpected = permute(muscleActivationsExpected, [2, 3, 1]);
assertWithinRange(modeledValues.muscleActivations, muscleActivationsExpected, 1e-15)

lMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').lMtildaExpected;
lMtildaExpected = permute(lMtildaExpected, [2, 3, 1]);
vMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').vMtildaExpected;
vMtildaExpected = permute(vMtildaExpected, [2, 3, 1]);
assertWithinRange(modeledValues.normalizedFiberLength, lMtildaExpected, 1e-15)
assertWithinRange(modeledValues.normalizedFiberVelocity, vMtildaExpected, 1e-15)

load('muscleMomentsAndForcesExpected.mat')
passiveForceExpected = permute(passiveForceExpected, [2, 3, 1]);
assertWithinRange(modeledValues.passiveForce, passiveForceExpected, 1e-11)
modelMomentsExpected = permute(modelMomentsExpected, [2, 3, 1]);
assertWithinRange(modeledValues.muscleJointMoments, modelMomentsExpected, 1e-11)

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cost Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% test with calcMtpModeledValues
totalCost1 = calcMomentTrackingCost(modeledValues, experimentalData, params);
totalCost2 = calcActivationTimeConstantDeviationCost(values, params);
totalCost3 = calcActivationNonlinearityDeviationCost(values, params);
totalCost4 = calcOptimalFiberLengthDeviationCost(values, experimentalData, ...
    params);
totalCost5 = calcTendonSlackLengthDeviationCost(values, experimentalData, ...
    params);
totalCost6 = calcEmgScaleFactorDevationCost(values, params);
totalCost7 = calcNormalizedFiberLengthDeviationCost( modeledValues, ...
    experimentalData, params);
totalCost8 = calcNormalizedFiberLengthPairedSimilarityCost(modeledValues, ...
    experimentalData, params);
totalCost9 = calcEmgScaleFactorPairedSimilarityCost(values, ...
    experimentalData, params);
totalCost10 = calcElectromechanicalDelayPairedSimilarityCost(values, ...
    experimentalData, params);
totalCost11 = calcPassiveForceCost(modeledValues, params);

expectedCost = load('individualCostsExpected.mat').individualCostsExpected;

momentTrackingCost = sum(expectedCost.momentMatching .^ 2, "all");
assertWithinRange(totalCost1, momentTrackingCost, 1e-12)

activationTimePenalty = sum(expectedCost.activationTimePenalty .^ 2, "all");
assertWithinRange(totalCost2, activationTimePenalty,  1e-12)

activationNonlinearityPenalty = sum(expectedCost.activationNonlinearityPenalty .^ 2, "all");
assertWithinRange(totalCost3, activationNonlinearityPenalty,  1e-12)

optimalFiberLengthPenalty = sum(expectedCost.lMoPenalty .^ 2, "all");
assertWithinRange(totalCost4, optimalFiberLengthPenalty,  1e-12)

tendonSlackLengthPenalty = sum(expectedCost.lTsPenalty .^ 2, "all");
assertWithinRange(totalCost5, tendonSlackLengthPenalty,  1e-12)

emgScalePenalty = sum(expectedCost.emgScalePenalty .^ 2, "all");
assertWithinRange(totalCost6, emgScalePenalty,  1e-12)

normalizedFiberLengthCost = sum(expectedCost.lMtildaPenalty .^ 2, "all");
assertWithinRange(totalCost7, normalizedFiberLengthCost,  1e-12)

lmtildaPairedSimilarity = sum(expectedCost.lmtildaPairedSimilarity .^ 2, "all");
assertWithinRange(totalCost8, lmtildaPairedSimilarity,  1e-12)

emgScalePairedSimilarity = sum(expectedCost.emgScalePairedSimilarity .^ 2, "all");
assertWithinRange(totalCost9, emgScalePairedSimilarity,  1e-12)

tdelayPairedSimilarity = sum(expectedCost.tdelayPairedSimilarity .^ 2, "all");
assertWithinRange(totalCost10, tdelayPairedSimilarity,  1e-12)

minPassiveForce = sum(expectedCost.minPassiveForce .^ 2, "all");
assertWithinRange(totalCost11, minPassiveForce,  1e-12)

%%%%%%%%%%%%%%%%%%%%%%%% Total Cost function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('costExpected.mat')
assertWithinRange(totalCost, costExpected, 1e-12)