% This function is part of the NMSM Pipeline, see file for full license.
%
% Builds NCP's initial design vector. Steps:
% 1. get raw weights and commands via the selected init method
% 2. group weights using activationGroups (if grouped_activations enabled)
% 3. renormalize weights and commands to match the optimizer's constraint
% 4. spline commands to num of nodes
% 5. pack into design vector
%
% Initialization method — four options:
%   'nnmf'     non-negative matrix factorization (default for positive synergies)
%   'svd'      SVD with sign correction          (default for negative synergies)
%   'constant' constant weights/commands scaled to the normalization target
%   'load'     warm-start from a previous results folder, for testing only
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
% Testing-only override: set init_method = 'load' and point results_folder
% at a prior NCP results directory to warm-start from it. Leave both empty
% to use the automatic default (svd/nnmf based on allow_negative_synergy_vector_weights).
init_method = '';
results_folder = '';

if isempty(init_method)
    if inputs.allow_negative_synergy_vector_weights
        init_method = 'svd';
    else
        init_method = 'nnmf';
    end
end

% Per-group counts
numGroups = length(inputs.synergyGroups);
numSynergiesPerGroup = cellfun(@(g) g.numSynergies,  inputs.synergyGroups);
numMusclesPerGroup = cellfun(@(g) length(g.muscleNames), ...
    inputs.synergyGroups);

% Precompute start indices for muscles and synergies in the stacked matrices
muscleGroupStart = [1, cumsum(numMusclesPerGroup(1:end-1)) + 1];
synergyGroupStart = [1, cumsum(numSynergiesPerGroup(1:end-1)) + 1];

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

if ~isfield(inputs, 'mtpActivations') && ismember(init_method, {'nnmf', 'svd'})
    warning('No mtpActivations available, falling back to constant init.');
    init_method = 'constant';
end

switch init_method
    case 'nnmf'
        fprintf("Generating NNMF initialization from mtpActivations ...\n\n")
        syn = RandStream('threefry', 'Seed', 42);
        options = statset('Display','off','TolX',1e-10,'TolFun',1e-10, ...
            'UseParallel',true, 'UseSubstreams',true, 'Streams',syn);
        numReplicates = 1000;

        mtpPerm = permute(inputs.mtpActivations, [1 3 2]);
        mtpActivationsStack = reshape(mtpPerm, inputs.numTrials * ...
            inputs.numPoints, inputs.numMuscles);

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

    case 'svd'
        fprintf("Generating SVD initialization (allows negative weights) ...\n\n")

        mtpPerm = permute(inputs.mtpActivations, [1 3 2]);
        mtpActivationsStack = reshape(mtpPerm, inputs.numTrials * ...
            inputs.numPoints, inputs.numMuscles);

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

    case 'constant'
        fprintf("Generating constant initialization ...\n\n")

        noTarget = isempty(inputs.synergy_vector_normalization_value) || ...
                   isnan(inputs.synergy_vector_normalization_value);
        if noTarget
            fprintf('[prepareNcpInitialValues] No normalization target. Using constant 0.15.\n\n');
        end

        weightsInit = zeros(inputs.numSynergies, inputs.numMuscles);
        commandsInitStack = zeros(inputs.numTrials * inputs.numPoints, ...
            inputs.numSynergies);
        for group = 1:numGroups
            muscleIdx_start  = muscleGroupStart(group);
            muscleIdx_end    = muscleIdx_start + numMusclesPerGroup(group) - 1;
            synergyIdx_start = synergyGroupStart(group);
            synergyIdx_end   = synergyIdx_start + numSynergiesPerGroup(group) - 1;

            if noTarget
                const = 0.15;
            else
                switch lower(inputs.synergy_vector_normalization_method)
                    case 'sum'
                        const = inputs.synergy_vector_normalization_value / ...
                            numMusclesPerGroup(group);
                    case 'magnitude'
                        const = inputs.synergy_vector_normalization_value / ...
                            sqrt(numMusclesPerGroup(group));
                    otherwise
                        error(['[prepareNcpInitialValues] Unknown ' ...
                            'normalization_method: "%s"'], ...
                            inputs.synergy_vector_normalization_method);
                end
                fprintf(['[prepareNcpInitialValues] Group %d: nMusc=%d, ' ...
                    'method="%s", target=%g -> const=%.4g\n'], ...
                    group, numMusclesPerGroup(group), ...
                    inputs.synergy_vector_normalization_method, ...
                    inputs.synergy_vector_normalization_value, const);
            end

            weightsInit(synergyIdx_start:synergyIdx_end, ...
                muscleIdx_start:muscleIdx_end) = const;
            commandsInitStack(:, synergyIdx_start:synergyIdx_end) = const;
        end

    case 'load'
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

    otherwise
        error('Unknown init_method: "%s"', init_method);
end

% Group weights based on activationGroups, take average for each group
if any(cellfun(@(t) t.isEnabled && strcmpi( ...
        t.type,'grouped_activations'), params.costTerms))
    for i = 1:length(params.activationGroups)
        groupWeights = weightsInit(:, params.activationGroups{i});
        groupWeightsAve = mean(groupWeights, 2);
        weightsInit(:, params.activationGroups{i}) = repmat( ...
            groupWeightsAve, 1, length(params.activationGroups{i}));
    end
end

% Normalize weights and commands to match the optimizer's constraint.
% Skip for 'load': values already come from a completed, constraint-
% satisfying optimization and should be used as-is.
if ~strcmpi(init_method, 'load')
    [weightsInit, commandsInitStack] = prenormalizeVariables( ...
        weightsInit, commandsInitStack, ...
        inputs.synergy_vector_normalization_method, ...
        inputs.synergy_vector_normalization_value);
end

% Commands: #points -> #nodes
commandsInit = reshape(commandsInitStack, inputs.numTrials, ...
    inputs.numPoints, inputs.numSynergies);
commands2d = reshape(permute(commandsInit, [2 1 3]), inputs.numPoints, []);
nodes2d = inputs.invBmatrix * commands2d;
commandsInitNodes = permute(reshape(nodes2d, inputs.numNodes, ...
    inputs.numTrials, inputs.numSynergies), [2 1 3]);

% matrix -> column vector
values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);
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
%   weights  (numSynergies x numMuscles): scale row s by ratios(s)
%   commands (numFrames x numSynergies):  scale col s by 1/ratios(s)
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
