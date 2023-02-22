load('trackingOptimizationInputsAndValues.mat')
phaseout = load('expectedPhaseout.mat');

phaseout.integrand = calcTrackingOptimizationIntegrand(values, inputs.auxdata, ...
    phaseout);

expectedIntegrand = load('expectedIntegrand.mat');
assertWithinRange(phaseout.integrand, expectedIntegrand.integrand, 1e-3);