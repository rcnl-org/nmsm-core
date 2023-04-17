load('trackingOptimizationEndpointInputs.mat')
pointKinematics('exampleModel.osim');
inverseDynamics('exampleModel.osim');

output.eventgroup.event = calcTrackingOptimizationTerminalConstraint( ...
    inputs, inputs.auxdata);
output.objective = calcTrackingOptimizationObjective(inputs.phase.integral);

expectedOutput = load('expectedOutput.mat');
assertWithinRange(output.eventgroup.event([1:62]), expectedOutput.output.eventgroup.event([1:62]), 1e-5);
