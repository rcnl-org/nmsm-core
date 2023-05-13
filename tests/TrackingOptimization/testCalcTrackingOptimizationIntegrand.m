load('trackingOptimizationContinuousInputsAndValues.mat')
load('phaseout.mat')

phaseout.integrand = calcTrackingOptimizationIntegrand(values, inputs.auxdata, ...
    phaseout);

expectedIntegrand = load('expectedIntegrand.mat');
assertWithinRange(phaseout.integrand(:,1:31), expectedIntegrand.integrand(:,1:31), 1e0);