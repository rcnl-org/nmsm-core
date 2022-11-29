%--------------------------------------------------------------------------
function [commands, weights] = unpackDesignVariables(x, inputs, params)

% Unpack synergy quantities from design variable vector
[commandNodes, weights] = unpackSynergyVariables(x, inputs);

% Spline fit command nodes to create synegy commands
percent = linspace(0, 100, inputs.numPoints)';
percentNodes = linspace(0, 100, inputs.numNodes)';

commands = zeros(inputs.numPoints, inputs.numSynergies);

for i = 1:inputs.numSynergies
    commands(:, i) = spline(percentNodes, commandNodes(:, i), percent);
end
