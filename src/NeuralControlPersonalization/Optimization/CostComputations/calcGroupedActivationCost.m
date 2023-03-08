function cost = calcGroupedActivationCost(activations, inputs, params)
% This should be ONLY for those that DO NOT have EMG activations to track.
cost = [];
for i = 1 : length(params.activationGroups)
    try
        groupActivations = activations(:, params.activationGroups{i}, :);
        cost = [cost reshape(groupActivations - mean(groupActivations, 2), ...
            1, [])];
    catch
    end
end
end