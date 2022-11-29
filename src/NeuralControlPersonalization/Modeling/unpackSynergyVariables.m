%--------------------------------------------------------------------------
function [commandNodes,weights] = unpackSynergyVariables(x,params)

numMuscles = params.numMuscles; numNodes = params.numNodes; numSynergies = params.numSynergies;

% Unpack synergy quantities from design variable vector
synergyDVs = x;
synergyDVs = reshape(synergyDVs,numNodes+numMuscles/2,numSynergies);

commandNodes = synergyDVs(1:numNodes,:);
weights = synergyDVs(numNodes+1:end,:)'; % The transpose is needed here