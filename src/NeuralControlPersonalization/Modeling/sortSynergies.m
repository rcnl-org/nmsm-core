function values = sortSynergies(values, inputs)
[weights, commands, commandNodes] = findSynergyWeightsAndCommands(values, inputs);

% Mean command across trials: (numPoints x numSynergies)
meanCommands = reshape(mean(commands, 1), inputs.numPoints, inputs.numSynergies);

numGroups            = length(inputs.synergyGroups);
numSynergiesPerGroup = cellfun(@(g) g.numSynergies, inputs.synergyGroups);
synergyGroupStart    = [1, cumsum(numSynergiesPerGroup(1:end-1)) + 1];

newOrder = (1:inputs.numSynergies)';

if inputs.enforce_bilateral_symmetry
    % Sort group 1 by peak timing; mirror the same permutation to group 2
    s1 = synergyGroupStart(1);
    e1 = s1 + numSynergiesPerGroup(1) - 1;
    [~, peakIdx] = max(meanCommands(:, s1:e1), [], 1);
    [~, sortPerm] = sort(peakIdx);
    newOrder(s1:e1) = s1 - 1 + sortPerm;

    s2 = synergyGroupStart(2);
    newOrder(s2 : s2 + numSynergiesPerGroup(2) - 1) = s2 - 1 + sortPerm;
else
    for g = 1:numGroups
        s = synergyGroupStart(g);
        e = s + numSynergiesPerGroup(g) - 1;
        [~, peakIdx] = max(meanCommands(:, s:e), [], 1);
        [~, sortPerm] = sort(peakIdx);
        newOrder(s:e) = s - 1 + sortPerm;
    end
end

sortedWeights      = weights(newOrder, :);
sortedCommandNodes = commandNodes(:, :, newOrder);
values = repackDesignVariables(sortedWeights, sortedCommandNodes, inputs);
end
