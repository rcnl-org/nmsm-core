function [initialValuesOrdered, finalValuesOrdered] = reorderDesignVariables(initialValues, finalValues, inputs, params)
[weightInit,  commandInit]  = findSynergyWeightsAndCommandsWithoutSpline(initialValues, inputs);
[weightFinal, commandFinal] = findSynergyWeightsAndCommandsWithoutSpline(finalValues,  inputs);

[numSynergies, numMuscles] = size(weightInit);
numMuscleOneLeg = numMuscles/2;

numSynergiesOneLeg = inputs.synergyGroups{1}.numSynergies;
rightIdx = 1:numSynergiesOneLeg;               % assume synergyGroups{1} is right 
leftIdx  = (numSynergiesOneLeg+1):numSynergies;

% activation groups first half is right, second half is left
activationGroups = params.activationGroups;
numGroupsTotal = numel(activationGroups);
numGroupsOneSide = numGroupsTotal/2;

actGroupsR_global = activationGroups(1:numGroupsOneSide);      
actGroupsL_global = activationGroups(numGroupsOneSide+1:end);      

% Convert global indices -> local indices for each side
actGroupsR_local = cellfun(@(g) g, actGroupsR_global, 'UniformOutput', false);
actGroupsL_local = cellfun(@(g) g - numMuscleOneLeg, actGroupsL_global, 'UniformOutput', false);

% compute order and map back to global synergy indices
permRightLocal = orderSynergiesByGroupFocus( ...
    weightInit(rightIdx, 1:numMuscleOneLeg), actGroupsR_local);
permLeftLocal  = orderSynergiesByGroupFocus( ...
    weightInit(leftIdx,  numMuscleOneLeg+1:numMuscles), actGroupsL_local);
permRight = rightIdx(permRightLocal);
permLeft  = leftIdx(permLeftLocal);
perm = [permRight, permLeft];

% apply permutation
weightInitOrdered  = weightInit(perm, :);
weightFinalOrdered = weightFinal(perm, :);

synDim = find(size(commandInit) == numSynergies, 1, 'first');
idxAll    = repmat({':'}, 1, ndims(commandInit));
idxAllSyn = idxAll; idxAllSyn{synDim} = perm;

commandInitOrdered  = commandInit(idxAllSyn{:});
commandFinalOrdered = commandFinal(idxAllSyn{:});

% repack into design variable vectors
initialValuesOrdered = repackDesignVariables(weightInitOrdered, commandInitOrdered, inputs);
finalValuesOrdered   = repackDesignVariables(weightFinalOrdered, commandFinalOrdered, inputs);

% print
fprintf('\n[reorderDesignVariables] Synergy order:\n');
oldIdx = 1:numSynergies;
newPos = zeros(1,numSynergies); newPos(perm) = 1:numSynergies; % inverse permutation
fprintf('  Old order: '); fprintf('%3d ', oldIdx); fprintf('\n');
fprintf('  New order: '); fprintf('%3d ', newPos); fprintf('\n\n');
end


function permLocal = orderSynergiesByGroupFocus(weightsOneSide, activationGroupsOneSide)
numSynergy = size(weightsOneSide, 1);
numGroup = numel(activationGroupsOneSide);

% groupScores(s,g) = mean(abs(w_s) over muscles in group g)
groupScores = zeros(numSynergy, numGroup);
absW = abs(weightsOneSide);

for g = 1:numGroup
    idx = activationGroupsOneSide{g};
    idx = idx(:)'; % row
    idx = idx(idx >= 1 & idx <= size(weightsOneSide,2));
    if isempty(idx)
        groupScores(:, g) = 0;
    else
        groupScores(:, g) = mean(absW(:, idx), 2);
    end
end

% primary group = argmax score
[primaryScore, primaryGroup] = max(groupScores, [], 2);

% secondary score for tie-breaking (max among remaining groups)
secondaryScore = zeros(numSynergy,1);
for s = 1:numSynergy
    tmp = groupScores(s,:);
    tmp(primaryGroup(s)) = -Inf;
    secondaryScore(s) = max(tmp);
    if isinf(secondaryScore(s)); secondaryScore(s) = 0; end
end

% deterministic tie-breaker: "center of mass" within the primary group
% (weighted avg of muscle indices using abs weights)
com = zeros(numSynergy,1);
for s = 1:numSynergy
    g = primaryGroup(s);
    idx = activationGroupsOneSide{g};
    idx = idx(:);
    idx = idx(idx >= 1 & idx <= size(weightsOneSide,2));
    if isempty(idx)
        com(s) = 0;
    else
        w = absW(s, idx);
        denom = sum(w);
        if denom <= eps
            com(s) = mean(idx);
        else
            com(s) = sum(idx .* w(:)) / denom;
        end
    end
end

% Sorting:
%  1) primaryGroup ascending
%  2) primaryScore descending
%  3) secondaryScore descending
%  4) com ascending
%
% sortrows sorts ascending, so negate scores for descending behavior.
sortKey = [primaryGroup, -primaryScore, -secondaryScore, com];
[~, permLocal] = sortrows(sortKey, [1 2 3 4]);
end


function [weights, commandNodes] = findSynergyWeightsAndCommandsWithoutSpline(values, inputs)
weights = zeros(inputs.numSynergies, inputs.numMuscles);
valuesIndex = 1;
row = 1;
column = 1; % the sum of the muscles in the previous synergy groups
for i = 1:length(inputs.synergyGroups)
    for j = 1: inputs.synergyGroups{i}.numSynergies
        weights(row, column : column + ...
            length(inputs.synergyGroups{i}.muscleNames) - 1) = ...
            values(valuesIndex : valuesIndex + ...
            length(inputs.synergyGroups{i}.muscleNames) - 1);
        valuesIndex = valuesIndex + length( ...
            inputs.synergyGroups{i}.muscleNames);
        row = row + 1;
    end
    column = column + length(inputs.synergyGroups{i}.muscleNames);
end
commandNodes = zeros(inputs.numTrials, inputs.numNodes, inputs.numSynergies);
for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        commandNodes(i, :, j) = values(valuesIndex : valuesIndex + ...
            inputs.numNodes - 1);
        valuesIndex = valuesIndex + inputs.numNodes;
    end
end
end
