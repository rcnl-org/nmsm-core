load('trackingOptimizationContinuousInputsAndValues.mat')
phaseout = load('expectedPhaseout.mat');

phaseout.path = calcTrackingOptimizationPathConstraint(values, phaseout, inputs.auxdata);

expectedPath = load('expectedPath.mat');
assertWithinRange(phaseout.path, expectedPath.path, 1e-2);
