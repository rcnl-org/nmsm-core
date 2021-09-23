% Compute the heuristic value of the inner optimization for kinematic
% calibration

% copyright RCNL *change later*

% (Model, struct) -> (number)
% Computes the heuristic value of the output of the inner optimization
function output = computeInnerOptimizationHeuristic(model, params)
params = prepareInnerOptimizationParams(params);% Prepare IK algorithm
model = computeInnerOptimization(model, params); % Run IK algorithm
output = computeMarkerError(model, params);  % Calculate marker error
end

