%% MuscleTendonLengthInitialization Cost Function Testing

load('muscleTendonLengthInitializationCostFunctionTesting.mat')
experimentalData.passiveMomentDataExists = 1;
experimentalData.muscleNames = string(ones(1, length(experimentalData.optimalFiberLength)));
experimentalData.maximumMuscleStressIsIncluded = true;
experimentalData.muscleTendonLength = experimentalData.gaitData.muscleTendonLength;
experimentalData.momentArms = experimentalData.gaitData.momentArms;
experimentalData.passiveMuscleTendonLength = experimentalData.passiveData.muscleTendonLength;
experimentalData.passiveMomentArms = experimentalData.passiveData.momentArms;
experimentalData.passiveData.inverseDynamicsMoments = experimentalData.passiveData.experimentalMoments;
experimentalData.params = [];
costTerms = ["passive_joint_moment", "optimal_muscle_fiber_length", "tendon_slack_length", "minimum_normalized_muscle_fiber_length", "maximum_normalized_muscle_fiber_length", "maximum_muscle_stress", "passive_muscle_force", "grouped_normalized_muscle_fiber_length", "grouped_maximum_normalized_muscle_fiber_length"];
for i = 1:length(costTerms)
    experimentalData.costTerms{i}.isEnabled = true;
    experimentalData.costTerms{i}.type = costTerms(i);
end

values = makeMuscleTendonLengthInitializationValuesAsStruct(parameterChange, experimentalData);
modeledValues = calcMuscleTendonLengthInitializationModeledValues(values, experimentalData);
outputCost = calcMuscleTendonLengthInitializationCost(values, modeledValues, experimentalData);

expectedNormalizedFiberLength = load('expectedNormalizedFiberLength.mat').normalizedFiberLength;
expectedNormalizedFiberLength = permute(expectedNormalizedFiberLength, [2 3 1]);
assertWithinRange(modeledValues.normalizedFiberLength, expectedNormalizedFiberLength, 1e-12)

expectedPassiveNormalizedFiberLength = load('expectedPassiveNormalizedFiberLength.mat').passiveNormalizedFiberLength;
expectedPassiveNormalizedFiberLength = permute(expectedPassiveNormalizedFiberLength, [2 3 1]);
assertWithinRange(modeledValues.passiveNormalizedFiberLength, expectedPassiveNormalizedFiberLength, 1e-12)

expectedPassiveForce = load('expectedPassiveForce.mat').passiveForce;
expectedPassiveForce = permute(expectedPassiveForce, [2 3 1]);
assertWithinRange(modeledValues.passiveForce, expectedPassiveForce, 1e-12)

expectedPassiveModelMoments = load('expectedPassiveModelMoments.mat').passiveModelMoments;
expectedPassiveModelMoments = permute(expectedPassiveModelMoments, [2 3 1]);
assertWithinRange(modeledValues.passiveModelMoments, expectedPassiveModelMoments, 1e-14)

expectedCost = load('expectedCost.mat').expectedCost;
assertWithinRange(sum(outputCost.^2), sum(expectedCost.^2), 1e-14)

%% Test individual cost function terms
load('muscleTendonLengthInitializationCostFunctionTesting.mat')
experimentalData.passiveMomentDataExists = 1;
experimentalData.muscleNames = string(ones(1, length(experimentalData.optimalFiberLength)));
experimentalData.maximumMuscleStressIsIncluded = true;
experimentalData.muscleTendonLength = experimentalData.gaitData.muscleTendonLength;
experimentalData.momentArms = experimentalData.gaitData.momentArms;
experimentalData.passiveMuscleTendonLength = experimentalData.passiveData.muscleTendonLength;
experimentalData.passiveMomentArms = experimentalData.passiveData.momentArms;
experimentalData.passiveData.inverseDynamicsMoments = experimentalData.passiveData.experimentalMoments;

values = makeMuscleTendonLengthInitializationValuesAsStruct(parameterChange, experimentalData);
modeledValues = calcMuscleTendonLengthInitializationModeledValues(values, experimentalData);

expectedIndividualCosts = load('expectedIndividualCosts.mat').cost;
expectedIndividualCosts.passiveMomentMatching = ...
    permute(-expectedIndividualCosts.passiveMomentMatching, [2 3 1]);
cost = calcPassiveMomentTrackingCost(modeledValues, experimentalData, ...
    struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.passiveMomentMatching(:), 1e-14)

cost = calcOptimalFiberLengthScaleFactorDeviationCost(values, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.optimalFiberLengthPenalty(:), 1e-12)

cost = calcTendonSlackLengthScaleFactorDeviationCost(values, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.tendonSlackLengthPenalty(:), 1e-12)

cost = calcMinimumNormalizedFiberLengthDeviationCost(modeledValues, ...
    experimentalData, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.minNormalizedFiberLength(:), 1e-12)

cost = calcMaximumNormalizedFiberLengthSimilarityCost(values, ...
    experimentalData, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.lMtildaMaxSetPointPenalty(:), 1e-12)

cost = calcMaximumNormalizedFiberLengthDeviationCost(modeledValues, ...
    values, experimentalData, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.maxNormalizedFiberLength(:), 1e-12)

cost = calcNormalizedFiberLengthMeanSimilarityCost(modeledValues, ...
    experimentalData, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.normalizedFiberLengthPairSimilarity(:), 1e-12)

cost = calcMaximumMuscleStressPenaltyCost(values, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.maximumMuscleStressPenalty(:), 1e-12)

expectedIndividualCosts.minimizePassiveForce = ...
    permute(expectedIndividualCosts.minimizePassiveForce, [2 3 1]);

cost = calcPassiveForcePenaltyCost(modeledValues, struct());
assertWithinRange(cost, ...
    expectedIndividualCosts.minimizePassiveForce(:), 1e-12)