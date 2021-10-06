% Prepares the initial values for the kinematic calibration based on the
% input functions and input parameters

% Copyright RCNL *change later*

% (cellArray, struct) -> (array)
% Creates an array of initial values of same length as 1D cellArray
function output = prepareKinematicCalibrationInitialValues(functions, ...
    params)
output = valueOrAlternate(params, 'initialValues', ...
    zeros(max(size(functions)),1));
end

