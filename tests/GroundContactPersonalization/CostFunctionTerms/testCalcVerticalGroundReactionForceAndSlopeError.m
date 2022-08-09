

%% Test simple calcVerticalGroundReactionForceAndSlopeError

inputs.time = [0.1 0.2 0.3 0.4];
inputs.experimentalGroundReactionForces = [1 2 3 4; 5 6 7 8; 9 10 11 12];
inputs.experimentalGroundReactionForcesSlope = calcBSplineDerivative(inputs.time, inputs.experimentalGroundReactionForces, 2, 25);
modeledValues.verticalGrf = [5.2 6.3 7.2 8.2];

[valueError, slopeError] = calcVerticalGroundReactionForceAndSlopeError(inputs, modeledValues);

assertWithinRange(valueError, 0.9, 0.001);
assertWithinRange(slopeError, 3.0, 0.001);