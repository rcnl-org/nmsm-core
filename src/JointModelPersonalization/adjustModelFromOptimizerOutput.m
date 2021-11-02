% The optimizer returns the optimized values after completion, these values
% should be used to change the input model to reflect the optimized state.

% Copyright RNCL *change later*

% (Model, cellArray, array, struct) -> (Model)
% Adjust the model based on the output of the optimizer
function outputModel = adjustModelFromOptimizerOutput(model, functions, ...
    values)
import org.opensim.modeling.*
outputModel = Model(model);
outputModel.initSystem();
for i = 1:length(values)
    functions{i}(values(i), outputModel);
end
end