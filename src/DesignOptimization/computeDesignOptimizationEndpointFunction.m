% This function is part of the NMSM Pipeline, see file for full license.
%
% This function computes the terminal constraint (if any), discrete 
% objective (if any), and total cost function objective.
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
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function output = computeDesignOptimizationEndpointFunction(inputs)

inputs.phase.state = [inputs.phase.initialstate; inputs.phase.finalstate];
inputs.phase.time = [inputs.phase.initialtime; inputs.phase.finaltime];
inputs.phase.control = ones(size(inputs.phase.time,1), ...
    length(inputs.auxdata.minControl));
phase = inputs.phase;
if isfield(inputs, "parameter")
    phase.parameter = inputs.parameter;
end
values = getDesignOptimizationValueStruct(phase, inputs.auxdata);
inputs = updateSystemFromUserDefinedFunctions(inputs, values);
modeledValues = calcTorqueBasedModeledValues(values, inputs.auxdata);

if ~isempty(inputs.auxdata.terminal)
    output.eventgroup.event = calcDesignOptimizationTerminalConstraint( ...
        values, modeledValues, inputs.auxdata);
end
discrete = calcDesignOptimizationDiscreteObjective(values, ...
    modeledValues, inputs.auxdata);
% discrete = computeStaticParameterCost(inputs);
output.objective = calcDesignOptimizationObjective(discrete, ...
    inputs.phase.integral, values.time(end), inputs.auxdata);
end

function cost = computeStaticParameterCost(inputs)
costTerms = inputs.auxdata.costTerms;
cost = 0;
for i = 1:length(costTerms)
    costTerm = costTerms{i};
    if strcmp(costTerm.type, "user_defined") && ...
            strcmp(costTerm.cost_term_type, "discrete")
        func = str2func(costTerm.function_name);
        cost = cost + func(inputs);
    end
end
end