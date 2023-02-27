function cost = calcGroupedNormalizedFiberLengthCost(activations, inputs, params)
cost = [];
for i = 1 : length(params.normalizedFiberLengthGroups)
    try
        groupNormalizedFiberLength = activations(:, params.normalizedFiberLengthGroups{i}, :);
        cost = [cost reshape(groupNormalizedFiberLength - mean(groupNormalizedFiberLength, 2), ...
            1, [])];
    catch
    end
end
end

