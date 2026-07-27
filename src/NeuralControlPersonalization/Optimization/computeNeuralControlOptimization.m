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
% Author(s): Claire V. Hammond, Spencer Williams, Xuanning liu            %
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

function finalValues = computeNeuralControlOptimization(initialValuesLong, ...
    inputs, params)
[initWeights, ~, ~] = findSynergyWeightsAndCommands(initialValuesLong, inputs);
initialValues = initialValuesLong;
if ~inputs.optimize_synergy_vectors
    initialValues(1:length(inputs.fixedSynergyVectorFlat)) = [];
elseif inputs.enforce_bilateral_symmetry
    initialValues(1:inputs.numWeightsPerGroup(1)) = [];
end
numDesignVariables = length(initialValues);
[synergyWeightEquations, synergyWeightSums, lowerBounds, upperbounds] = ...
    makeConstraints(inputs, numDesignVariables, initWeights);
optimizerOptions = prepareOptimizerOptions(params);
% uncomment for a Cancel button that stops fmincon early and still saves the current result
% optimizerOptions = addCancelButton(optimizerOptions, params);   
if ~inputs.optimize_synergy_vectors
    % weights are fixed, not part of the design vector
    % no weight normalization constraints to build
    if params.useCasadi
        derivatives = prepareNcpCasadiDerivatives(inputs, params, ...
            numDesignVariables, []);
        optimizerOptions = applyCasadiOptimizerOptions(optimizerOptions, ...
            derivatives);
        finalValues = fmincon(derivatives.costFcn, initialValues, [], [], ...
            [], [], lowerBounds, upperbounds, [], optimizerOptions);
    else
        finalValues = fmincon(@(values)computeNeuralControlCostFunction(values, ...
            inputs, params), initialValues, [], [], [], [], lowerBounds, ...
            upperbounds, [], optimizerOptions);
    end
elseif strcmpi(inputs.synergy_vector_normalization_method,'sum')
    % linear constraints
    if params.useCasadi
        derivatives = prepareNcpCasadiDerivatives(inputs, params, ...
            numDesignVariables, []);
        optimizerOptions = applyCasadiOptimizerOptions(optimizerOptions, ...
            derivatives);
        finalValues = fmincon(derivatives.costFcn, initialValues, [], [], ...
            synergyWeightEquations, synergyWeightSums, lowerBounds, ...
            upperbounds, [], optimizerOptions);
    else
        finalValues = fmincon(@(values)computeNeuralControlCostFunction(values, ...
            inputs, params), initialValues, [], [], synergyWeightEquations, ...
            synergyWeightSums, lowerBounds, upperbounds, [], optimizerOptions);
    end
elseif strcmpi(inputs.synergy_vector_normalization_method,'magnitude')
    % nonlinear constraints
    normalizationTarget = sum(initWeights.^2, 2);   % (numSynergies x 1)
    if params.useCasadi
        derivatives = prepareNcpCasadiDerivatives(inputs, params, ...
            numDesignVariables, normalizationTarget);
        optimizerOptions = applyCasadiOptimizerOptions(optimizerOptions, ...
            derivatives);
        finalValues = fmincon(derivatives.costFcn, initialValues, [], [], ...
            [], [], lowerBounds, upperbounds, derivatives.constraintFcn, ...
            optimizerOptions);
    else
        finalValues = fmincon(@(values)computeNeuralControlCostFunction(values, ...
            inputs, params), initialValues, [], [], ...
            [], [], lowerBounds, upperbounds, ...
            @(values)nonlinearConstraints(values, inputs, normalizationTarget),optimizerOptions);
    end
else
    error('Unknown normalization method: %s', ...
        inputs.synergy_vector_normalization_method);
end
if ~inputs.optimize_synergy_vectors
    finalValues = [inputs.fixedSynergyVectorFlat; finalValues];
elseif inputs.enforce_bilateral_symmetry
    weightsVariables = finalValues(1:inputs.numWeightsPerGroup(1));
    finalValues = [weightsVariables; finalValues];
end
end

% ----------------------------------------------------------------------- 
function [synergyWeightEquations, synergyWeightSums, lowerBounds, upperBounds] = ...
    makeConstraints(inputs, numDesignVariables, initWeights)

if ~inputs.optimize_synergy_vectors
    synergyWeightEquations = [];
    synergyWeightSums      = [];
elseif strcmpi(inputs.synergy_vector_normalization_method, 'sum')
    if inputs.enforce_bilateral_symmetry
        activeGroups = inputs.synergyGroups(1);
        activeWeights = initWeights(1:inputs.synergyGroups{1}.numSynergies, ...
                                    1:length(inputs.synergyGroups{1}.muscleNames));
    else
        activeGroups  = inputs.synergyGroups;
        activeWeights = initWeights;
    end
    numActiveRows = sum(cellfun(@(g) g.numSynergies, activeGroups));
    synergyWeightEquations = zeros(numActiveRows, numDesignVariables);
    synergyWeightSums = sum(activeWeights, 2);
    row = 1; 
    column = 1;
    for i = 1:length(activeGroups)
        nSyn = activeGroups{i}.numSynergies;
        nMus = length(activeGroups{i}.muscleNames);
        for j = 1:nSyn
            synergyWeightEquations(row, column:column + nMus - 1) = 1;
            row = row + 1;
            column = column + nMus;
        end
    end
else
    synergyWeightEquations = [];
    synergyWeightSums      = [];
end
lowerBounds = zeros(numDesignVariables, 1);
upperBounds = inf(numDesignVariables, 1);
end

% ----------------------------------------------------------------------- 
function optimizerOptions = prepareOptimizerOptions(params)
optimizerOptions = optimoptions('fmincon', 'UseParallel',true);
optimizerOptions.DiffMinChange = params.diffMinChange;
optimizerOptions.OptimalityTolerance = params.optimalityTolerance;
optimizerOptions.FunctionTolerance = params.functionTolerance;
optimizerOptions.StepTolerance = params.stepTolerance;
optimizerOptions.MaxFunctionEvaluations = params.maxFunctionEvaluations;
optimizerOptions.MaxIterations = params.maxIterations;
optimizerOptions.Algorithm = params.algorithm;
optimizerOptions.FiniteDifferenceType = params.finiteDifferenceType;
optimizerOptions.Display = valueOrAlternate(params, ...
    'display','iter');
end

% ----------------------------------------------------------------------- 
function optimizerOptions = applyCasadiOptimizerOptions(optimizerOptions, ...
    derivatives)
% interior-point is required to accept a user-supplied HessianFcn
if ~strcmpi(optimizerOptions.Algorithm, 'interior-point')
    fprintf(['NCP: use_casadi requires the interior-point algorithm ' ...
        '(for exact Hessian support); overriding configured algorithm ' ...
        '"%s".\n'], optimizerOptions.Algorithm);
end
optimizerOptions.Algorithm = 'interior-point';
optimizerOptions.SpecifyObjectiveGradient = true;
optimizerOptions.SpecifyConstraintGradient = true;
optimizerOptions.HessianFcn = derivatives.hessianFcn;
% UseParallel only affects finite-difference gradient
optimizerOptions.UseParallel = false;
end

% ----------------------------------------------------------------------- 
function [c, ceq] = nonlinearConstraints(values, inputs, normalizationTarget)
if inputs.enforce_bilateral_symmetry
    weightsPart = values(1:inputs.numWeightsPerGroup(1));
    values = [weightsPart; values];
end

[weights, ~, ~] = findSynergyWeightsAndCommands(values, inputs);
c = [];
if inputs.enforce_bilateral_symmetry
    nSyn1 = inputs.synergyGroups{1}.numSynergies;
    ceq = sum(weights(1:nSyn1,:).^2, 2) - normalizationTarget(1:nSyn1);
else
    ceq = sum(weights.^2, 2) - normalizationTarget;
end
end

% -----------------------------------------------------------------------
% Adds a waitbar with a Cancel button
function optimizerOptions = addCancelButton(optimizerOptions, params)
waitbarHandle = waitbar(0, 'Optimizing NCP... click Cancel or closing the window to stop early', ...
    'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
optimizerOptions.OutputFcn = @(x, optimValues, state) ncpCancelButtonOutputFcn( ...
    optimValues, state, waitbarHandle, params.maxIterations);
end

function stop = ncpCancelButtonOutputFcn(optimValues, state, waitbarHandle, ...
    maxIterations)
stop = false;
if ~ishghandle(waitbarHandle)
    stop = true;
    return
end
if getappdata(waitbarHandle, 'canceling')
    stop = true;
end
if stop || strcmp(state, 'done')
    delete(waitbarHandle);
else
    fraction = min(optimValues.iteration / max(maxIterations, 1), 1);
    waitbar(fraction, waitbarHandle, sprintf( ...
        'Optimizing NCP (iteration %d, cost %.4g)... click Cancel or closing the window to stop early', ...
        optimValues.iteration, optimValues.fval));
end
end
