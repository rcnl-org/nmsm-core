% This function computes the inner optimization as defined in the Joint
% Model Personalization module by preparing and running the IK algorithm
% and returning a model with the new values

% Copyright RCNL *change later*

% (Model, struct) -> (Model)
% Returns new model with inverse kinematic optimized marker positions
function error = computeInnerOptimization(values, functions, ...
    model, markersReference, params)
model.initSystem();
for i = 1:length(values)
    functions{i}(values(i), model);
end
error = computeInnerOptimizationHeuristic(model, markersReference, params);
end

