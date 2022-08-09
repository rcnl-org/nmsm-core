

%% Test simple calcSpringConstantsErrorFromMean

springConstants = [1 2 3 4];

error = calcSpringConstantsErrorFromMean(springConstants);

assertWithinRange(error(1), -1.5, 0.001);