load('trackingOptimizationContinuousInputsAndValues.mat')
% phaseout = load('phaseout.mat');
phaseout = load('expectedPhaseout.mat');

phaseout.path = calcTrackingOptimizationPathConstraint(values, phaseout, inputs.auxdata);

expectedPath = load('expectedPath.mat');
assertWithinRange(phaseout.path(:,1:9), expectedPath.path(:,1:9), 1e-2);
