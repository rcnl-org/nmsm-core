function a = calcActivationsFromSynergyDesignVariables(x, inputs, params)
numMuscles_leg = inputs.numMuscles_legs / 2;
% Unpack design variables
[commands, weights] = unpackDesignVariables(x, inputs);

% Form feedforward muscle activations from synergies
a_right = commands(:, 1 : inputs.numSynergies / 2) * weights(1:inputs.numSynergies/2, :);
a_left = commands(:, inputs.numSynergies / 2 + 1 : end) * weights(inputs.numSynergies / 2 + 1 : end, :);
a = [a_right(:, 1 : numMuscles_leg), a_left(:, 1 : numMuscles_leg), ...
 a_right(:, numMuscles_leg + 1 : end), a_left(:, numMuscles_leg + 1 : end)];