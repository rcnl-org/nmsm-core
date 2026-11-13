function cost = calcGroupedActivationCost(activations, inputs, params)
% This should be ONLY for those that DO NOT have EMG activations to track.
cost = [];
for i = 1 : length(params.activationGroups)
    groupIndex = params.activationGroups{i};
    if isempty(groupIndex)
        continue
    end
    groupActivations = activations(:, groupIndex, :);
    cost = [cost reshape(groupActivations - mean(groupActivations, 2), ...
        1, [])];
end
end