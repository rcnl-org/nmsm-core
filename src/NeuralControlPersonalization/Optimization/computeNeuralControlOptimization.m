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
numDesignVariables = length(initialValues);
[synergyWeightEquations, synergyWeightSums, lowerBounds] = ...
    makeConstraints(inputs, numDesignVariables);
optimizerOptions = prepareOptimizerOptions(params);
finalValues = fmincon(@(values)computeNeuralControlCostFunction(values, ...
    inputs, params), initialValues, [], [], synergyWeightEquations, ...
    synergyWeightSums, lowerBounds, [], [], optimizerOptions);
end

% Generate constraints for synergy weight vectors and design variable lower
% bounds
function [synergyWeightEquations, synergyWeightSums, lowerBounds] = ...
    makeConstraints(inputs, numDesignVariables)
synergyWeightEquations = zeros(inputs.numSynergies, numDesignVariables);
synergyWeightSums = 1*ones(inputs.numSynergies, 1);
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
end

% Set optimizer options from params struct
function optimizerOptions = prepareOptimizerOptions(params)
optimizerOptions = optimoptions('fmincon', 'UseParallel', 'always');
optimizerOptions.DiffMinChange = valueOrAlternate(params, ...
    'diffMinChange', 1e-6);
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
end
