
function [commands, weights] = unpackDesignVariables(values, inputs, ...
    params)

% Unpack synergy quantities from design variable vector
% [commandNodes, weights] = unpackSynergyVariables(values, inputs);

weights = values(1 : inputs.numSynergies * ...
    inputs.numMuscles);
commandNodes = values(inputs.numSynergies * ...
    inputs.numMuscles + 1 : end);

% Spline fit command nodes to create synegy commands
percent = linspace(0, 100, inputs.numPoints)';
percentNodes = linspace(0, 100, inputs.numNodes)';

commands = zeros(inputs.numPoints, inputs.numSynergies);

for i = 1:inputs.numSynergies
    commands(:, i) = spline(percentNodes, commandNodes(:, i), percent);
end
