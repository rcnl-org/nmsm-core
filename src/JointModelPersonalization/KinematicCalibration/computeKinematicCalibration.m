% Kinematic Calibration takes a model and applies a calibration.

% Copyright RCNL *change*

% (Model, Array, Array, number, struct) -> (Model)
% Creates calibrated model from joint structure and marker plate structure
function optimizedValues = computeKinematicCalibration(model, ...
    markerFileName, functions, desiredError, params)
params.desiredError = desiredError; %required arg, but passed in params
optimizerOptions = prepareOptimizerOptions(params); % Prepare optimizer
initialValues = prepareKinematicCalibrationInitialValues(functions, ...
    params);
[lowerBounds, upperBounds] = prepareKinematicCalibrationBounds( ...
    initialValues, params);
optimizedValues = lsqnonlin ...
    (@(values) computeInnerOptimization(values, functions, model, ...
    markerFileName, params), initialValues, lowerBounds, upperBounds, ...
    optimizerOptions);
end

% (cellArray, struct) -> (array)
% Creates an array of initial values of same length as 1D cellArray
function output = prepareKinematicCalibrationInitialValues(functions, ...
    params)
output = valueOrAlternate(params, 'initialValues', ...
    zeros(max(size(functions)),1));
end

% (cell array, array, struct) -> (array, array)
% Returns the bounds of the KinCal or default bounds around initial values
function [lowerBounds, upperBounds] = prepareKinematicCalibrationBounds(...
    initialValues, params)
lowerBounds = valueOrAlternate(params, 'lowerBounds', ...
    initialValues - 0.1); 
upperBounds = valueOrAlternate(params, 'upperBounds', ...
    initialValues + 0.1);
end

% (struct) -> (struct)
% Prepare params for outer optimizer for Kinematic Calibration
function output = prepareOptimizerOptions(params)
output = optimoptions('lsqnonlin', 'UseParallel', true);
output.DiffMinChange = valueOrAlternate(params, 'diffMinChange', 1e-4);
output.OptimalityTolerance = valueOrAlternate(params, ...
    'optimalityTolerance', 1e-6);
output.FunctionTolerance = valueOrAlternate(params, ...
    'functionTolerance', 1e-6);
output.StepTolerance = valueOrAlternate(params, ...
    'stepTolerance', 1e-6);
output.MaxFunctionEvaluations = valueOrAlternate(params, ...
    'maxFunctionEvaluations', 3e2);
output.Display = valueOrAlternate(params, ...
    'display','iter');
end

