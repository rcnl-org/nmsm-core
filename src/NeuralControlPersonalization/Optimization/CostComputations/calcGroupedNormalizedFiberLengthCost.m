function cost = calcGroupedNormalizedFiberLengthCost(activations, inputs, params)
cost = [];
for i = 1 : length(params.normalizedFiberLengthGroups)
    groupNormalizedFiberLength = activations(:, params.normalizedFiberLengthGroups{i}, :);
    cost = [cost reshape(groupNormalizedFiberLength - mean(groupNormalizedFiberLength, 2), ...
        1, [])];
end
end

