load('trackingOptimizationInputsAndValues.mat')
load('expectedPhaseout.mat')

phaseout.path = calcTrackingOptimizationPathConstraint(phaseout, inputs.auxdata);

expectedPath = load('expectedPath.mat');
assertWithinRange(phaseout.path, expectedPath.path, 1e-12);