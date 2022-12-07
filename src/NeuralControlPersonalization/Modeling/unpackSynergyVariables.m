%--------------------------------------------------------------------------
function [commandNodes,weights] = unpackSynergyVariables(x,params)

nMuscles = params.nMuscles; nNodes = params.nNodes; nSynergies = params.nSynergies;

% Unpack synergy quantities from design variable vector
synergyDVs = x;
synergyDVs = reshape(synergyDVs,nNodes+nMuscles/2,nSynergies);

commandNodes = synergyDVs(1:nNodes,:);
weights = synergyDVs(nNodes+1:end,:)'; % The transpose is needed here