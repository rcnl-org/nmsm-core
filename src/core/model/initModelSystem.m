% This function takes a model and returns the state from initializing the
% system. It's used in situations where the state is required, even if the
% model has an initialized system

function state = initModelSystem(model)
[~, state] = evalc('model.initSystem()');
end

