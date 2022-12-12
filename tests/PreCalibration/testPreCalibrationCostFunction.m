%% PreCalibration Cost Function Testing

load('preCalibrationCostFunctionTesting.mat')
experimentalData.passiveMomentDataExists = 1;
experimentalData.params = [];

values = makePreCalibrationValuesAsStruct(parameterChange, experimentalData);
modeledValues = calcPreCalibrationModeledValues(values, experimentalData);
outputCost = calcPreCalibrationCost(values, modeledValues, experimentalData);

expectedNormalizedFiberLength = load('expectedNormalizedFiberLength.mat').normalizedFiberLength;
expectedNormalizedFiberLength = permute(expectedNormalizedFiberLength, [2 3 1]);
assertWithinRange(modeledValues.normalizedFiberLength, expectedNormalizedFiberLength, 1e-15)

expectedPassiveNormalizedFiberLength = load('expectedPassiveNormalizedFiberLength.mat').passiveNormalizedFiberLength;
expectedPassiveNormalizedFiberLength = permute(expectedPassiveNormalizedFiberLength, [2 3 1]);
assertWithinRange(modeledValues.passiveNormalizedFiberLength, expectedPassiveNormalizedFiberLength, 1e-15)

expectedPassiveForce = load('expectedPassiveForce.mat').passiveForce;
expectedPassiveForce = permute(expectedPassiveForce, [2 3 1]);
assertWithinRange(modeledValues.passiveForce, expectedPassiveForce, 1e-15)

expectedPassiveModelMoments = load('expectedPassiveModelMoments.mat').passiveModelMoments;
expectedPassiveModelMoments = permute(expectedPassiveModelMoments, [2 3 1]);
assertWithinRange(modeledValues.passiveModelMoments, expectedPassiveModelMoments, 1e-14)

expectedCost = load('expectedCost.mat').expectedCost;
assertWithinRange(sum(outputCost.^2), sum(expectedCost.^2), 1e-14)

%% Test individual cost function terms
load('preCalibrationCostFunctionTesting.mat')
experimentalData.passiveMomentDataExists = 1;

values = makePreCalibrationValuesAsStruct(parameterChange, experimentalData);
modeledValues = calcPreCalibrationModeledValues(values, experimentalData);

expectedIndividualCosts = load('expectedIndividualCosts.mat').cost;
expectedIndividualCosts.passiveMomentMatching = ...
    permute(-expectedIndividualCosts.passiveMomentMatching, [2 3 1]);
cost = calcPassiveMomentTrackingCost(modeledValues, experimentalData, ...
    struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.passiveMomentMatching(:), 1e-14)

cost =calcOptimalFiberLengthScaleFactorDeviationCost(values, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.optimalFiberLengthPenalty(:), 1e-15)

cost = calcTendonSlackLengthScaleFactorDeviationCost(values, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.tendonSlackLengthPenalty(:), 1e-15)

cost = calcMinimumNormalizedFiberLengthDeviationCost(modeledValues, ...
    experimentalData, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.minNormalizedFiberLength(:), 1e-15)

cost = calcMaximumNormalizedFiberLengthSimilarityCost(values, ...
    experimentalData, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.lMtildaMaxSetPointPenalty(:), 1e-15)

cost = calcMaximumNormalizedFiberLengthDeviationCost(modeledValues, ...
    values, experimentalData, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.maxNormalizedFiberLength(:), 1e-15)

cost = calcNormalizedFiberLengthMeanSimilarityCost(modeledValues, ...
    experimentalData, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.normalizedFiberLengthGroupSimilarity(:), 1e-15)

cost = calcMaximumMuscleStressPenaltyCost(values, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.maximumMuscleStressPenalty(:), 1e-15)

expectedIndividualCosts.minimizePassiveForce = ...
    permute(expectedIndividualCosts.minimizePassiveForce, [2 3 1]);
cost = calcPassiveForcePenaltyCost(modeledValues, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.minimizePassiveForce(:), 1e-15)