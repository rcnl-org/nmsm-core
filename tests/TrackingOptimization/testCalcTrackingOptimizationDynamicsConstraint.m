load('trackingOptimizationInputsAndValues.mat')

phaseout.dynamics = calcTrackingOptimizationDynamicsConstraint(values, inputs.auxdata);

expectedDynamics = load('expectedDynamics.mat');
assertWithinRange(phaseout.dynamics, expectedDynamics.dynamics, 1e-12);
