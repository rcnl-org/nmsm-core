%--------------------------------------------------------------------------
function [commandNodes, weights] = unpackSynergyVariables(x, inputs)

% Unpack synergy quantities from design variable vector
synergyDVs = reshape(x, inputs.numNodes + inputs.numMuscles / 2, inputs.numSynergies);

commandNodes = synergyDVs(1 : inputs.numNodes, :);
weights = synergyDVs(inputs.numNodes + 1 : end, :)'; % The transpose is needed here