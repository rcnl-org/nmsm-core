% This model function overrides the default model for the purpose of
% suppressing the outputs upon initialization

% Copyright RCNL *change later*

% (Model or string) -> (Model, state)
% Makes an opensim Model object without outputs to command window
function [outputModel, state] = Model(model)
[~, outputModel] = evalc('org.opensim.modeling.Model(model)');
[~, state] = evalc('outputModel.initSystem()');
end