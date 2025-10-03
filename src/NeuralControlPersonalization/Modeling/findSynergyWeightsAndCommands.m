function [weights, commands] = findSynergyWeightsAndCommands(values, inputs)
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
% Spline fit command nodes to create synergy commands
percent = linspace(0, 100, inputs.numPoints)';
percentNodes = linspace(0, 100, inputs.numNodes)';

commands = zeros(inputs.numTrials, inputs.numPoints, inputs.numSynergies);

for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        commands(i, :, j) = spline(percentNodes, commandNodes(i, :, j), ...
            percent);
        % commands(i,:,j) = pchip(percentNodes, commandNodes(i,:,j), percent);
    end
end
end

