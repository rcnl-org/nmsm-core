load('trackingOptimizationEndpointInputs.mat')

output.eventgroup.event = calcTrackingOptimizationTerminalConstraint( ...
    inputs, inputs.auxdata);
integralTerms = parseIntegral(inputs.phase.integral, inputs.auxdata);
output.objective = calcTrackingOptimizationObjective(integralTerms, ...
    inputs.auxdata);

expectedOutput = load('expectedOutput.mat');
assertWithinRange(output.eventgroup.event, expectedOutput.output.eventgroup.event, 1e-5);
assertWithinRange(output.objective, expectedOutput.output.objective, 1e-5);