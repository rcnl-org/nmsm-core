function weights = findSynergyWeightsByGroup(values, inputs)
weights = zeros(length(inputs.synergyGroups), inputs.numMuscles);
valuesIndex = 1;
for i = 1:length(inputs.synergyGroups)
    weights(i, 1 : length(inputs.synergyGroups{i}.muscleNames)) = ...
        values(valuesIndex : valuesIndex + ...
        length(inputs.synergyGroups{i}.muscleNames) - 1);
    valuesIndex = valuesIndex + length( ...
        inputs.synergyGroups{i}.muscleNames);
end
weights = weights(:, any(weights));
end

