load('trackingOptimizationContinuousInputsAndValues.mat')
expectedPhaseout = load('expectedPhaseout.mat');

phaseout = calcTrackingOptimizationSynergyBasedModeledValues(values, inputs.auxdata, expectedPhaseout);
assertWithinRange(phaseout.normalizedFiberLength, expectedPhaseout.normalizedFiberLength, 1e-5);
assertWithinRange(phaseout.normalizedFiberVelocity, expectedPhaseout.normalizedFiberVelocity, 1e-5);
assertWithinRange(phaseout.muscleActivations, expectedPhaseout.muscleActivations, 1e-5);
assertWithinRange(phaseout.muscleJointMoments, expectedPhaseout.muscleJointMoments, 1e-3);
