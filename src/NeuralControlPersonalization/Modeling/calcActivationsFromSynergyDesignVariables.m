function [activations, weights, commands] = calcActivationsFromSynergyDesignVariables( ...
    values, inputs)
[weights, commands, ~] = findSynergyWeightsAndCommands(values, inputs);

commands2d = reshape(commands, [], inputs.numSynergies);
activations2d = commands2d * weights;
activations = permute(reshape(activations2d, inputs.numTrials, ...
    inputs.numPoints, inputs.numMuscles), [1 3 2]);
end