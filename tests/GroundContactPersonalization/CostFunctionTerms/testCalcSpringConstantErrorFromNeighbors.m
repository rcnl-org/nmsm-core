

%% Test simple calcSpringConstantErrorFromNeighbors

springConstants = [1 2 3 4];
gaussianWeights = zeros(2, 4, 4);
gaussianWeights(1, :, :) = [0 1 1 0.75; 1 0 0.75 1; 1 0.75 0 1; 0.75 1 1 0];
gaussianWeights(2, :, :) = gaussianWeights(1, :, :) .* 1.1;

error = calcSpringConstantsErrorFromNeighbors(springConstants, ...
    gaussianWeights);
expected = [-1.9091 -0.6364 0.6364 1.9091 -1.9091 -0.6364 0.6364 1.9091];

assertWithinRange(error .^ 2, expected .^ 2, 0.001)