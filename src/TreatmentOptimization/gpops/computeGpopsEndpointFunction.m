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
if any(cellfun(@(x) x.isEnabled == 1, setup.auxdata.terminal)) || strcmp(setup.auxdata.toolName, "DesignOptimization")
    setup.phase.state = [setup.phase.initialstate; setup.phase.finalstate];
    setup.phase.time = [setup.phase.initialtime; setup.phase.finaltime];
    setup.phase.control = ones(size(setup.phase.time,1),length(setup.auxdata.minControl));
    if isfield(setup, "parameter")
        setup.phase.parameter = setup.parameter;
    end
    values = makeGpopsValuesAsStruct(setup.phase, setup.auxdata);
    if strcmp(setup.auxdata.toolName, "DesignOptimization")
        setup = updateSystemFromUserDefinedFunctions(setup, values);
    end
    modeledValues = calcTorqueBasedModeledValues(values, setup.auxdata);
    modeledValues = calcSynergyBasedModeledValues(values, setup.auxdata, ...
        modeledValues);
end

if any(cellfun(@(x) x.isEnabled == 1, setup.auxdata.terminal))
    [constraintTermCalculations, allowedTypes] = ...
        generateConstraintTermStruct("terminal", ...
        setup.auxdata.controllerType, setup.auxdata.toolName);
    event = ...
        calcGpopsConstraint(setup.auxdata.terminal, ...
        constraintTermCalculations, allowedTypes, values, ...
        modeledValues, setup.auxdata);
    if ~isempty(event)
        output.eventgroup.event = event;
    end
end

if strcmp(setup.auxdata.toolName, "DesignOptimization")
    [costTermCalculations, allowedTypes] = ...
        generateCostTermStruct("discrete", "DesignOptimization");
    discrete = calcTreatmentOptimizationCost( ...
        costTermCalculations, allowedTypes, values, modeledValues, setup.auxdata);
    discrete = discrete ./ setup.auxdata.discreteMaxAllowableError;
    discreteObjective = sum(discrete) / length(discrete);
    if isnan(discreteObjective); discreteObjective = 0; end
else
    discreteObjective = 0;
end

if isfield(setup.phase, "integral") && any(isnan(setup.phase.integral))
    continuousObjective = sum(setup.phase.integral) / length(setup.phase.integral);
else
    continuousObjective = 0;
end

output.objective = continuousObjective + discreteObjective;
end
