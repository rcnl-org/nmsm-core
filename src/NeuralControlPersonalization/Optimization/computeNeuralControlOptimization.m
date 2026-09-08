% This function is part of the NMSM Pipeline, see file for full license.
%
% This function runs fmincon for Neural Control Personalization, preparing
% any necessary options and constraints for the optimizer. 
%
% The optional app is the GUI's run window. When one is given, its
% CancelOptimizationGui method is installed as fmincon's OutputFcn so the
% Cancel button can stop the solver, the same way MuscleTendonPersonalization
% and GroundContactPersonalization hook their run windows in. A scripted run
% passes no app and gets no OutputFcn at all.
%
% (Array of double, struct, struct, App) -> (Array of double)
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
    inputs, params, app)
if nargin < 4
    app = [];
end
[initWeights, ~, ~] = findSynergyWeightsAndCommands(initialValuesLong, inputs);
initialValues = initialValuesLong;
if inputs.enforce_bilateral_symmetry
    initialValues(1:inputs.numWeightsPerGroup(1)) = [];
end
numDesignVariables = length(initialValues);
[synergyWeightEquations, synergyWeightSums, lowerBounds, upperbounds] = ...
    makeConstraints(inputs, numDesignVariables, initWeights);
optimizerOptions = prepareOptimizerOptions(params, app);
if strcmpi(inputs.synergy_vector_normalization_method,'sum')
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
if inputs.enforce_bilateral_symmetry
    weightsVariables = finalValues(1:inputs.numWeightsPerGroup(1));
    finalValues = [weightsVariables; finalValues];
end
end

% Generate constraints for synergy weight vectors and design variable lower
% bounds
function [synergyWeightEquations, synergyWeightSums, lowerBounds, upperBounds] = ...
    makeConstraints(inputs, numDesignVariables, initWeights)

if strcmpi(inputs.synergy_vector_normalization_method, 'sum')
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
    % magnitude: nonlinear constraints handle normalization, 
    % no linear constraints needed
    synergyWeightEquations = [];
    synergyWeightSums      = [];
end
lowerBounds = zeros(numDesignVariables, 1);
upperBounds = inf(numDesignVariables, 1);
end

% Set optimizer options from params struct
function optimizerOptions = prepareOptimizerOptions(params, app)
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
% Lets the GUI's Cancel button stop the solver. The OutputFcn runs on the
% client, so unlike the cost function this closure is not shipped to the
% parallel workers.
if ~isempty(app) && ismethod(app, "CancelOptimizationGui")
    optimizerOptions.OutputFcn = @(x, optimValues, state) ...
        app.CancelOptimizationGui(x, optimValues, state);
end
end


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

function [c, ceq] = nonlinearConstraints(values, inputs, normalizationTarget)
if inputs.enforce_bilateral_symmetry
    weightsPart = values(1:inputs.numWeightsPerGroup(1));
    values = [weightsPart; values];
end

[weights, ~, ~] = findSynergyWeightsAndCommands(values, inputs);
c = [];
% Equality constraints: magnitude normalization per synergy
if inputs.enforce_bilateral_symmetry
    nSyn1 = inputs.synergyGroups{1}.numSynergies;
    ceq = sum(weights(1:nSyn1,:).^2, 2) - normalizationTarget(1:nSyn1);
else
    ceq = sum(weights.^2, 2) - normalizationTarget;
end
end
