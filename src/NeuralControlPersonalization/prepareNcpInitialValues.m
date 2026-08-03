% This function is part of the NMSM Pipeline, see file for full license.
%
% Builds NCP's initial design vector by dispatching to one of four
% strategies based on inputs.optimize_synergy_vectors,
% inputs.allow_negative_synergy_vector_weights, and whether
% mtpActivations are available
%
% (struct, struct) -> (Array of number)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function values = prepareNcpInitialValues(inputs, params)
% Testing-only override
% constant   svd   nnmf   load
init_method = '';
results_folder = '';

[numGroups, numMusclesPerGroup, numSynergiesPerGroup, muscleGroupStart, ...
    synergyGroupStart] = getSynergyGroupIndices(inputs);

if ~inputs.optimize_synergy_vectors
    values = prepareNcpInitialValuesFixedWeights(inputs, numGroups, ...
        numMusclesPerGroup, numSynergiesPerGroup, muscleGroupStart, ...
        synergyGroupStart);
    return
end

verifyBilateralSymmetryGroups(inputs, numGroups, numMusclesPerGroup, ...
    numSynergiesPerGroup);

if isempty(init_method)
    if ~isfield(inputs, 'mtpActivations')
        init_method = 'constant';
    elseif inputs.allow_negative_synergy_vector_weights
        init_method = 'svd';
    else
        init_method = 'nnmf';
    end
end

switch init_method
    case 'nnmf'
        values = prepareNcpInitialValuesNnmf(inputs, params, numGroups, ...
            numMusclesPerGroup, numSynergiesPerGroup, muscleGroupStart, ...
            synergyGroupStart);
    case 'svd'
        values = prepareNcpInitialValuesSvd(inputs, params, numGroups, ...
            numMusclesPerGroup, numSynergiesPerGroup, muscleGroupStart, ...
            synergyGroupStart);
    case 'constant'
        values = prepareNcpInitialValuesConstant(inputs, numGroups, ...
            numMusclesPerGroup, numSynergiesPerGroup, synergyGroupStart);
    case 'load'
        values = prepareNcpInitialValuesLoad(inputs, results_folder);
    otherwise
        error('Unknown init_method: "%s"', init_method);
end
end

% -------------------------------------------------------------------------
function [numGroups, numMusclesPerGroup, numSynergiesPerGroup, ...
    muscleGroupStart, synergyGroupStart] = getSynergyGroupIndices(inputs)
numGroups = length(inputs.synergyGroups);
numSynergiesPerGroup = cellfun(@(g) g.numSynergies,  inputs.synergyGroups);
numMusclesPerGroup = cellfun(@(g) length(g.muscleNames), ...
    inputs.synergyGroups);

muscleGroupStart = [1, cumsum(numMusclesPerGroup(1:end-1)) + 1];
synergyGroupStart = [1, cumsum(numSynergiesPerGroup(1:end-1)) + 1];
end

% -------------------------------------------------------------------------
function verifyBilateralSymmetryGroups(inputs, numGroups, ...
    numMusclesPerGroup, numSynergiesPerGroup)
if inputs.enforce_bilateral_symmetry
% when bilateral symmetry enabled, two legs share one set of weights
    if numGroups ~= 2
        throw(MException('', ['Bilateral symmetry cost ' ...
            'requires exactly two synergy groups.']))
    end
    assert(numMusclesPerGroup(1) == numMusclesPerGroup(2), ...
        'Left and right groups must have the same number of muscles.');
    assert(numSynergiesPerGroup(1) == numSynergiesPerGroup(2), ...
        'Left and right groups must have the same number of synergies.');
    assert(sum(numSynergiesPerGroup) == inputs.numSynergies, ...
        'inputs.numSynergies must equal sum of numSynergies per leg.');
end
end

% -------------------------------------------------------------------------
% Builds the initial design vector when synergy weights are fixed
% commands are initialized via a per-group, per-timepoint least-squares
function values = prepareNcpInitialValuesFixedWeights(inputs, numGroups, ...
    numMusclesPerGroup, numSynergiesPerGroup, muscleGroupStart, ...
    synergyGroupStart)
weightsInit = inputs.fixedSynergyWeights;

if isfield(inputs, 'mtpActivations')
    fprintf(['Fixed synergy weights: fitting commands via NNLS ' ...
        'against mtpActivations ...\n\n'])
    mtpActivationsStack = stackMtpActivations(inputs);

    commandsInitStack = zeros(inputs.numTrials * inputs.numPoints, ...
        inputs.numSynergies);
    for group = 1:numGroups
        muscleIdx_start = muscleGroupStart(group);
        muscleIdx_end = muscleIdx_start + numMusclesPerGroup(group) - 1;
        synergyIdx_start = synergyGroupStart(group);
        synergyIdx_end = synergyIdx_start + numSynergiesPerGroup(group) - 1;

        groupWeights = weightsInit(synergyIdx_start:synergyIdx_end, ...
            muscleIdx_start:muscleIdx_end);
        groupActivations = mtpActivationsStack(:, ...
            muscleIdx_start:muscleIdx_end);

        numFrames = size(groupActivations, 1);
        groupCommands = zeros(numFrames, numSynergiesPerGroup(group));
        for t = 1:numFrames
            groupCommands(t, :) = lsqnonneg(groupWeights', ...
                groupActivations(t, :)')';
        end
        commandsInitStack(:, synergyIdx_start:synergyIdx_end) = ...
            groupCommands;
    end

    commandsInitNodes = commandsPointsToNodes(commandsInitStack, inputs);
else
    fprintf("Fixed synergy weights: constant command initialization ...\n\n")
    noTarget = isempty(inputs.synergy_vector_normalization_value) || ...
               isnan(inputs.synergy_vector_normalization_value);
    if noTarget
        const = 0.15;
    else
        const = inputs.synergy_vector_normalization_value;
    end
    commandsInitNodes = const * ones(inputs.numTrials, inputs.numNodes, ...
        inputs.numSynergies);
end

values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);
end

% -------------------------------------------------------------------------
% Factorizes mtpActivations via nnmf to get initial weights and commands
function values = prepareNcpInitialValuesNnmf(inputs, params, numGroups, ...
    numMusclesPerGroup, numSynergiesPerGroup, muscleGroupStart, ...
    synergyGroupStart)
% nnmf options
fprintf("Generating NNMF initialization from mtpActivations ...\n\n")
syn = RandStream('threefry', 'Seed', 42);
options = statset('Display','off','TolX',1e-10,'TolFun',1e-10, ...
    'UseParallel',true, 'UseSubstreams',true, 'Streams',syn);
numReplicates = 1000;

mtpActivationsStack = stackMtpActivations(inputs);

weightsInit = zeros(inputs.numSynergies, inputs.numMuscles);
commandsInitStack = zeros(inputs.numTrials * inputs.numPoints, ...
    inputs.numSynergies);

if inputs.enforce_bilateral_symmetry
% when bilateral symmetry enabled, two legs share one set of weights
    % Stack both legs for a single shared nnmf
    numMuscles = numMusclesPerGroup(1);
    numSynergies = numSynergiesPerGroup(1);
    mtpActivationsStackStack = [mtpActivationsStack(:, 1:numMuscles);
                               mtpActivationsStack(:, numMuscles+1:end)];

    [commandsOneLegStack, weightsOneLeg] = nnmf( ...
        mtpActivationsStackStack, numSynergies, 'replicates', ...
        numReplicates, 'algorithm', 'als', 'options', options);

    % Shared weights mirrored to both sides
    weightsInit(1:numSynergies, 1:numMuscles) = weightsOneLeg;
    weightsInit(numSynergies+1:end, numMuscles+1:end) = weightsOneLeg;

    % Split the double-stacked commands back into per-leg blocks
    count = inputs.numTrials * inputs.numPoints;
    commandsInitStack(:, 1:numSynergies) = ...
        commandsOneLegStack(1:count,:);
    commandsInitStack(:, numSynergies+1:end) = ...
        commandsOneLegStack(count+1:end,:);
else
% no bilateral symmetry, each group has its own nnmf
    for group = 1:numGroups
        muscleIdx_start = muscleGroupStart(group);
        muscleIdx_end = muscleIdx_start + numMusclesPerGroup(group)-1;
        synergyIdx_start = synergyGroupStart(group);
        synergyIdx_end = synergyIdx_start + ...
            numSynergiesPerGroup(group)-1;

        mtpActivationsGroup = mtpActivationsStack...
            (:, muscleIdx_start:muscleIdx_end);

        [commandsGroup, weightsGroup] = nnmf(mtpActivationsGroup, ...
            numSynergiesPerGroup(group), 'replicates', numReplicates, ...
            'algorithm', 'als', 'options', options);

        weightsInit(synergyIdx_start:synergyIdx_end, ...
            muscleIdx_start:muscleIdx_end) = weightsGroup;
        commandsInitStack(:, synergyIdx_start:synergyIdx_end)= ...
            commandsGroup;
    end
end


% Group weights based on activationGroups, take average for each group
if any(cellfun(@(t) t.isEnabled && strcmpi( ...
        t.type,'grouped_activations'), params.costTerms))
    weightsInitGrouped = weightsInit;
    for i = 1:length(params.activationGroups)
        groupWeights = weightsInit(:, params.activationGroups{i});
        groupWeightsAve = mean(groupWeights, 2);
        weightsInitGrouped(:, params.activationGroups{i}) = repmat( ...
            groupWeightsAve, 1, length(params.activationGroups{i}));
    end
    weightsInit = weightsInitGrouped;
end

% Normalize weights and commands to match the optimizer's constraint
[weightsInit, commandsInitStack] = prenormalizeVariables( ...
    weightsInit, commandsInitStack, ...
    inputs.synergy_vector_normalization_method, ...
    inputs.synergy_vector_normalization_value);

% Commands: #points -> #nodes (unchanged)
commandsInitNodes = commandsPointsToNodes(commandsInitStack, inputs);

% matrix -> column vector
values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);
end

% -------------------------------------------------------------------------
% SVD-based sign-preserving initialization, used for 
% negative synergy weights since nnmf cannot produce negative factors
function values = prepareNcpInitialValuesSvd(inputs, params, numGroups, ...
    numMusclesPerGroup, numSynergiesPerGroup, muscleGroupStart, ...
    synergyGroupStart)
fprintf("Generating SVD initialization (allows negative weights) ...\n\n")

mtpActivationsStack = stackMtpActivations(inputs);

weightsInit = zeros(inputs.numSynergies, inputs.numMuscles);
commandsInitStack = zeros(inputs.numTrials * inputs.numPoints, ...
    inputs.numSynergies);

if inputs.enforce_bilateral_symmetry
    numMuscles = numMusclesPerGroup(1);
    numSynergies = numSynergiesPerGroup(1);
    mtpActivationsStackStack = [mtpActivationsStack(:, 1:numMuscles);
                 mtpActivationsStack(:, numMuscles+1:end)];

    [U, S, V] = svds(mtpActivationsStackStack, numSynergies);
    sqrtS = diag(sqrt(diag(S)));
    commandRaw = U * sqrtS;   % [2*TP x k], mixed sign
    weightRaw  = sqrtS * V';  % [k x M/2], mixed sign

    for j = 1:numSynergies
        if mean(commandRaw(:, j)) < 0
            commandRaw(:, j) = -commandRaw(:, j);
            weightRaw(j, :)  = -weightRaw(j, :);
        end
    end
    % Split the double-stacked commands back into per-leg blocks
    count = inputs.numTrials * inputs.numPoints;
    weightsInit(1:numSynergies, 1:numMuscles) = weightRaw;
    weightsInit(numSynergies+1:end, numMuscles+1:end) = weightRaw;
    commandsInitStack(:, 1:numSynergies) = max(0, commandRaw(1:count, :));
    commandsInitStack(:, numSynergies+1:end) = max(0, commandRaw(count+1:end, :));
else
    for group = 1:numGroups
        muscleIdx_start  = muscleGroupStart(group);
        muscleIdx_end    = muscleIdx_start + numMusclesPerGroup(group) - 1;
        synergyIdx_start = synergyGroupStart(group);
        synergyIdx_end   = synergyIdx_start + numSynergiesPerGroup(group) - 1;

        mtpActivationsGroup = mtpActivationsStack(:, muscleIdx_start:muscleIdx_end);

        [U, S, V] = svds(mtpActivationsGroup, numSynergiesPerGroup(group));
        sqrtS = diag(sqrt(diag(S)));
        commandRaw = U * sqrtS;   % [TP x k]
        weightRaw  = sqrtS * V';  % [k x M_group]
        for j = 1:numSynergiesPerGroup(group)
            if mean(commandRaw(:, j)) < 0
                commandRaw(:, j) = -commandRaw(:, j);
                weightRaw(j, :)  = -weightRaw(j, :);
            end
        end
        weightsInit(synergyIdx_start:synergyIdx_end, ...
                    muscleIdx_start:muscleIdx_end) = weightRaw;
        commandsInitStack(:, synergyIdx_start:synergyIdx_end) = ...
            max(0, commandRaw);  % clamp: command nodes must be >= 0
    end
end

% Group weights based on activationGroups, take average for each group
if any(cellfun(@(t) t.isEnabled && strcmpi( ...
        t.type,'grouped_activations'), params.costTerms))
    weightsInitGrouped = weightsInit;
    for i = 1:length(params.activationGroups)
        groupWeights = weightsInit(:, params.activationGroups{i});
        groupWeightsAve = mean(groupWeights, 2);
        weightsInitGrouped(:, params.activationGroups{i}) = repmat( ...
            groupWeightsAve, 1, length(params.activationGroups{i}));
    end
    weightsInit = weightsInitGrouped;
end

% Normalize weights and commands to match the optimizer's constraint
[weightsInit, commandsInitStack] = prenormalizeVariables( ...
    weightsInit, commandsInitStack, ...
    inputs.synergy_vector_normalization_method, ...
    inputs.synergy_vector_normalization_value);

commandsInitNodes = commandsPointsToNodes(commandsInitStack, inputs);

values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);
end

% -------------------------------------------------------------------------
% No mtpActivations available, uses a constant initial guess
function values = prepareNcpInitialValuesConstant(inputs, numGroups, ...
    numMusclesPerGroup, numSynergiesPerGroup, synergyGroupStart)
fprintf("Generating constant initialization ...\n\n")

noTarget = isempty(inputs.synergy_vector_normalization_value) || ...
           isnan(inputs.synergy_vector_normalization_value);
if noTarget
    fprintf('[prepareNcpInitialValues] No normalization target. Using constant 0.15.\n\n');
end

weightValues  = [];
constCommands = zeros(inputs.numSynergies, 1);
for i = 1:numGroups
    nMusc = numMusclesPerGroup(i);
    if noTarget
        const = 0.15;
    else
        switch lower(inputs.synergy_vector_normalization_method)
            case 'sum'
                const = inputs.synergy_vector_normalization_value / nMusc;
            case 'magnitude'
                const = inputs.synergy_vector_normalization_value / sqrt(nMusc);
            otherwise
                error('[prepareNcpInitialValues] Unknown normalization_method: "%s"', ...
                    inputs.synergy_vector_normalization_method);
        end
        fprintf('[prepareNcpInitialValues] Group %d: nMusc=%d, method="%s", target=%g -> const=%.4g\n', ...
            i, nMusc, inputs.synergy_vector_normalization_method, ...
            inputs.synergy_vector_normalization_value, const);
    end

    weightValues = [weightValues; const * ones(numSynergiesPerGroup(i) * nMusc, 1)];

    sStart = synergyGroupStart(i);
    sEnd   = sStart + numSynergiesPerGroup(i) - 1;
    constCommands(sStart:sEnd) = const;
end

% Pack commands in (trial, synergy) order to match repackDesignVariables
commandTemplate = repelem(constCommands, inputs.numNodes);
commandValues = repmat(commandTemplate, inputs.numTrials, 1);

values = [weightValues; commandValues];
fprintf('\n');
end

% -------------------------------------------------------------------------
% Testing-only: warm-starts from a prior NCP results folder
function values = prepareNcpInitialValuesLoad(inputs, results_folder)
fprintf("Loading initialization from: %s\n\n", results_folder)
weightsFile = fullfile(results_folder, 'synergyWeights.sto');
assert(isfile(weightsFile), 'synergyWeights.sto not found in: %s', ...
    results_folder);
wData = storageToDoubleMatrix(org.opensim.modeling.Storage(weightsFile));
weightsInit = wData';  % [numMuscles x numSynergies] -> [numSynergies x numMuscles]

commandsInitStack = zeros(inputs.numTrials * inputs.numPoints, ...
    inputs.numSynergies);
for i = 1:inputs.numTrials
    cmdFile = fullfile(results_folder, ...
        inputs.trialNames(i) + "_synergyCommands.sto");
    assert(isfile(cmdFile), 'Command file not found: %s', cmdFile);
    cData = storageToDoubleMatrix( ...
        org.opensim.modeling.Storage(char(cmdFile)));
    % cData is [numSynergies x numPoints]; rows here are time points
    commandsInitStack((i-1)*inputs.numPoints+1 : i*inputs.numPoints, :) = cData';
end

commandsInitNodes = commandsPointsToNodes(commandsInitStack, inputs);
values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);
end

% -------------------------------------------------------------------------
% Reshapes inputs.mtpActivations (numTrials x numMuscles x numPoints) into
% a stacked (numTrials*numPoints) x numMuscles matrix
function mtpActivationsStack = stackMtpActivations(inputs)
mtpPerm = permute(inputs.mtpActivations, [1 3 2]);
mtpActivationsStack = reshape(mtpPerm, inputs.numTrials * ...
    inputs.numPoints, inputs.numMuscles);
end

% -------------------------------------------------------------------------
function commandsInitNodes = commandsPointsToNodes(commandsInitStack, inputs)
commandsInit = reshape(commandsInitStack, inputs.numTrials, ...
    inputs.numPoints, inputs.numSynergies);
commands2d = reshape(permute(commandsInit, [2 1 3]), inputs.numPoints, []);
nodes2d = inputs.invBmatrix * commands2d;
commandsInitNodes = permute(reshape(nodes2d, inputs.numNodes, ...
    inputs.numTrials, inputs.numSynergies), [2 1 3]);
end

% -------------------------------------------------------------------------
function [weightsNormalized,commandsNormalized] = prenormalizeVariables(...
    weights,commands, normalization_method, normalization_value)

if isempty(normalization_value) || isnan(normalization_value)
    numSynergies = size(weights, 1);
    % abs(): weights may be signed when allow_negative_synergy_vector_weights
    % is set, and mean(weights(:)) could otherwise be near zero or negative.
    ratios = sqrt(mean(commands(:)) / mean(abs(weights(:)))) * ones(numSynergies, 1);
else
    % Back-calculate constW so a constant weight vector satisfies
    % the same constraint the optimizer will enforce.
    switch lower(normalization_method)
        case 'sum'
            % Per-synergy ratio so sum(w_i) == normalization_value
            ratios = normalization_value ./ sum(weights, 2);
            fprintf(['[PrenormalizeVariables] Method=sum: target sum = %.4g, ' ...
                'per-synergy ratios (min/max) = %.3g / %.3g\n'], ...
                normalization_value, min(ratios), max(ratios));
        case 'magnitude'
            % Per-synergy ratio so norm(w_i) == normalization_value
            ratios = normalization_value ./ vecnorm(weights, 2, 2);
            fprintf(['[PrenormalizeVariables] Method=magnitude: target norm = %.4g, ' ...
                'per-synergy ratios (min/max) = %.3g / %.3g\n'], ...
                normalization_value, min(ratios), max(ratios));
        otherwise
            error('[PrenormalizeVariables] Unknown normalization_method: "%s"', ...
                normalization_method);
    end
end

% Apply per-synergy scaling:
weightsNormalized = weights.* ratios;
commandsNormalized = commands./ ratios';

fprintf('[PrenormalizeVariables] Before -> After:\n');
fprintf('  Weight  (min/max/mean): %.3g/%.3g/%.3g -> %.3g/%.3g/%.3g\n', ...
    min(weights(:)),            max(weights(:)),            mean(weights(:)), ...
    min(weightsNormalized(:)),  max(weightsNormalized(:)),  mean(weightsNormalized(:)));
fprintf('  Command (min/max/mean): %.3g/%.3g/%.3g -> %.3g/%.3g/%.3g\n', ...
    min(commands(:)),           max(commands(:)),           mean(commands(:)), ...
    min(commandsNormalized(:)), max(commandsNormalized(:)), mean(commandsNormalized(:)));
end
