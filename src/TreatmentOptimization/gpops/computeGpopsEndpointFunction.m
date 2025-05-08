% This function is part of the NMSM Pipeline, see file for full license.
%
% This function computes the terminal constraint (if any), and total cost
% function objective for gpops treatment optimization.
%
% (struct) -> (struct)
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function output = computeGpopsEndpointFunction(setup)
    setup.phase.state = [setup.phase.initialstate; setup.phase.finalstate];
    setup.phase.time = [setup.phase.initialtime; setup.phase.finaltime];
    setup.phase.control = ones(size(setup.phase.time,1),length(setup.auxdata.minControl));
    if isfield(setup, "parameter")
        setup.phase.parameter = setup.parameter;
    end
    values = makeGpopsValuesAsStruct(setup.phase, setup.auxdata);
    if strcmp(setup.auxdata.toolName, "DesignOptimization")
        [setup, values] = updateSystemFromUserDefinedFunctions(setup, values);
    end
    modeledValues = calcSynergyBasedModeledValues(values, setup.auxdata);
    modeledValues = calcTorqueBasedModeledValues(values, setup.auxdata, ...
        modeledValues);
    counter = 0;
    if valueOrAlternate(setup.auxdata, 'calculatePropulsiveImpulse', false)
        modeledValues.propulsiveImpulse = setup.phase.integral( ...
            end - length(setup.auxdata.contactSurfaces) + 1 : end);
        counter = counter + length(setup.auxdata.contactSurfaces);
    end
    if valueOrAlternate(setup.auxdata, 'calculateBrakingImpulse', false)
        modeledValues.brakingImpulse = setup.phase.integral( ...
            end - length(setup.auxdata.contactSurfaces) - counter + 1 : end - counter);
    end
    if valueOrAlternate(setup.auxdata, 'calculateMetabolicCost', false)
        modeledValues.metabolicCost = setup.phase.integral(end - counter);
    end

persistent constraintTermCalculations, persistent allowedConstraintTypes;
if isempty(allowedConstraintTypes)
    [constraintTermCalculations, allowedConstraintTypes] = ...
        generateConstraintTermStruct("terminal", ...
        setup.auxdata.controllerTypes, setup.auxdata.toolName);
end
event = ...
    calcGpopsConstraint(setup.auxdata.terminal, ...
    constraintTermCalculations, allowedConstraintTypes, values, ...
    modeledValues, setup.auxdata);
if ~isempty(event)
    output.eventgroup.event = event;
end

persistent costTermCalculations, persistent allowedCostTypes;
if isempty(allowedCostTypes)
    [costTermCalculations, allowedCostTypes] = ...
        generateCostTermStruct("discrete", setup.auxdata.controllerTypes, setup.auxdata.toolName);
end
discrete = calcTreatmentOptimizationCost( ...
    costTermCalculations, allowedCostTypes, values, modeledValues, setup.auxdata);
discreteObjective = sum(discrete) / length(discrete);
if isnan(discreteObjective); discreteObjective = 0; end


if isfield(setup.phase, "integral") && ~any(isnan(setup.phase.integral)) && ~isempty(setup.phase.integral)
    integral = setup.phase.integral;
    if valueOrAlternate(setup.auxdata, 'calculateMetabolicCost', false)
        integral = integral(1:end-1);
    end
    if valueOrAlternate(setup.auxdata, 'calculateBrakingImpulse', false)
        for i = 1:length(setup.auxdata.contactSurfaces)
            integral = integral(1:end-1);
        end
    end
    if valueOrAlternate(setup.auxdata, 'calculatePropulsiveImpulse', false)
        for i = 1:length(setup.auxdata.contactSurfaces)
            integral = integral(1:end-1);
        end
    end
    if isempty(integral)
        continuousObjective = 0;
    else
        if setup.auxdata.normalizeCostByType
            continuousObjective = normalizeCostByType( ...
                setup.auxdata.costTerms, allowedCostTypes, integral);
        else
            continuousObjective = sum(integral) / length(integral);
        end
    end
else
    continuousObjective = 0;
end

output.objective = continuousObjective + discreteObjective;
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
