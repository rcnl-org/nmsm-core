%--------------------------------------------------------------------------
function [commands, weights] = unpackDesignVariables(x, inputs)

% Unpack synergy quantities from design variable vector
[commandNodes, weights] = unpackSynergyVariables(x, inputs);

% Spline fit command nodes to create synegy commands
percent = linspace(0, 100, inputs.nPts)';
percentNodes = linspace(0, 100, inputs.numNodes)';

commands = zeros(inputs.nPts, inputs.numSynergies);

for i = 1:inputs.numSynergies
    commands(:, i) = spline(percentNodes, commandNodes(:, i), percent);
end
