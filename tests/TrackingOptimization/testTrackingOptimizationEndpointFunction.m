load('trackingOptimizationEndpointInputs.mat')
pointKinematics('exampleModel.osim');
inverseDynamics('exampleModel.osim');

output.eventgroup.event = calcTrackingOptimizationTerminalConstraint( ...
    inputs, inputs.auxdata);
integralTerms = parseIntegral(inputs.phase.integral, inputs.auxdata);
output.objective = calcTrackingOptimizationObjective(integralTerms, ...
    inputs.auxdata);

expectedOutput = load('expectedOutput.mat');
assertWithinRange(output.eventgroup.event([1:62 69:80]), expectedOutput.output.eventgroup.event([1:62 69:80]), 1e-5);
assertWithinRange(output.eventgroup.event(63:68), expectedOutput.output.eventgroup.event(63:68), 1e2);
assertWithinRange(output.objective, expectedOutput.output.objective, 1e-5);