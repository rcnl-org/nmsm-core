function x = normalizeSynergyVariables(x,params)

nMuscles = params.nMuscles; nNodes = params.nNodes; nSynergies = params.nSynergies;

[commandNodes,weights] = unpackSynergyVariables(x,params);

% Normalize synergy weights to a sum of nMuscles/sqrt(nSynergies) where nSynergies
% is the # of synergies per side. If nSynergies is the total # of
% synergies, divide by 2. nMusclles should also be the number of muscles
% per side.
vectorSum = sum(weights,2)/sqrt(nSynergies/2)*nMuscles/2;
for i = 1:nSynergies
    weights(i,:) = weights(i,:)/vectorSum(i,1);
    commandNodes(:,i) = commandNodes(:,i)*vectorSum(i,1);
end
nDesignVars = nSynergies*(nMuscles/2 + nNodes);
x = [commandNodes; weights'];
x = reshape(x,nDesignVars,1);