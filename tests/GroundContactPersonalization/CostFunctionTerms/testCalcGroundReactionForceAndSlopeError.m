

%% Test simple calcGroundReactionForceAndSlopeError

inputs.time = [0.1 0.2 0.3 0.4];
inputs.experimentalGroundReactionForces = [1 2 3 4; 5 6 7 8; 9 10 11 12];
inputs.experimentalGroundReactionForcesSlope = calcBSplineDerivative( ...
    inputs.time, inputs.experimentalGroundReactionForces, 2, 25);
modeledValues.anteriorGrf = [1.2 2.3 3.2 4.2];
modeledValues.verticalGrf = [5.2 6.3 7.2 8.2];
modeledValues.lateralGrf = [9.2 10.3 11.2 12.2];

[valueError, slopeError] = calcGroundReactionForceAndSlopeError( ...
    inputs, modeledValues);

assertWithinRange(valueError .^ 2, ...
    [0.2 0.3 0.2 0.2; 0.2 0.3 0.2 0.2; 0.2 0.3 0.2 0.2] .^ 2, 0.001);
assertWithinRange(slopeError .^ 2, ...
    [1.5 0 0.5 1; 1.5 0 0.5 1; 1.5 0 0.5 1] .^ 2, 0.001);