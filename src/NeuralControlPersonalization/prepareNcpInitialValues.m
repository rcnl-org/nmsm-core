% This function is part of the NMSM Pipeline, see file for full license.
%
% Builds NCP's initial design vector. Steps:
% 1. factorize MTP activations via nnmf to get initial weights and commands
% 2. renormalize weights and commands to (0-1) scale
% 3. group weights using activationGroups
% 4. spline commands to num of nodes
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

if isfield(inputs, 'mtpActivations') && use_nnmf_as_init
    % nnmf options
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
    commandsInit = reshape(commandsInitStack, inputs.numTrials, ...
        inputs.numPoints, inputs.numSynergies);
    commands2d = reshape(permute(commandsInit, [2 1 3]), inputs.numPoints, []);
    nodes2d = inputs.invBmatrix * commands2d;
    commandsInitNodes = permute(reshape(nodes2d, inputs.numNodes, ...
        inputs.numTrials, inputs.numSynergies), [2 1 3]);

    % matrix -> column vector 
    values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);

else
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
end

% -------------------------------------------------------------------------
function [weightsNormalized,commandsNormalized] = prenormalizeVariables(...
    weights,commands, normalization_method, normalization_value)

if isempty(normalization_value) || isnan(normalization_value)
    numSynergies = size(weights, 1);
    ratios = sqrt(mean(commands(:)) / mean(weights(:)))* ones(numSynergies, 1);
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
%   weights  (numSynergies x numMuscles): scale row s by ratios(s)
%   commands (numFrames x numSynergies):  scale col s by 1/ratios(s)
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