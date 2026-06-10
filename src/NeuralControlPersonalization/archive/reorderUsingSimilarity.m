% Input required:
% data.weights       (numSyn x numMuscles)
% data.activations   (numTrials x numPoints x numSyn)
% data.synergyGroups (optional) provide this to enable bilateral reordering
% data.labels        (optional) length-numSyn array/cell
function [data1, data2] = reorderUsingSimilarity(data1, data2)

data1 = reorderBilateral(data1, 'data1');
data2 = reorderBilateral(data2, 'data2');

numSyn1 = size(data1.weights, 1);
numSyn2 = size(data2.weights, 1);
if numSyn1 ~= numSyn2
    error('Number of synergies mismatch: data1=%d, data2=%d', numSyn1, numSyn2);
end
numSyn = numSyn1;

pairs = matchpairs(-pairwiseCosineRows(data1.weights, data2.weights), 1e9);
perm  = zeros(1, numSyn);
for p = 1:size(pairs,1)
    perm(pairs(p,1)) = pairs(p,2);
end
data2 = applyPermutation(data2, perm, 'data2 -> data1');

% Check similarity after reordering
sim_w = pairwiseCosineRows(data1.weights, data2.weights);
fprintf('Weight similarity after reorder  {mean diag, min diag}: {%.4f, %.4f}\n', ...
    mean(diag(sim_w))*100, min(diag(sim_w)));

% Average over trials, then compare per-synergy activation profiles
act1 = squeeze(mean(data1.activations, 1))';   % (numSyn x numPoints)
act2 = squeeze(mean(data2.activations, 1))';
sim_a = pairwiseCosineRows(act1, act2);
fprintf('Command similarity after reorder {mean diag, min diag}: {%.4f, %.4f}\n\n', ...
    mean(diag(sim_a))*100, min(diag(sim_a)));
end


% ------------------ Bilateral reordering ------------------
function data = reorderBilateral(data, label)

if ~isfield(data, 'synergyGroups') || numel(data.synergyGroups) < 2
    fprintf('[reorderBilateral] %s: synergyGroups not provided or < 2 groups, skipping.\n', label);
    return
end
if numel(data.synergyGroups) > 2
    warning('[reorderBilateral] %s: more than 2 groups found, using only groups 1 and 2.', label);
end

nSynPerGroup = cellfun(@(g) g.numSynergies,       data.synergyGroups);
nMusPerGroup = cellfun(@(g) numel(g.muscleNames), data.synergyGroups);
nSyn1 = nSynPerGroup(1);  nSyn2 = nSynPerGroup(2);
nMus1 = nMusPerGroup(1);  nMus2 = nMusPerGroup(2);

synIdx1 = 1       : nSyn1;
synIdx2 = nSyn1+1 : nSyn1+nSyn2;
musIdx1 = 1       : nMus1;
musIdx2 = nMus1+1 : nMus1+nMus2;

w1 = data.weights(synIdx1, musIdx1);
w2 = data.weights(synIdx2, musIdx2);

nMusOverlap = min(nMus1, nMus2);
sim = pairwiseCosineRows(w1(:, 1:nMusOverlap), w2(:, 1:nMusOverlap));

% Pad cost matrix to square for unequal synergy counts
nMax    = max(nSyn1, nSyn2);
costMat = ones(nMax) * 1e9;
costMat(1:nSyn1, 1:nSyn2) = -sim;
pairs   = matchpairs(costMat, 1e9);

% Build localPerm: reordering of group2 synergies to best match group1
matched_g2 = nan(1, nSyn1);
for p = 1:size(pairs,1)
    r = pairs(p,1);  c = pairs(p,2);
    if r <= nSyn1 && c <= nSyn2
        matched_g2(r) = c;
    end
end
unmatched = setdiff(1:nSyn2, matched_g2(~isnan(matched_g2)));
localPerm = [matched_g2(~isnan(matched_g2)), unmatched];   % length == nSyn2

% Apply to group 2 only; group 1 stays in place
globalPerm       = [synIdx1, synIdx2(localPerm)];
data             = applyPermutation(data, globalPerm, label);

% Report
nDiag     = min(nSyn1, nSyn2);
sim_after = pairwiseCosineRows( ...
    data.weights(synIdx1, musIdx1(1:nMusOverlap)), ...
    data.weights(synIdx2, musIdx2(1:nMusOverlap)));
fprintf('[reorderBilateral] %s | perm: ', label);
fprintf('%d ', localPerm);
fprintf('\n  Weight cosine similarity (mean/min of diagonal): %.4f / %.4f\n\n', ...
    mean(diag(sim_after(1:nDiag, 1:nDiag)))*100, ...
    min(diag(sim_after(1:nDiag, 1:nDiag))));
end


% ------------------ Helper functions ------------------
function data = applyPermutation(data, perm, label)
data.weights     = data.weights(perm, :);
data.activations = data.activations(:, :, perm);
if isfield(data, 'labels') && numel(data.labels) == numel(perm)
    data.labels = data.labels(perm);
end
if isfield(data, 'trackedWeights') && isfield(data.trackedWeights, 'data')
    data.trackedWeights.data = data.trackedWeights.data(perm, :);
end
if isfield(data, 'resultsWeights') && isfield(data.resultsWeights, 'data')
    for k = 1:numel(data.resultsWeights.data)
        data.resultsWeights.data{k} = data.resultsWeights.data{k}(perm, :);
    end
end
if isfield(data, 'trackedActivations') && isfield(data.trackedActivations, 'data')
    data.trackedActivations.data = data.trackedActivations.data(:, perm);
    if isfield(data.trackedActivations, 'labels') && numel(data.trackedActivations.labels) == numel(perm)
        data.trackedActivations.labels = data.trackedActivations.labels(perm);
    end
end
if isfield(data, 'resultsActivations') && isfield(data.resultsActivations, 'data')
    for k = 1:numel(data.resultsActivations.data)
        data.resultsActivations.data{k} = data.resultsActivations.data{k}(:, perm);
    end
    if isfield(data.resultsActivations, 'labels')
        for k = 1:numel(data.resultsActivations.labels)
            if numel(data.resultsActivations.labels{k}) == numel(perm)
                data.resultsActivations.labels{k} = data.resultsActivations.labels{k}(perm);
            end
        end
    end
end
fprintf('[applyPermutation] %s | perm: ', label);
fprintf('%d ', perm);
fprintf('\n');
end

function S = pairwiseCosineRows(A, B)
% Vectorized: S(i,j) = cosine similarity between row i of A and row j of B
normA = vecnorm(A, 2, 2);
normB = vecnorm(B, 2, 2);
normA(normA < eps) = 1;   % guard against zero-norm rows
normB(normB < eps) = 1;
S = (A ./ normA) * (B ./ normB)';
end