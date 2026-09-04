% This function is part of the NMSM Pipeline, see file for full license.
%
% Builds NCP's initial design vector by dispatching to one of three
% strategies based on inputs.optimize_synergy_vectors and whether
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
use_nnmf_as_init = true;                                                   % !!!

[numGroups, numMusclesPerGroup, numSynergiesPerGroup, muscleGroupStart, ...
    synergyGroupStart] = getSynergyGroupIndices(inputs);

% Runs regardless of optimize_synergy_vectors/initial_guess_directory
verifyBilateralSymmetryGroups(inputs, numGroups, numMusclesPerGroup, ...
    numSynergiesPerGroup);

if ~inputs.optimize_synergy_vectors
    weightsInit = inputs.fixedSynergyWeights;
    if inputs.initialGuessHasCommands
        commandsInitStack = loadInitialGuessCommands(inputs) ./ ...
            inputs.fixedSynergyWeightsRatios';
    else
        commandsInitStack = generateNcpCommandsGivenWeights(inputs, ...
            weightsInit, numGroups, numMusclesPerGroup, ...
            numSynergiesPerGroup, muscleGroupStart, synergyGroupStart);
    end
    commandsInitNodes = commandsPointsToNodes(commandsInitStack, inputs);
    values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);
    return
end

% optimize_synergy_vectors = true
if inputs.initialGuessHasWeights
    fprintf("Loading initial synergy weights from %s ...\n\n", ...
        inputs.initialGuessDirectory);
    rawWeights = inputs.initialGuessWeights;
    if inputs.initialGuessHasCommands
        rawCommandsStack = loadInitialGuessCommands(inputs);
    else
        rawCommandsStack = generateNcpCommandsGivenWeights(inputs, ...
            rawWeights, numGroups, numMusclesPerGroup, ...
            numSynergiesPerGroup, muscleGroupStart, synergyGroupStart);
    end
    rawWeights = applyGroupedActivations(rawWeights, params);
    ratios = computeNcpNormalizationRatios(rawWeights, ...
        inputs.synergy_vector_normalization_method, ...
        inputs.synergy_vector_normalization_value);
    weightsInit = rawWeights .* ratios;
    commandsInitStack = rawCommandsStack ./ ratios';
    commandsInitNodes = commandsPointsToNodes(commandsInitStack, inputs);
    values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);
    return
end

% No loaded weights
if isfield(inputs, 'mtpActivations') && use_nnmf_as_init
    values = prepareNcpInitialValuesNnmf(inputs, params, numGroups, ...
        numMusclesPerGroup, numSynergiesPerGroup, muscleGroupStart, ...
        synergyGroupStart);
else
    values = prepareNcpInitialValuesConstant(inputs, numGroups, ...
        numMusclesPerGroup, numSynergiesPerGroup, synergyGroupStart);
end
if inputs.initialGuessHasCommands
    fprintf(['Overriding generated commands with saved commands from ' ...
        'initial_guess_directory ...\n\n']);
    [weightsInit, ~, ~] = findSynergyWeightsAndCommands(values, inputs);
    commandsInitNodes = commandsPointsToNodes( ...
        loadInitialGuessCommands(inputs), inputs);
    values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);
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
function commandsInitStack = loadInitialGuessCommands(inputs)
model = Model(inputs.modelFileName);
expectedColumns = buildSynergyCommandColumnNames(inputs);
commandsInitStack = zeros(inputs.numTrials * inputs.numPoints, ...
    inputs.numSynergies);
for i = 1:inputs.numTrials
    trialName = inputs.trialNames(i);
    [data, columnNames, time] = parseTrialData(inputs.initialGuessDirectory, ...
        trialName + "_synergyCommands", model);
    columnNames = string(columnNames);

    missingColumns = setdiff(expectedColumns, columnNames);
    if ~isempty(missingColumns)
        throw(MException('', '%s', trialName + ...
            "_synergyCommands.sto in " + inputs.initialGuessDirectory + ...
            " is missing synergy command column(s): " + ...
            strjoin(missingColumns, ", ")))
    end
    extraColumns = setdiff(columnNames, expectedColumns);
    if ~isempty(extraColumns)
        throw(MException('', '%s', trialName + ...
            "_synergyCommands.sto in " + inputs.initialGuessDirectory + ...
            " contains unexpected column(s): " + ...
            strjoin(extraColumns, ", ")))
    end
    if numel(time) ~= inputs.numPoints
        throw(MException('', '%s', sprintf( ...
            "%s_synergyCommands.sto in %s has %d timepoints but %d " + ...
            "are expected (numPoints) for the current settings", ...
            trialName, inputs.initialGuessDirectory, numel(time), ...
            inputs.numPoints)))
    end

    [~, reorderIndex] = ismember(expectedColumns, columnNames);
    trialCommands = data(:, reorderIndex);
    rowStart = (i - 1) * inputs.numPoints + 1;
    rowEnd = i * inputs.numPoints;
    commandsInitStack(rowStart:rowEnd, :) = trialCommands;
end
end

% -------------------------------------------------------------------------
% Generates initial commands for an already-fixed set of synergy weights
% NNLS-fit against mtpActivations if available
% otherwise constant matching the normalization target
function commandsInitStack = generateNcpCommandsGivenWeights(inputs, ...
    weightsInit, numGroups, numMusclesPerGroup, numSynergiesPerGroup, ...
    muscleGroupStart, synergyGroupStart)
if isfield(inputs, 'mtpActivations')
    fprintf(['Fixed synergy weights: fitting commands via NNLS ' ...
        'against mtpActivations ...\n\n'])
    fprintf(['[prepareNcpInitialValues] Commands are fit directly to ' ...
        'mtpActivations via NNLS; normalization value is not applied ' ...
        'to commands here.\n']);
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
else
    fprintf("Fixed synergy weights: constant command initialization ...\n\n")
    noTarget = isempty(inputs.synergy_vector_normalization_value) || ...
               isnan(inputs.synergy_vector_normalization_value);
    commandsInitStack = zeros(inputs.numTrials * inputs.numPoints, ...
        inputs.numSynergies);
    if noTarget
        const = defaultNcpConstant();
        fprintf(['[prepareNcpInitialValues] Fixed weights, constant ' ...
            'commands: no normalization target. Using constant %.4g ' ...
            'for all groups.\n'], const);
        commandsInitStack(:) = const;
    else
        value = inputs.synergy_vector_normalization_value;
        method = inputs.synergy_vector_normalization_method;
        for group = 1:numGroups
            nMusc = numMusclesPerGroup(group);
            const = computeNcpGroupConstant(value, method, nMusc);
            fprintf(['[prepareNcpInitialValues] Fixed weights, constant ' ...
                'commands - Group %d: nMusc=%d, method="%s", target=%g ' ...
                '-> const=%.4g\n'], group, nMusc, method, value, const);
            sStart = synergyGroupStart(group);
            sEnd = sStart + numSynergiesPerGroup(group) - 1;
            commandsInitStack(:, sStart:sEnd) = const;
        end
    end
end
end

% -------------------------------------------------------------------------
% Averages synergy weights within each grouped_activations group
function weights = applyGroupedActivations(weights, params)
if any(cellfun(@(t) t.isEnabled && strcmpi( ...
        t.type, 'grouped_activations'), params.costTerms))
    weightsGrouped = weights;
    for i = 1:length(params.activationGroups)
        groupWeights = weights(:, params.activationGroups{i});
        groupWeightsAve = mean(groupWeights, 2);
        weightsGrouped(:, params.activationGroups{i}) = repmat( ...
            groupWeightsAve, 1, length(params.activationGroups{i}));
    end
    weights = weightsGrouped;
end
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
weightsInit = applyGroupedActivations(weightsInit, params);

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
% No mtpActivations available, uses a constant initial guess
function values = prepareNcpInitialValuesConstant(inputs, numGroups, ...
    numMusclesPerGroup, numSynergiesPerGroup, synergyGroupStart)
fprintf("Generating constant initialization ...\n\n")

noTarget = isempty(inputs.synergy_vector_normalization_value) || ...
           isnan(inputs.synergy_vector_normalization_value);
if noTarget
    const = defaultNcpConstant();
    fprintf('[prepareNcpInitialValues] No normalization target. Using constant %.4g.\n\n', const);
end

weightValues  = [];
constCommands = zeros(inputs.numSynergies, 1);
for i = 1:numGroups
    nMusc = numMusclesPerGroup(i);
    if noTarget
        const = defaultNcpConstant();
    else
        const = computeNcpGroupConstant(inputs.synergy_vector_normalization_value, ...
            inputs.synergy_vector_normalization_method, nMusc);
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
% Reshapes inputs.mtpActivations (numTrials x numMuscles x numPoints) into
% a stacked (numTrials*numPoints) x numMuscles matrix
function mtpActivationsStack = stackMtpActivations(inputs)
mtpPerm = permute(inputs.mtpActivations, [1 3 2]);
mtpActivationsStack = reshape(mtpPerm, inputs.numTrials * ...
    inputs.numPoints, inputs.numMuscles);
end

% -------------------------------------------------------------------------
% Fits nodes to the given point-level commands
function commandsInitNodes = commandsPointsToNodes(commandsInitStack, inputs)
commandsInit = reshape(commandsInitStack, inputs.numTrials, ...
    inputs.numPoints, inputs.numSynergies);
commands2d = reshape(permute(commandsInit, [2 1 3]), inputs.numPoints, []);
nodes2d = inputs.invBmatrix * commands2d;
minPositiveNode = 1e-6;
nodes2d = max(nodes2d, minPositiveNode);
commandsInitNodes = permute(reshape(nodes2d, inputs.numNodes, ...
    inputs.numTrials, inputs.numSynergies), [2 1 3]);
end

% -------------------------------------------------------------------------
function [weightsNormalized,commandsNormalized] = prenormalizeVariables(...
    weights,commands, normalization_method, normalization_value)

if isempty(normalization_value) || isnan(normalization_value)
    numSynergies = size(weights, 1);
    ratios = sqrt(mean(commands(:)) / mean(weights(:)))* ones(numSynergies, 1);
    fprintf(['[PrenormalizeVariables] No normalization target given. Using ' ...
        'data-driven ratio to match weight/command scale: ratio=%.4g ' ...
        '(sqrt(mean(commands)/mean(weights))).\n'], ratios(1));
    % ratios = ones(numSynergies, 1);
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

% % For reference: ratio that would equalize global means post-normalization
% ratioEqualize = sqrt(mean(commandsNormalized(:)) / mean(weightsNormalized(:)));

fprintf('[PrenormalizeVariables] Before → After:\n');
fprintf('  Weight  (min/max/mean): %.3g/%.3g/%.3g → %.3g/%.3g/%.3g\n', ...
    min(weights(:)),            max(weights(:)),            mean(weights(:)), ...
    min(weightsNormalized(:)),  max(weightsNormalized(:)),  mean(weightsNormalized(:)));
fprintf('  Command (min/max/mean): %.3g/%.3g/%.3g → %.3g/%.3g/%.3g\n', ...
    min(commands(:)),           max(commands(:)),           mean(commands(:)), ...
    min(commandsNormalized(:)), max(commandsNormalized(:)), mean(commandsNormalized(:)));
% fprintf('  Ratio to equalize mean(w)==mean(c) after norm: %.4g\n\n', ratioEqualize);
end

% -------------------------------------------------------------------------
function const = computeNcpGroupConstant(value, method, nMusc)
switch lower(method)
    case 'sum'
        const = value / nMusc;
    case 'magnitude'
        const = value / sqrt(nMusc);
    otherwise
        error('[prepareNcpInitialValues] Unknown normalization_method: "%s"', ...
            method);
end
end

% -------------------------------------------------------------------------
% Fallback constant used when no normalization target is given and there is
% no mtp data to derive a data-driven scale from.
function const = defaultNcpConstant()
const = 0.15;
end