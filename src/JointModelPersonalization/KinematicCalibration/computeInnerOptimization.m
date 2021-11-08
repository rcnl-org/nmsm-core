% This function computes the inner optimization as defined in the Joint
% Model Personalization module by preparing and running the IK algorithm
% and returning a model with the new values

% Copyright RCNL *change later*

% (Model, struct) -> (Model)
% Returns new model with inverse kinematic optimized marker positions
function error = computeInnerOptimization(values, inputs, params)
inputs.model.initSystem();
for i = 1:length(values)
    inputs.functions{i}(values(i), inputs.model);
end
heuristic = computeInnerOptimizationHeuristic(inputs.model, ...
    inputs.markersReference, inputs.coordinateReference, params);
error = zeros(1, length(values)) + heuristic;
end
