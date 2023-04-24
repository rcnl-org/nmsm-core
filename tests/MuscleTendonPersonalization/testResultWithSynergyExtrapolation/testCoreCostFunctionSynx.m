%% Core Cost Function Testing
clear

load('initialValues.mat')
values.electromechanicalDelays = electromechanicalDelays;
values.activationTimeConstants = activationTimeConstants;
values.activationNonlinearityConstants = activationNonlinearityConstants;
values.emgScaleFactors = emgScaleFactors;
values.optimalFiberLengthScaleFactors = optimalFiberLengthScaleFactors;
values.tendonSlackLengthScaleFactors = tendonSlackLengthScaleFactors;
values.synergyWeights = synergyWeights;

experimentalData = inputData;
experimentalData.inverseDynamicsMoments = experimentalData.experimentalMoments;

%%%%%%%%%%%%%%%%%%%%%%%% calcMtpSynXModeledValues %%%%%%%%%%%%%%%%%%%%%%%%

[muscleExcitations, modeledValues.muscleExcitationsNoTDelay] = ...
    calcMuscleExcitationsSynX(experimentalData, ...
    values.electromechanicalDelays, values.emgScaleFactors, ...
    values.synergyWeights, experimentalData.synergyExtrapolation);
neuralActivations = calcNeuralActivations(muscleExcitations, ...
    values.activationTimeConstants, experimentalData.emgTime, ...
    experimentalData.numPaddingFrames);
modeledValues.muscleActivations = calcMuscleActivations( ...
    neuralActivations, values.activationNonlinearityConstants);
[modeledValues.normalizedFiberLength, ...
    modeledValues.normalizedFiberVelocity] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(experimentalData, ...
    values.optimalFiberLengthScaleFactors, ...
    values.tendonSlackLengthScaleFactors);
modeledValues.passiveForce = calcPassiveForceLengthCurve( ...
    modeledValues.normalizedFiberLength, ...
    experimentalData.maxIsometricForce, ...
    experimentalData.pennationAngle);
modeledValues.muscleJointMoments = calcMuscleJointMoments( ...
    experimentalData, modeledValues.muscleActivations, ...
    modeledValues.normalizedFiberLength, ...
    modeledValues.normalizedFiberVelocity);

synxMuscleExcitationsExpected = load('synxMuscleExcitationsExpected.mat').muscleExcitationsExpected;
synxMuscleExcitationsExpected = permute(synxMuscleExcitationsExpected, [2, 3, 1]);
assertWithinRange(muscleExcitations, synxMuscleExcitationsExpected, 1e-12)

synxNeuralActivationsExpected = load('synxNeuralActivationsExpected.mat').neuralActivationsExpected;
synxNeuralActivationsExpected = permute(synxNeuralActivationsExpected, [2, 3, 1]);
assertWithinRange(neuralActivations, synxNeuralActivationsExpected, 1e-12)

synxMuscleActivationsExpected = load('synxMuscleActivationsExpected.mat').muscleActivationsExpected;
synxMuscleActivationsExpected = permute(synxMuscleActivationsExpected, [2, 3, 1]);
assertWithinRange(modeledValues.muscleActivations, synxMuscleActivationsExpected, 1e-12)

lMtildaExpected = load('synxNormalizedMuscleLengthandVelocitiesExpected.mat').lMtildaExpected;
lMtildaExpected = permute(lMtildaExpected, [2, 3, 1]);
assertWithinRange(modeledValues.normalizedFiberLength, lMtildaExpected, 1e-12)
vMtildaExpected = load('synxNormalizedMuscleLengthandVelocitiesExpected.mat').vMtildaExpected;
vMtildaExpected = permute(vMtildaExpected, [2, 3, 1]);
assertWithinRange(modeledValues.normalizedFiberVelocity, vMtildaExpected, 1e-12)

load('synxMuscleMomentsAndForcesExpected.mat')
passiveForceExpected = permute(passiveForceExpected, [2, 3, 1]);
assertWithinRange(modeledValues.passiveForce, passiveForceExpected, 1e-11)
modelMomentsExpected = permute(modelMomentsExpected, [2, 3, 1]);
assertWithinRange(modeledValues.muscleJointMoments, modelMomentsExpected, 1e-12)

%%%%%%%%%%%%%%%%%%%%%%%%%% calcMtpModeledValues %%%%%%%%%%%%%%%%%%%%%%%%%%

muscleExcitations = calcMuscleExcitations(experimentalData.emgTime, ...
    experimentalData.emgSplines, values.electromechanicalDelays, ...
    values.emgScaleFactors);
neuralActivations = calcNeuralActivations(muscleExcitations, ...
    values.activationTimeConstants, experimentalData.emgTime, ...
    experimentalData.numPaddingFrames);
modeledValues.muscleActivations = calcMuscleActivations( ...
    neuralActivations, values.activationNonlinearityConstants);
[modeledValues.normalizedFiberLength, ...
    modeledValues.normalizedFiberVelocity] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(experimentalData, ...
    values.optimalFiberLengthScaleFactors, ...
    values.tendonSlackLengthScaleFactors);
modeledValues.passiveForce = calcPassiveForceLengthCurve( ...
    modeledValues.normalizedFiberLength, ...
    experimentalData.maxIsometricForce, ...
    experimentalData.pennationAngle);
modeledValues.muscleJointMoments = calcMuscleJointMoments( ...
    experimentalData, modeledValues.muscleActivations, ...
    modeledValues.normalizedFiberLength, ...
    modeledValues.normalizedFiberVelocity);

muscleExcitationsExpected = load('muscleExcitationsExpected.mat').muscleExcitationsExpected;
muscleExcitationsExpected = permute(muscleExcitationsExpected, [2, 3, 1]);
assertWithinRange(muscleExcitations, muscleExcitationsExpected, 1e-12)

synxNeuralActivationsExpected = load('neuralActivationsExpected.mat').neuralActivationsExpected;
synxNeuralActivationsExpected = permute(synxNeuralActivationsExpected, [2, 3, 1]);
assertWithinRange(neuralActivations, synxNeuralActivationsExpected, 1e-12)

synxMuscleActivationsExpected = load('muscleActivationsExpected.mat').muscleActivationsExpected;
synxMuscleActivationsExpected = permute(synxMuscleActivationsExpected, [2, 3, 1]);
assertWithinRange(modeledValues.muscleActivations, synxMuscleActivationsExpected, 1e-12)

lMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').lMtildaExpected;
lMtildaExpected = permute(lMtildaExpected, [2, 3, 1]);
assertWithinRange(modeledValues.normalizedFiberLength, lMtildaExpected, 1e-12)
vMtildaExpected = load('normalizedMuscleLengthandVelocitiesExpected.mat').vMtildaExpected;
vMtildaExpected = permute(vMtildaExpected, [2, 3, 1]);
assertWithinRange(modeledValues.normalizedFiberVelocity, vMtildaExpected, 1e-12)

load('muscleMomentsAndForcesExpected.mat')
passiveForceExpected = permute(passiveForceExpected, [2, 3, 1]);
assertWithinRange(modeledValues.passiveForce, passiveForceExpected, 1e-11)
modelMomentsExpected = permute(modelMomentsExpected, [2, 3, 1]);
assertWithinRange(modeledValues.muscleJointMoments, modelMomentsExpected, 1e-12)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calcMtpCost %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% experimentalData.costWeight = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
% experimentalData.maxAllowableErrors = [2, 0.02, 0.1, 0.1, 0.1, 0.2, 0.1, 50, ...
%     0.05, 0.1, 0.2, 2.5, 0.3, 0.3];
% experimentalData.errorCenters = [0, 0.015, 0, 0, 0, 0.3, 0, 0, 0, 0, 0, 0, 0, 0];

synxModeledValues = calcMtpSynXModeledValues(values, experimentalData, struct());
modeledValues = calcMtpModeledValues(values, experimentalData, struct());

expectedCost = load('individualCostsExpected.mat').individualCostsExpected;

momentTrackingCost = calcSynergyExtrapolationMomentTrackingCost(synxModeledValues, experimentalData, struct());
assertWithinRange(momentTrackingCost, sum(expectedCost.synxMomentMatching .^ 2, "all"), 1e-13)

momentTrackingNoSynXCost = calcMomentTrackingCost(modeledValues, experimentalData, struct());
assertWithinRange(momentTrackingNoSynXCost, sum(expectedCost.momentMatching .^ 2, "all"), 1e-13)

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

normalizedFiberLengthCost = calcNormalizedFiberLengthDeviationCost(synxModeledValues, experimentalData, struct());
assertWithinRange(normalizedFiberLengthCost, sum(expectedCost.lMtildaPenalty .^ 2, "all"), 1e-13)

lmtildaGroupedSimilarity = calcNormalizedFiberLengthGroupedSimilarityCost( ...
    synxModeledValues, experimentalData, struct());
assertWithinRange(lmtildaGroupedSimilarity, sum(expectedCost.lmtildaPairedSimilarity .^ 2, "all"), 1e-13)

emgScaleGroupedSimilarity = calcEmgScaleFactorGroupedSimilarityCost(values, experimentalData, struct());
assertWithinRange(emgScaleGroupedSimilarity, sum(expectedCost.emgScalePairedSimilarity .^ 2, "all"), 1e-13)

tdelayGroupedSimilarity = calcElectromechanicalDelayGroupedSimilarityCost(values, experimentalData, struct());
assertWithinRange(tdelayGroupedSimilarity, sum(expectedCost.tdelayPairedSimilarity .^ 2, "all"), 1e-13)

minPassiveForce = calcPassiveForceCost(synxModeledValues, struct());
assertWithinRange(minPassiveForce, sum(expectedCost.minPassiveForce .^ 2, "all"), 1e-13)

synergyMuscleExcitationMinimization = calcSynergyExtrapolationMuscleActivationCost(synxModeledValues, experimentalData, struct());
assertWithinRange(synergyMuscleExcitationMinimization, sum(expectedCost.synergyMuscleExcitationMinimization .^ 2, "all"), 1e-13)

residualMuscleActivationMinimization =calcResidualMuscleActivationCost(synxModeledValues, modeledValues, experimentalData, struct());
assertWithinRange(residualMuscleActivationMinimization, sum(expectedCost.residualMuscleActivationMinimization .^ 2, "all"), 1e-13)

excitationPenalty = calcMuscleExcitationPenaltyCost(synxModeledValues,experimentalData);
assertWithinRange(excitationPenalty, sum([sqrt(0.1) * expectedCost.excitationPenalty] .^ 2, "all"), 1e-12)

%%%%%%%%%%%%%%%%%%%%%%%% Total Cost function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

synxModeledValues = calcMtpSynXModeledValues(values, experimentalData, struct());
modeledValues = calcMtpModeledValues(values, experimentalData, struct());
params.costTerms = {};
params.costTerms{1}.type = "measured_inverse_dynamics_joint_moment";
params.costTerms{1}.isEnabled = true;
params.costTerms{2}.type = "inverse_dynamics_joint_moment";
params.costTerms{2}.isEnabled = true;
params.costTerms{3}.type = "activation_time_constant";
params.costTerms{3}.isEnabled = true;
params.costTerms{4}.type = "activation_nonlinearity_constant";
params.costTerms{4}.isEnabled = true;
params.costTerms{5}.type = "optimal_muscle_fiber_length";
params.costTerms{5}.isEnabled = true;
params.costTerms{6}.type = "tendon_slack_length";
params.costTerms{6}.isEnabled = true;
params.costTerms{7}.type = "emg_scale_factor";
params.costTerms{7}.isEnabled = true;
params.costTerms{8}.type = "normalized_muscle_fiber_length";
params.costTerms{8}.isEnabled = true;
params.costTerms{9}.type = "passive_muscle_force";
params.costTerms{9}.isEnabled = true;
params.costTerms{10}.type = "grouped_normalized_muscle_fiber_length";
params.costTerms{10}.isEnabled = true;
params.costTerms{11}.type = "grouped_emg_scale_factor";
params.costTerms{11}.isEnabled = true;
params.costTerms{12}.type = "grouped_electromechanical_delay";
params.costTerms{12}.isEnabled = true;
params.costTerms{13}.type = "extrapolated_muscle_activation";
params.costTerms{13}.isEnabled = true;
params.costTerms{14}.type = "residual_muscle_activation";
params.costTerms{14}.isEnabled = true;
params.costTerms{15}.type = "muscle_excitation_penalty";
params.costTerms{15}.isEnabled = true;
cost = calcMtpCost(values, synxModeledValues, modeledValues, ...
    experimentalData, params);

load('costExpected.mat')
assertWithinRange(cost, costExpected, 1e-11)

%%%%%%%%%%%%%%%%%% calcMuscleTendonNonLinearConstraints %%%%%%%%%%%%%%%%%%

ceq = [];
modeledValues = calcMtpModeledValues(values, experimentalData, struct());
softmaxlmtildaCon = log(sum(exp(500 * ...
    (modeledValues.normalizedFiberLength - 1.3)), [1 3])) / 500; % max lmtilda less than 1.5
softminlmtildaCon = log(sum(exp(500 * (0.3 - ...
    modeledValues.normalizedFiberLength)), [1 3])) / 500; % min lmtilda bigger than 0.3
% assign values to c matrix
c =  [softmaxlmtildaCon, softminlmtildaCon];
c(c<-1000) = -1;
c(c>1000) = 1;


expectedNonlinearConstraint = load('expectedNonlinearConstraint.mat').expectedNonlinearConstraint;
assertWithinRange(c, expectedNonlinearConstraint, 1e-12)

