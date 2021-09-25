% Kinematic Calibration takes a model and applies a calibration.

% Copyright RCNL *change*

% (Model, Array, Array, struct) -> (Model)
% Creates calibrated model from joint structure and marker plate structure
function outputModel = computeKinematicCalibration(inputModel, jointArray, ...
    markerPlateArray, params)
optimizerOptions = prepareOptimizerOptions(params); % Prepare optimizer
initialValues = prepareInitialValues(jointArray, markerPlateArray, params);
[lowerBounds, upperBounds] = prepareBounds(jointArray, markerPlateArray,...
    params);
optimizerOutput = findOptimizer(params)...
    (@computeInnerOptimizationHeuristic, initialValues, lowerBounds, ...
    upperBounds, optimizerOptions);
outputModel = adjustModelFromOptimizerOutput(inputModel,...
    optimizerOutput, params);
end