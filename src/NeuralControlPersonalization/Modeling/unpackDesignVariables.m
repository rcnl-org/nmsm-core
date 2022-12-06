%--------------------------------------------------------------------------
function [commands,weights] = unpackDesignVariables(x,params)

nNodes = params.nNodes; nSynergies = params.nSynergies; nPts = params.nPts;
% Unpack synergy quantities from design variable vector
[commandNodes,weights] = unpackSynergyVariables(x,params);

% Spline fit command nodes to create synegy commands
percent = linspace(0,100,nPts)';
percentNodes = linspace(0,100,nNodes)';

commands = zeros(nPts,nSynergies);

for i = 1:nSynergies
    commands(:,i) = spline(percentNodes,commandNodes(:,i),percent);
end

