function cost = calcGroupedActivationCost(activations, inputs, params) % This should be ONLY for those that DO NOT have EMG activations to track.
cost = [];
for i = 1 : length(params.activationGroups)
    columns = ismember(inputs.activationColumnNames, ...
        params.activationGroups{i});
    groupActivations = activations(:, columns, :);
    cost = [cost, groupActivations - mean(groupActivations, 2)];
end
end