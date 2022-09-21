

%% Test simple calcDampingFactorsErrorFromMean

dampingFactors = [0.1 0.3 0.5 0.7];

error = calcDampingFactorsErrorFromMean(dampingFactors);

assertWithinRange(error(1), -0.3, 0.001);