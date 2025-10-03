% This function is part of the NMSM Pipeline, see file for full license.
%
% This function runs fmincon for Neural Control Personalization, preparing
% any necessary options and constraints for the optimizer. 
%
% (Array of double, struct, struct) -> (Array of double)
% Runs fmincon optimization for Neural Control Personalization. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function finalValues = computeNeuralControlOptimization(initialValues, ...
    inputs, params)

[initWeights, initCommands] = findSynergyWeightsAndCommands( ...
    initialValues, inputs);
[initWeights, initCommands] = normalizeSynergiesByMaximumWeight(...
    initWeights, initCommands);
initActivations = zeros(inputs.numTrials, inputs.numMuscles, ...
inputs.numPoints);
for i = 1:inputs.numTrials
    initActivations(i, :, :) = initWeights' * ...
        squeeze(initCommands(i, :, :))';
end
fprintf('Init activation range: [%g, %g], error = %g\n', min(initActivations(:)), max(initActivations(:)), mean((initActivations(:) - inputs.mtpActivations(:)).^2));

numDesignVariables = length(initialValues);
[synergyWeightEquations, synergyWeightSums, lowerBounds, upperbounds] = ...
    makeConstraints(inputs, numDesignVariables);
optimizerOptions = prepareOptimizerOptions(params, initialValues);

if strcmpi(inputs.synergy_vector_normalization_method,'magnitude')
    % nonlinear constraints
    finalValues = fmincon(@(values)computeNeuralControlCostFunction(values, ...
        inputs, params), initialValues, [], [], [], [], lowerBounds, [], ...
        @(values)nonlinearConstraints(values, inputs, optimizerOptions, params), optimizerOptions);

elseif strcmpi(inputs.synergy_vector_normalization_method,'sum')
    % linear constraints
    finalValues = fmincon(@(values)computeNeuralControlCostFunction(values, ...
        inputs, params), initialValues, [], [], synergyWeightEquations, ...
        synergyWeightSums, lowerBounds, [], [], optimizerOptions);
else
    error('Unknown normalization method: %s', ...
        inputs.synergy_vector_normalization_method);
end
end

% Generate constraints for synergy weight vectors and design variable lower
% bounds
function [synergyWeightEquations, synergyWeightSums, lowerBounds, upperbounds] = ...
    makeConstraints(inputs, numDesignVariables)
synergyWeightEquations = zeros(inputs.numSynergies, numDesignVariables);
synergyWeightSums = zeros(inputs.numSynergies, 1);
row = 1; 
column = 1;
for i = 1:length(inputs.synergyGroups)
    for j = 1: inputs.synergyGroups{i}.numSynergies
        synergyWeightEquations(row, column:column + ...
            length(inputs.synergyGroups{i}.muscleNames) - 1) = 1;
        synergyWeightSums(row) = ...
            length(inputs.synergyGroups{i}.muscleNames) / 100;
        row = row + 1;
        column = column + length(inputs.synergyGroups{i}.muscleNames);
    end
end
lowerBounds = zeros(numDesignVariables, 1);
upperbounds = inf(numDesignVariables, 1);
numberOfWeights = 0;
for g = 1:length(inputs.synergyGroups)
    numberOfWeights = numberOfWeights + length(inputs.synergyGroups{g}.muscleNames)...
        * inputs.synergyGroups{g}.numSynergies;
end
if inputs.allow_negative_synergy_vector_weights
    lowerBounds(1:numberOfWeights) = -Inf;
    upperbounds(1:numberOfWeights) = Inf;
end
end

% Set optimizer options from params struct
function optimizerOptions = prepareOptimizerOptions(params, initialValues)
optimizerOptions = optimoptions('fmincon', 'UseParallel', 'always');
optimizerOptions.DiffMinChange = valueOrAlternate(params, ...
    'diffMinChange', 1e-6);
% optimizerOptions.DiffMaxChange = valueOrAlternate(params, ...
%     'diffMaxChange', 1);
optimizerOptions.OptimalityTolerance = valueOrAlternate(params, ...
    'optimalityTolerance', 1e-3);
optimizerOptions.FunctionTolerance = valueOrAlternate(params, ...
    'functionTolerance', 1e-6);
optimizerOptions.StepTolerance = valueOrAlternate(params, ...
    'stepTolerance', 1e-16);
optimizerOptions.MaxFunctionEvaluations = valueOrAlternate(params, ...
    'maxFunctionEvaluations', 1e6);
optimizerOptions.MaxIterations = valueOrAlternate(params, ...
    'maxIterations', 1e3);
optimizerOptions.Display = valueOrAlternate(params, ...
    'display','iter');
optimizerOptions.Algorithm = valueOrAlternate(params, 'algorithm', 'sqp');
optimizerOptions.ConstraintTolerance = valueOrAlternate(params,'ConstraintTolerance', 1e-5);
% optimizerOptions.TypicalX = valueOrAlternate(params,'TypicalX', initialValues);
% optimizerOptions.FiniteDifferenceType = valueOrAlternate(params,'FiniteDifferenceType', 'central');
optimizerOptions.FiniteDifferenceStepSize = valueOrAlternate(params,'FiniteDifferenceStepSize', 1e-6);
% optimizerOptions.EnableFeasibilityMode = valueOrAlternate(params,'EnableFeasibilityMode', true);
% optimizerOptions.ScaleProblem = valueOrAlternate(params,'ScaleProblem', 'obj-and-constr');
end

function [c, ceq] = nonlinearConstraints(values, inputs, optimizerOptions, params)     

    [synergyWeights, synergyCommands] = findSynergyWeightsAndCommands( ...
        values, inputs);
    [synergyWeights, synergyCommands] = normalizeSynergiesByMaximumWeight(...
        synergyWeights, synergyCommands);
    synergyActivations = zeros(inputs.numTrials, inputs.numMuscles, ...
    inputs.numPoints);
    for i = 1:inputs.numTrials
        synergyActivations(i, :, :) = synergyWeights' * ...
            squeeze(synergyCommands(i, :, :))';
    end

    if any(isnan(synergyActivations(:))) || any(isinf(synergyActivations(:)))
        c   = 1000 * ones(2*numel(synergyActivations(:)), 1);
        ceq = 1000 * ones(inputs.numSynergies, 1);
        return
    end

    % if inputs.use_activation_saturation
    %     c  = [ synergyActivations(:) - 1.1 + optimizerOptions.ConstraintTolerance;               % <= 2
    %           -synergyActivations(:) - 0.1 + optimizerOptions.ConstraintTolerance];              % >= -1
    % else
    %     c  = [ synergyActivations(:) - 1 + optimizerOptions.ConstraintTolerance;                       % <= 1
    %           -synergyActivations(:) + optimizerOptions.ConstraintTolerance];                          % >= 0
    % end

    if inputs.use_activation_saturation
        c  = [ synergyActivations(:) - 1.5;                       % <= 2
              -synergyActivations(:) - 0.5];                      % >= -1
    else
        c  = [ synergyActivations(:) - 1;                       % <= 1
              -synergyActivations(:)];                          % >= 0
    end
    if any(cellfun(@(t) isfield(t,'isEnabled') && t.isEnabled && isfield(t,'type') && strcmpi(t.type,'bilateral_symmetry'),params.costTerms))
        numOfWeightsOneLeg = inputs.numMuscles*inputs.numSynergies/4;
        matrixA = zeros(numOfWeightsOneLeg,length(values));
        matrixA(:,1:numOfWeightsOneLeg*2) = [eye(numOfWeightsOneLeg),-1*eye(numOfWeightsOneLeg)];
        symmetryResult = matrixA*values;
        c_symmetry = [symmetryResult - 0.005;
                     -symmetryResult - 0.005];
        c = [c;c_symmetry/2];
    end
    target = inputs.synergy_vector_normalization_value;        
    ceq = zeros(1,inputs.numSynergies, 'double');
    valuesIndex = 1;
    row = 1; 
    for i = 1:length(inputs.synergyGroups)
        for j = 1:inputs.synergyGroups{i}.numSynergies
            weights = values(valuesIndex:(valuesIndex+...
                length(inputs.synergyGroups{i}.muscleNames)-1));
            ceq(row) = sum(weights.^2) - target^2;   % ||w||^2 - target^2 = 0
            valuesIndex = valuesIndex + length(inputs.synergyGroups{i}.muscleNames);
            row = row + 1;
        end
    end
end
