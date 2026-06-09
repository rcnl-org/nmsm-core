function [weights, commands, commandNodes] = findSynergyWeightsAndCommands(values, inputs)
weights = zeros(inputs.numSynergies, inputs.numMuscles);
valuesIndex = 1;
row = 1;
column = 1; % the sum of the muscles in the previous synergy groups
for i = 1:length(inputs.synergyGroups)
    for j = 1: inputs.synergyGroups{i}.numSynergies
        weights(row, column : column + ...
            length(inputs.synergyGroups{i}.muscleNames) - 1) = ...
            values(valuesIndex : valuesIndex + ...
            length(inputs.synergyGroups{i}.muscleNames) - 1);
        valuesIndex = valuesIndex + length( ...
            inputs.synergyGroups{i}.muscleNames);
        row = row + 1;
    end
    column = column + length(inputs.synergyGroups{i}.muscleNames);
end
commandNodes = zeros(inputs.numTrials, inputs.numNodes, inputs.numSynergies);
for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        commandNodes(i, :, j) = values(valuesIndex : valuesIndex + ...
            inputs.numNodes - 1);
        valuesIndex = valuesIndex + inputs.numNodes;
    end
end
commandNodes2d = reshape(permute(commandNodes, [2 1 3]), inputs.numNodes, []);
commands2d  = inputs.Bmatrix * commandNodes2d;
commands = permute(reshape(commands2d, inputs.numPoints, inputs.numTrials, ...
    inputs.numSynergies), [2 1 3]);
end