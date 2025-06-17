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

function [outputs, inputs] = ...
    computeCasadiFiniteDifferenceModelFunction(casadiValues, inputs, ...
    ~)
% persistent storedModeledValues;
% if nargin == 1
%     storedModeledValues = struct();
%     fields = fieldnames(casadiValues);
%     for field = string(fields)'
%         storedModeledValues.(field) = full(casadiValues.(field));
%     end
%     return
% end
% if nargin < 3
%     modeledValues = storedModeledValues;
% end

% Prepare values and modeled values
values = makeGpopsValuesAsStruct(casadiValues, inputs);
[inputs, values] = updateSystemFromUserDefinedFunctions(inputs, values);
modeledValues = calcSynergyBasedModeledValues(values, inputs);
modeledValues = calcTorqueBasedModeledValues(values, inputs, ...
    modeledValues);

% Path constraints
persistent pathConstraintTermCalculations, persistent pathAllowedTypes;
persistent pathNoAD;
if any(cellfun(@(x) x.isEnabled == 1, inputs.path))
    if isempty(pathAllowedTypes)
        [pathConstraintTermCalculations, pathAllowedTypes, ...
            pathSupportAD] = generateConstraintTermStruct("path", ...
            inputs.controllerTypes, inputs.toolName);
        pathNoAD = ~pathSupportAD;
    end
    [outputs.path, inputs.path] = calcCasadiConstraint( ...
        inputs.path, pathConstraintTermCalculations, pathAllowedTypes, ...
        values, modeledValues, inputs, pathNoAD);
end

% Continuous cost terms
[integrand, inputs] = calcCasadiIntegrand(values, modeledValues, ...
    inputs, false);

% Integrate continuous cost terms and modeled values
if ~isempty(integrand)
    integral = integrateRadauQuadrature(integrand, inputs, values.time);
else
    integral = [];
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
values = reduceValuesStructsToEndpoints(values);
modeledValues = reduceValuesStructsToEndpoints(modeledValues);

% Terminal constraint terms
persistent terminalConstraintTermCalculations;
persistent terminalAllowedTypes;
persistent terminalNoAD;
if isempty(terminalAllowedTypes)
    [terminalConstraintTermCalculations, terminalAllowedTypes, ...
        terminalSupportAD] = generateConstraintTermStruct("terminal", ...
        inputs.controllerTypes, inputs.toolName);
    terminalNoAD = ~terminalSupportAD;
end
[outputs.terminal, inputs.terminal] = calcCasadiConstraint( ...
    inputs.terminal, terminalConstraintTermCalculations, ...
    terminalAllowedTypes, values, modeledValues, inputs, terminalNoAD);

% Discrete cost terms
persistent costTermCalculations, persistent allowedCostTypes;
persistent costNoAD;
if isempty(allowedCostTypes)
    [costTermCalculations, allowedCostTypes, costSupportAD] = ...
        generateCostTermStruct("discrete", inputs.controllerTypes, ...
        inputs.toolName);
    costNoAD = ~costSupportAD;
end
[discrete, inputs] = calcCasadiTreatmentOptimizationCost( ...
    costTermCalculations, allowedCostTypes, values, modeledValues, ...
    inputs, costNoAD);
if ~isempty(discrete)
    discreteObjective = sum(discrete) / length(discrete);
else
    discreteObjective = 0;
end

% Calculate total objective
if ~isempty(integral)
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
