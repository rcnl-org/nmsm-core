% This function is part of the NMSM Pipeline, see file for full license.
%
% This function saves and prints the unscaled results from
% Design Optimization. An osim model may also be printed if model specific
% values were optimized
%
% (struct, struct) -> (None)
% Prints design optimization results

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Spencer Williams                               %
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

function saveDesignOptimizationResults(solution, inputs)
values = makeGpopsValuesAsStruct(solution.solution.phase, inputs);
if isfield(inputs, "systemFns")
    inputs.auxdata = inputs;
    [inputs, values] = updateSystemFromUserDefinedFunctions(inputs, values);
    model = Model(inputs.auxdata.model);
    model.print(strrep(inputs.mexModel, '_inactiveMuscles.osim', 'DesignOpt.osim'));
end
if inputs.controllerTypes(2)
    values = normalizeSynergySolution(values, inputs);
end
printUserDefinedVariablesToXml(solution, inputs);
saveTreatmentOptimizationResults(solution, inputs, values);
end

function printUserDefinedVariablesToXml(solution, inputs)
if isfield(inputs, 'userDefinedVariables')
    counter = 1;
    for i = 1:length(inputs.userDefinedVariables)
        numParameters = length(inputs.userDefinedVariables{i}.initial_values);
        parameterResults = scaleToOriginal( ...
            solution.solution.phase.parameter( ...
            counter : counter + numParameters - 1), ...
            inputs.userDefinedVariables{i}.upper_bounds, ...
            inputs.userDefinedVariables{i}.lower_bounds);
        counter = counter + numParameters;
        valuesStr = num2str(parameterResults(1));
        for j = 2:length(parameterResults)
            valuesStr = strcat(valuesStr, " ", num2str(parameterResults(j)));
        end
        parameters.NMSMPipelineDocument.RCNLParameters{i}.RCNLParameterSet.type = inputs.userDefinedVariables{i}.type;
        parameters.NMSMPipelineDocument.RCNLParameters{i}.RCNLParameterSet.values = convertStringsToChars(valuesStr);
        struct2xml(parameters, fullfile(inputs.resultsDirectory, ...
            strcat(inputs.trialName, "_parameterSolution.xml")));
    end
end
end

function values = normalizeSynergySolution(values, inputs)
values.controllerTypes = inputs.controllerTypes;
values.initialSynergyControls = values.controlSynergyActivations;
values.synergyNormalizationMethod = inputs.synergyNormalizationMethod;
values.synergyNormalizationValue = inputs.synergyNormalizationValue;
values = normalizeSynergyData(values);
values.controlSynergyActivations = values.initialSynergyControls;
end