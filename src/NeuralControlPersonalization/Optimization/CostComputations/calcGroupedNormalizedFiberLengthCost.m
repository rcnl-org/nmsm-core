function cost = calcGroupedNormalizedFiberLengthCost(activations, inputs, params)
cost = [];
for i = 1 : length(params.normalizedFiberLengthGroups)
    groupIndex = params.normalizedFiberLengthGroups{i};
    if isempty(groupIndex)
        continue
    end
    groupNormalizedFiberLength = activations(:, groupIndex, :);
    cost = [cost reshape(groupNormalizedFiberLength - mean(groupNormalizedFiberLength, 2), ...
        1, [])];
end
end

