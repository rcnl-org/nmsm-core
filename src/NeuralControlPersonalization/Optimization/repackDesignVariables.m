function values = repackDesignVariables(weights, commands, inputs)
% design variables size
length_weights   = sum(inputs.numWeightsPerGroup);
length_commands = inputs.numTrials*inputs.numNodes*inputs.numSynergies;
values = zeros(length_weights + length_commands, 1);

idx = 1;
row = 1;
idx_group = 1;

% weights
for i = 1:numel(inputs.synergyGroups)
    numMuscleOneLeg = length(inputs.synergyGroups{i}.muscleNames);
    for j = 1:inputs.synergyGroups{i}.numSynergies
        weight_list = weights(row, idx_group:idx_group+numMuscleOneLeg-1);
        values(idx:idx+numMuscleOneLeg-1) = weight_list(:);
        idx  = idx + numMuscleOneLeg;
        row  = row + 1;
    end
    idx_group = idx_group + numMuscleOneLeg;
end

% commands
for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        command_list = squeeze(commands(i,:,j));
        values(idx:idx+inputs.numNodes-1) = command_list(:);
        idx = idx + inputs.numNodes;
    end
end
end