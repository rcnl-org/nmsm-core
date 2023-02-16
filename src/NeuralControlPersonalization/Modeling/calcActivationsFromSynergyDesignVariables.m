function activations = calcActivationsFromSynergyDesignVariables( ...
    values, inputs, params)
[weights, commands] = findSynergyWeightsAndCommands(values, inputs, params);

activations = zeros(inputs.numTrials, inputs.numMuscles, inputs.numPoints);

for i = 1:inputs.numTrials
    activations(i, :, :) =  weights' * squeeze(commands(i, :, :))';
end

end