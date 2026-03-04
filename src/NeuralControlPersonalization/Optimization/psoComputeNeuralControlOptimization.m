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

function finalValues = psoComputeNeuralControlOptimization(initialValuesLong, ...
    inputs, params)
[initWeights, ~, ~] = findSynergyWeightsAndCommands(initialValuesLong, inputs);
initialValues = initialValuesLong;
if inputs.use_bilateral_symmetry
    initialValues(1:inputs.numWeightsOneLeg) = [];
end
numDesignVariables = length(initialValues);
[synergyWeightEquations, synergyWeightSums, lowerBounds, upperbounds] = ...
    makeConstraints(inputs, numDesignVariables, initWeights);
optimizerOptions = prepareOptimizerOptions(params);

if strcmpi(inputs.synergy_vector_normalization_method,'magnitude')
    % nonlinear constraints
    finalValues = fmincon(@(values)computeNeuralControlCostFunction(values, ...
        inputs, params, initialValuesLong), initialValues, [], [], [], [], lowerBounds, upperbounds, ...
        @(values)nonlinearConstraints(values, inputs, params), optimizerOptions);

elseif strcmpi(inputs.synergy_vector_normalization_method,'sum')
    % linear constraints
    % finalValues = fmincon(@(values)computeNeuralControlCostFunction(values, ...
    %     inputs, params, initialValuesLong), initialValues, [], [], ...
    %     synergyWeightEquations, synergyWeightSums, lowerBounds, [], [], optimizerOptions);
    psoOptions = psoset('Display','iter','MaxFunEvals',100000,'Plot','output');
    fprintf('Solving optimization problem using pso:\n')
    finalValues = pso(@(values)psoComputeNeuralControlCostFunction(values, ...
        inputs, params, initialValuesLong, synergyWeightEquations, ...
        synergyWeightSums),initialValues,lowerBounds,upperbounds,psoOptions);
else
    error('Unknown normalization method: %s', ...
        inputs.synergy_vector_normalization_method);
end

if inputs.use_bilateral_symmetry
    weightsVariables = finalValues(1:inputs.numWeightsOneLeg);
    finalValues = [weightsVariables; finalValues];
    weightsVariablesInit = initialValues(1:inputs.numWeightsOneLeg);
    initialValues = [weightsVariablesInit; initialValues];
end
initActivations = calcActivationsFromSynergyDesignVariables(initialValues, inputs);
finalActivations = calcActivationsFromSynergyDesignVariables(finalValues, inputs);
fprintf('[computeNeuralControlOptimization] Compare init and final activation: \n');
fprintf('  Init activation range: [%g, %g], error = %g\n', min(initActivations(:)), max(initActivations(:)), mean((initActivations(:) - inputs.mtpActivations(:)).^2));
fprintf('  Final activation range: [%g, %g], error = %g\n', min(finalActivations(:)), max(finalActivations(:)), mean((finalActivations(:) - inputs.mtpActivations(:)).^2));

% Reorder synergies to enforce a consistent ordering for easier comparison
% [initialValues, finalValues] = reorderDesignVariables(initialValues, finalValues, inputs, params);
[initialValues, finalValues] = reorderUsingSimilarity(initialValues, finalValues, inputs);
plotSynergyWeightsComparison(initialValues, finalValues, inputs);

end


function  cost = psoComputeNeuralControlCostFunction(values_short, inputs, params, ...
    initialValues, synergyWeightEquations, synergyWeightSums)
if inputs.use_bilateral_symmetry
    weights_part = values_short(1:inputs.numWeightsOneLeg);
    values = [weights_part; values_short];
end
[activations, ~] = calcActivationsFromSynergyDesignVariables(values, inputs);

error = [];
weightsByGroup = findSynergyWeightsByGroup(values, inputs);

% Split activations into subsets ahead of cost computation
if isfield(inputs, 'mtpActivationsColumnNames')
    [activationsWithMtpData, activationsWithoutMtpData] = ...
        makeMtpActivatonSubset(activations, ...
        inputs.mtpActivationsColumnNames, inputs.muscleTendonColumnNames);
else
    activationsWithoutMtpData = activations;
end
for term = 1:length(params.costTerms)
    costTerm = params.costTerms{term};
    if costTerm.isEnabled
        switch costTerm.type
            case "moment_tracking"
                [normalizedFiberLengths, normalizedFiberVelocities] = ...
                    calcNormalizedMuscleFiberLengthsAndVelocities( ...
                    inputs, inputs.optimalFiberLengthScaleFactors, ...
                    inputs.tendonSlackLengthScaleFactors);
                muscleJointMoments = calcMuscleJointMoments(inputs, ...
                    activations, normalizedFiberLengths, ...
                    normalizedFiberVelocities);
                rawCost = muscleJointMoments - ...
                    inputs.inverseDynamicsMoments; 
                % fprintf("moment_tracking\n")
            case "activation_tracking"
                if isfield(inputs, 'mtpActivations')
                    rawCost = activationsWithMtpData - inputs.mtpActivations;
                else
                    rawCost = 0;
                end
                % fprintf("activation_tracking\n")
            case "bilateral_symmetry"
                if length(inputs.synergyGroups) ~= 2
                    throw(MException('', ['Bilateral symmetry cost ' ...
                        'requires exactly two synergy groups.']))
                end
                rawCost = weightsByGroup(1, :, :) - weightsByGroup(2, :, :);
                % fprintf("bilateral_symmetry\n")
        end
        rawCost = rawCost(:);
        rawCost_scaled = (rawCost/ costTerm.maxAllowableError) / sqrt(numel(rawCost));
        error = [error; rawCost_scaled];
    end
end
constraint_err = synergyWeightSums-synergyWeightEquations*values_short;
constraint_err_maxAllowableError = 5;
constraint_err_scaled = (constraint_err/ constraint_err_maxAllowableError) / sqrt(numel(constraint_err));
error = [error; constraint_err_scaled];
cost = error' * error;
end


function [data1, data2] = reorderUsingSimilarity(data1, data2, inputs)
[weights1, ~, ~] = findSynergyWeightsAndCommands(data1, inputs);
[weights2, ~, commandNodes2] = findSynergyWeightsAndCommands(data2, inputs);

numSyn = size(weights1,1);
similarity = zeros(numSyn, numSyn);
for i = 1:numSyn
    for j = 1:numSyn
        similarity(i,j) = cosineSim(weights1(i,:), weights2(j,:));
    end
end
% for each i pick best unused 
perm = zeros(1,numSyn);
used = false(1,numSyn);
for i = 1:numSyn
    row = similarity(i,:);
    row(used) = -Inf;
    [~, j] = max(row);
    perm(i) = j;
    used(j) = true;
end
% apply to data2
weights2 = weights2(perm,:);
commandNodes2 = commandNodes2(:,:,perm);
fprintf('[reorderUsingSimilarity] perm (data2 -> data1 order): '); fprintf('%d ', perm); fprintf('\n');

data2 = repackDesignVariables(weights2, commandNodes2, inputs);
end

function s = cosineSim(a,b)
a = a(:); b = b(:);
na = norm(a); nb = norm(b);
if na < eps || nb < eps
    s = 0;
else
    s = (a' * b) / (na * nb);
end
end

% Generate constraints for synergy weight vectors and design variable bounds
function [synergyWeightEquations, synergyWeightSums, lowerBounds, upperBounds] = ...
    makeConstraints(inputs, numDesignVariables, initWeights)
% for linear sum constraint use (only positive synergy)
initWeightSum = sum(initWeights,2);
numSynergiesOneLeg = inputs.synergyGroups{1}.numSynergies;
numMuscleOneLeg = length(inputs.synergyGroups{1}.muscleNames);
row = 1; 
column = 1;
if inputs.use_bilateral_symmetry
    synergyWeightEquations = zeros(numSynergiesOneLeg, numDesignVariables);
    % synergyWeightSums = zeros(numSynergiesOneLeg, 1);
    synergyWeightSums = initWeightSum(1:numSynergiesOneLeg);
        for j = 1: numSynergiesOneLeg
            synergyWeightEquations(row, column:column + ...
                numMuscleOneLeg - 1) = 1;
            % synergyWeightSums(row) = numMuscleOneLeg / 100;
            row = row + 1;
            column = column + numMuscleOneLeg;
        end
else
    synergyWeightEquations = zeros(inputs.numSynergies, numDesignVariables);
    % synergyWeightSums = zeros(inputs.numSynergies, 1);
    synergyWeightSums = initWeightSum;
    for i = 1:length(inputs.synergyGroups)
        for j = 1: inputs.synergyGroups{i}.numSynergies
            synergyWeightEquations(row, column:column + ...
                length(inputs.synergyGroups{i}.muscleNames) - 1) = 1;
            % synergyWeightSums(row) = ...
            %     length(inputs.synergyGroups{i}.muscleNames) / 100;
            row = row + 1;
            column = column + length(inputs.synergyGroups{i}.muscleNames);
        end
    end
end

lowerBounds = zeros(numDesignVariables, 1);
upperBounds = ones(numDesignVariables, 1)*10;

numberOfWeights = 0;
if inputs.use_bilateral_symmetry
    numberOfWeights = inputs.numWeightsOneLeg;
else
    for g = 1:length(inputs.synergyGroups)
        numberOfWeights = numberOfWeights + length(inputs.synergyGroups{g}.muscleNames)...
            * inputs.synergyGroups{g}.numSynergies;
    end
end
if inputs.allow_negative_synergy_vector_weights
    lowerBounds(1:numberOfWeights) = -Inf;
    upperBounds(1:numberOfWeights) = Inf;

    % maxValue = max(initialValues(:))*1.5;
    % lowerBounds(1:numberOfWeights) = -maxValue;
    % upperBounds(1:numberOfWeights) = maxValue;
end
end

% Set optimizer options from params struct
function optimizerOptions = prepareOptimizerOptions(params)
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
% optimizerOptions.ConstraintTolerance = valueOrAlternate(params,'ConstraintTolerance', 1e-5);
% optimizerOptions.TypicalX = valueOrAlternate(params,'TypicalX', initialValues);
% optimizerOptions.FiniteDifferenceType = valueOrAlternate(params,'FiniteDifferenceType', 'central');
% optimizerOptions.FiniteDifferenceStepSize = valueOrAlternate(params,'FiniteDifferenceStepSize', 1e-6);
% optimizerOptions.EnableFeasibilityMode = valueOrAlternate(params,'EnableFeasibilityMode', true);
% optimizerOptions.ScaleProblem = valueOrAlternate(params,'ScaleProblem', 'obj-and-constr');

optimizerOptions.PlotFcn = {@optimplotfval, @optimplotconstrviolation, @optimplotstepsize};
end

function [c, ceq] = nonlinearConstraints(values, inputs, params)  
if inputs.use_bilateral_symmetry
    weights_part = values(1:inputs.numWeightsOneLeg);
    values = [weights_part; values];
end
[synergyActivations, weights] = calcActivationsFromSynergyDesignVariables(values, inputs);
normalizationTarget = inputs.synergy_vector_normalization_value;        
switch lower(params.algorithm)
    case 'interior-point'
        if inputs.use_activation_saturation
            %  -0.5 <= activation <= 1.5
            c = [ synergyActivations(:) - 1.5;  
                 -synergyActivations(:) - 0.5]; 
        else
            %   0 <= activation <= 1
            c = [ synergyActivations(:) - 1;   
                 -synergyActivations(:)];   
        end

        % if use_bilateral_symmetry
        %     ceq = zeros(inputs.numSynergies/2, 1, 'double');
        % else
        %     ceq = zeros(inputs.numSynergies, 1, 'double');
        % end
        ceq = zeros(inputs.numSynergies, 1, 'double');
        valuesIndex = 1;
        row = 1; 
        for i = 1:length(inputs.synergyGroups)
            numSynergies = inputs.synergyGroups{i}.numSynergies;
            for j = 1:numSynergies
                weightsTemp = weights(valuesIndex, :);
                % norm: ||w||^2 = target^2
                ceq(row) = sum(weightsTemp.^2) - normalizationTarget^2;
                valuesIndex = valuesIndex + 1;
                row = row + 1;
            end
            % if use_bilateral_symmetry
            %     break;
            % end
        end
    case 'sqp'
        c   = [];
        ceq = [];

        % tolerance = 1e-6;
        % targetLow  = (1-tolerance)*normalizationTarget;
        % targetHigh = (1+tolerance)*normalizationTarget;
        % 
        % valuesIndex = 1;
        % row = 1;
        % for i = 1:length(inputs.synergyGroups)
        %     numSynergies = inputs.synergyGroups{i}.numSynergies;
        %     numMuscle = length(inputs.synergyGroups{i}.muscleNames);
        %     for j = 1:numSynergies
        %         weights = values(valuesIndex:(valuesIndex + numMuscle - 1));
        %         norm2 = sum(weights.^2);
        %         % upper bound:  ||w||^2 - targetHigh^2 <= 0
        %         c(row)   = norm2 - targetHigh^2;
        %         % lower bound:  targetLow^2 - ||w||^2 <= 0
        %         c(row+1) = targetLow^2 - norm2;
        % 
        %         valuesIndex = valuesIndex + numMuscle;
        %         row = row + 2;
        %     end
        % end
end
end