

%% Test simple calcSpringConstantDeviationFromInitialValueError

initialSpringConstants = [1 1 1 1];
modeledSpringConstants = [1.8 1.1 0.9 1.1];

error = calcSpringConstantDeviationFromInitialValueError(initialSpringConstants, modeledSpringConstants);

assertWithinRange(error(1), 0.1074, 0.001);