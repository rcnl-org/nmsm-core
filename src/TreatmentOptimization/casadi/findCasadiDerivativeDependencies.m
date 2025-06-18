% This function is part of the NMSM Pipeline, see file for full license.
%
% This function uses NaN to find derivative dependencies, similar to what
% is described in the GPOPS-II publication (Patterson and Rao 2013).
%
% (struct, struct) -> (struct, struct)
% Find derivative dependencies before solving Treatment Optimization. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function [derivativeDependencies, casadiDependencies] = ...
    findCasadiDerivativeDependencies(inputs)
valuesStruct.state = inputs.guess.phase.state;
valuesStruct.control = inputs.guess.phase.control;
valuesStruct.parameter = valueOrAlternate(inputs.guess.phase, 'parameter', []);

% Create a separate sparse dependency matrix for every input/output combo
outputsFields = setdiff(string(fieldnames(inputs.initialOutputs)), ...
    "dynamics", 'stable');
valuesFields = string(fieldnames(valuesStruct));
derivativeDependencies = cell(length(outputsFields), length(valuesFields));
totalTests = 0;
for i = 1 : length(outputsFields)
    for j = 1 : length(valuesFields)
        derivativeDependencies{i, j} = sparse( ...
            numel(inputs.initialOutputs.(outputsFields(i))), ...
            numel(valuesStruct.(valuesFields(j))));
        if i == 1
            totalTests = totalTests + ...
                numel(valuesStruct.(valuesFields(j)));
        end
    end
end

% Handle AD derivatives separately
% [~, modeledValues] = computeCasadiSymbolicModelFunction(valuesStruct);
% computeCasadiFiniteDifferenceModelFunction(modeledValues);

% Find finite difference dependencies using NaN method
currentTest = 0;
reverseStr = '';
fprintf('\n')
disp("Finding finite difference derivative dependencies...")
for i = 1 : length(valuesFields)
    for j = 1 : numel(valuesStruct.(valuesFields(i)))
        testValues = valuesStruct;
        % Run model function with a single broken (NaN) input
        testValues.(valuesFields(i))(j) = nan;
        outputs = computeCasadiFiniteDifferenceModelFunction( ...
            testValues, inputs);
        
        % All broken (NaN) outputs depended on the broken input
        for k = 1 : length(outputsFields)
            derivativeDependencies{k, i}( ...
                isnan(outputs.(outputsFields(k))(:)), j) = true;
        end

        updatePeriod = 50;
        if mod(j, updatePeriod) == 0
            currentTest = currentTest + updatePeriod;
            reverseStr = printProgressBar(currentTest, totalTests, ...
                reverseStr);
        end
    end

%     currentTest = currentTest + numel(valuesStruct.(valuesFields(i)));
%     reverseStr = printProgressBar(currentTest, totalTests, reverseStr);
end
reverseStr = printProgressBar(totalTests, totalTests, reverseStr);
fprintf('\n\n')

% Convert Matlab dependencies to CasADi Sparsity structures
casadiDependencies = cell(size(derivativeDependencies));
for i = 1 : numel(casadiDependencies)
    if numel(derivativeDependencies{i}) == 0
        casadiDependencies{i} = [];
    else
        casadiDependencies{i} = casadi.Sparsity.nonzeros( ...
            size(derivativeDependencies{i}, 1), ...
            size(derivativeDependencies{i}, 2), ...
            find(derivativeDependencies{i}));
    end
end
end
