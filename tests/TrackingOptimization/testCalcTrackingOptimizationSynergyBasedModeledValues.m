load('trackingOptimizationInputsAndValues.mat')
expectedPhaseout = load('expectedPhaseout.mat');

phaseout = calcTrackingOptimizationSynergyBasedModeledValues(values, inputs.auxdata, expectedPhaseout);

assertWithinRange(phaseout.rightMuscleActivations, expectedPhaseout.rightMuscleActivations, 1e-12);
assertWithinRange(phaseout.leftMuscleActivations, expectedPhaseout.leftMuscleActivations, 1e-12);
% assertWithinRange(phaseout.muscleJointMoments, expectedPhaseout.muscleJointMoments, 1e-12);
