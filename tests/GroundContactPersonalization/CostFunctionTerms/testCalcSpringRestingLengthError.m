

%% Test simple calcSpringRestingLengthError

initialRestingLength = 0.02;
modeledRestingLength = 0.038;

error = calcSpringRestingLengthError(initialRestingLength, modeledRestingLength);

assertWithinRange(error, 0.3487, 0.001);