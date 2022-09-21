

%% Test simple calcKinematicCurveSlopeError

experimentalCoordinate1 = [1 2 4 7];
experimentalCoordinate2 = [-4 -5 -7 -10];
modeledValue1 = [1.3 2.2 4.2 7.1];
modeledValue2 = [-4.1 -5.2 -7.1 -10.4];

inputs.experimentalJointVelocities = zeros(2, 4);

inputs.experimentalJointVelocities(1, :) = experimentalCoordinate1;
inputs.experimentalJointVelocities(2, :) = experimentalCoordinate2;
modeledValues.jointVelocities(1, :) = modeledValue1;
modeledValues.jointVelocities(2, :) = modeledValue2;

error = calcKinematicCurveSlopeError(inputs, modeledValues, 1);

assertWithinRange(error, 0.8, 0.001);