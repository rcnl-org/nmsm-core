function x = normalizeSynergyVariables(x,params)

numMuscles = params.numMuscles; numNodes = params.numNodes; numSynergies = params.numSynergies;

[commandNodes,weights] = unpackSynergyVariables(x,params);

% Normalize synergy weights to a sum of numMuscles/sqrt(numSynergies) where numSynergies
% is the # of synergies per side. If numSynergies is the total # of
% synergies, divide by 2. nMusclles should also be the number of muscles
% per side.
vectorSum = sum(weights,2)/sqrt(numSynergies/2)*numMuscles/2;
for i = 1:numSynergies
    weights(i,:) = weights(i,:)/vectorSum(i,1);
    commandNodes(:,i) = commandNodes(:,i)*vectorSum(i,1);
end
numDesignVars = numSynergies*(numMuscles/2 + numNodes);
x = [commandNodes; weights'];
x = reshape(x,numDesignVars,1);
end