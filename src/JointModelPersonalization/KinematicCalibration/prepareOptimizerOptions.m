% This function takes the input values and returns the parameters for the
% outer optimization to be used in the kinematic calibration.

% Copyright RCNL *change later*

% (struct) -> (struct)
% Prepare params for outer optimizer for Kinematic Calibration
function output = prepareOptimizerOptions(params)
output = optimoptions('lsqnonlin');
output.DiffMinChange = 1e-5;
output.OptimalityTolerance = 1e-12;
output.FunctionTolerance = 1e-12;
output.StepTolerance = 1e-12;
end

