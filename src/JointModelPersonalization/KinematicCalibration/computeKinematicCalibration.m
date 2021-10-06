% Kinematic Calibration takes a model and applies a calibration.

% Copyright RCNL *change*

% (Model, Array, Array, struct) -> (Model)
% Creates calibrated model from joint structure and marker plate structure
function outputModel = computeKinematicCalibration(model, ...
    markerFileName, functions, params)
optimizerOptions = prepareOptimizerOptions(params); % Prepare optimizer
initialValues = prepareKinematicCalibrationInitialValues(params);
[lowerBounds, upperBounds] = prepareBounds(params);
markersReference = makeMarkersReference(model, markerFileName, params);
optimizerOutput = lsqnonlin ...
    (@(values) computeInnerOptimization(values, functions, model, ...
    markersReference, params), initialValues, lowerBounds, ...
    upperBounds, optimizerOptions);
outputModel = adjustModelFromOptimizerOutput(model, functions, ...
    optimizerOutput, params);
end