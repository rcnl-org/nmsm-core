% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (struct, struct) -> (None)
% Prints final user-defined parameters

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

function printUserDefinedVariablesToXml(solution, inputs)
if isfield(inputs, 'userDefinedVariables')
    counter = 1;
    if inputs.controllerTypes(2) && inputs.optimizeSynergyVectors
        for i = 1 : length(inputs.synergyGroups)
            counter = counter + inputs.synergyGroups{i}.numSynergies * ...
                length(inputs.synergyGroups{i}.muscleNames);
        end
    end
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
