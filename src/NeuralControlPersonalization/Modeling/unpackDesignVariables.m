%--------------------------------------------------------------------------
function [commands,weights] = unpackDesignVariables(x,params)

numNodes = params.numNodes; numSynergies = params.numSynergies; nPts = params.nPts;
% Unpack synergy quantities from design variable vector
[commandNodes,weights] = unpackSynergyVariables(x,params);

% Spline fit command nodes to create synegy commands
percent = linspace(0,100,nPts)';
percentNodes = linspace(0,100,numNodes)';

commands = zeros(nPts,numSynergies);

for i = 1:numSynergies
    commands(:,i) = spline(percentNodes,commandNodes(:,i),percent);
end

