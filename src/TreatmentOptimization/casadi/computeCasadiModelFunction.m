% This function is part of the NMSM Pipeline, see file for full license.
%
% This function computes modeled values, constraints, and cost terms for
% CasADi. 
%
% (struct, struct) -> (struct, struct)
%

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

function [outputs, inputs] = computeCasadiModelFunction(casadiValues, ...
    inputs)
% Prepare values and modeled values
values = makeGpopsValuesAsStruct(casadiValues, inputs);
[inputs, values] = updateSystemFromUserDefinedFunctions(inputs, values);
modeledValues = calcSynergyBasedModeledValues(values, inputs);
modeledValues = calcTorqueBasedModeledValues(values, inputs, ...
    modeledValues);

% Dynamic constraint
outputs.dynamics = calcCasadiDynamicConstraint(values, inputs);

% Path constraints
persistent pathConstraintTermCalculations, persistent pathAllowedTypes;
if any(cellfun(@(x) x.isEnabled == 1, inputs.path))
    if isempty(pathAllowedTypes)
        [pathConstraintTermCalculations, pathAllowedTypes] = ...
            generateConstraintTermStruct("path", ...
            inputs.controllerTypes, inputs.toolName);
    end
    [outputs.path, inputs.path] = calcGpopsConstraint( ...
        inputs.path, pathConstraintTermCalculations, pathAllowedTypes, ...
        values, modeledValues, inputs);
end

% Continuous cost terms
[integrand, inputs] = calcGpopsIntegrand(values, modeledValues, inputs);

% Integrate continuous cost terms and modeled values
if ~isempty(integrand)
    integral = integrateRadauQuadrature(integrand, inputs, values.time);
else
    integral = [];
end
if valueOrAlternate(inputs, 'calculateMetabolicCost', false)
    modeledValues.metabolicCost = integrateRadauQuadrature( ...
        modeledValues.metabolicCost, inputs, values.time);
end
if valueOrAlternate(inputs, 'calculatePropulsiveImpulse', false)
    modeledValues.propulsiveImpulse = integrateRadauQuadrature( ...
        modeledValues.propulsiveImpulse, inputs, values.time);
end
if valueOrAlternate(inputs, 'calculateBrakingImpulse', false)
    modeledValues.brakingImpulse = integrateRadauQuadrature( ...
        modeledValues.brakingImpulse, inputs, values.time);
end

% Switch to endpoint function
values = reduceValuesToEndpoints(values);
modeledValues = reduceValuesToEndpoints(modeledValues);

% Terminal constraint terms
persistent terminalConstraintTermCalculations;
persistent terminalAllowedTypes;
if isempty(terminalAllowedTypes)
    [terminalConstraintTermCalculations, terminalAllowedTypes] = ...
        generateConstraintTermStruct("terminal", ...
        inputs.controllerTypes, inputs.toolName);
end
[outputs.terminal, inputs.terminal] = calcGpopsConstraint( ...
    inputs.terminal, terminalConstraintTermCalculations, ...
    terminalAllowedTypes, values, modeledValues, inputs);

% Discrete cost terms
persistent costTermCalculations, persistent allowedCostTypes;
if isempty(allowedCostTypes)
    [costTermCalculations, allowedCostTypes] = generateCostTermStruct( ...
        "discrete", inputs.controllerTypes, inputs.toolName);
end
[discrete, inputs] = calcTreatmentOptimizationCost( ...
    costTermCalculations, allowedCostTypes, values, modeledValues, inputs);
discreteObjective = sum(discrete) / length(discrete);
if isnan(discreteObjective); discreteObjective = 0; end

% Calculate total objective
if ~isempty(integral) && ~any(isnan(integral))
    if inputs.normalizeCostByType
        continuousObjective = normalizeCostByType( ...
            inputs.costTerms, allowedCostTypes, integral);
    else
        continuousObjective = sum(integral) / length(integral);
    end
else
    continuousObjective = 0;
end

outputs.objective = continuousObjective + discreteObjective;

% Store initial values if this is the first run
if valueOrAlternate(inputs, 'calculateMetabolicCost', false) && ...
        ~isfield(inputs, 'initialMetabolicCost')
    inputs.initialMetabolicCost = modeledValues.metabolicCost;
end
end

function endpointStruct = reduceValuesToEndpoints(continuousStruct)
fields = fieldnames(continuousStruct);
for i = 1 : length(fields)
    currentTerm = continuousStruct.(fields{i});
    if size(currentTerm, 1) > 2
        endpointStruct.(fields{i}) = currentTerm([1 end], :);
    else
        endpointStruct.(fields{i}) = currentTerm;
    end
end
end

function continuousObjective = normalizeCostByType(costTerms, ...
    allowedCostTypes, integral)
persistent termCounts, persistent numUnique;
if isempty(termCounts)
    isEnabled = cellfun(@(x) x.isEnabled, costTerms);
    if isempty(allowedCostTypes)
        isAllowed = isEnabled;
    else
        isAllowed = cellfun(@(x) ~ismember(x.type, allowedCostTypes), ...
            costTerms);
    end
    
    termNames = string(cellfun(@(x) x.type, costTerms, ...
        'UniformOutput', false));
    includedTermNames = termNames(isEnabled & isAllowed);
    termCounts = grouptransform(includedTermNames', includedTermNames', ...
        @numel)';
    numUnique = length(unique(includedTermNames));
end
continuousObjective = sum(integral ./ termCounts) / numUnique;
end
