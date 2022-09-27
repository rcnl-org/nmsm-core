

%% Test simple calcDampingFactorDeviationFromInitialValueError

initialDampingFactors = [1 1 1 1];
modeledDampingFactors = [1.8 1.1 0.9 1.1];

error = calcDampingFactorDeviationFromInitialValueError(initialDampingFactors, modeledDampingFactors);

assertWithinRange(error(1), 0.1074, 0.001);