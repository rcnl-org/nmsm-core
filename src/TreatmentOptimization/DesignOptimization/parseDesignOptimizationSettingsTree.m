% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct of the
% Design Optimizatoin settings XML file.
%
% (struct) -> (struct, struct)
% returns the input values for Design Optimization

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

function [inputs, params] = ...
    parseDesignOptimizationSettingsTree(settingsTree)
inputs = parseTreatmentOptimizationInputs(settingsTree);
inputs = parseDesignSettings(settingsTree, inputs);
inputs = parseUserDefinedFunctions(settingsTree, inputs);
params = parseTreatmentOptimizationParams(settingsTree);
inputs = modifyModelForces(inputs);
end

function inputs = parseUserDefinedFunctions(tree, inputs)
import org.opensim.modeling.Storage
inputs.systemFns = parseSpaceSeparatedList(tree, "model_functions");
parameterTree = getFieldByNameOrError(tree, "RCNLParameterTermSet");
if isstruct(parameterTree) && isfield(parameterTree, "RCNLParameterTerm")
    inputs.userDefinedVariables = parseRcnlCostTermSet( ...
        parameterTree.RCNLParameterTerm);
    for i = 1:length(inputs.userDefinedVariables)
        inputs.userDefinedVariables{i}.initial_values = ...
            stringToSpaceSeparatedList(inputs.userDefinedVariables{i}.initial_values);
        inputs.userDefinedVariables{i}.upper_bounds = ...
            stringToSpaceSeparatedList(inputs.userDefinedVariables{i}.upper_bounds);
        inputs.userDefinedVariables{i}.lower_bounds = ...
            stringToSpaceSeparatedList(inputs.userDefinedVariables{i}.lower_bounds);
    end
else
    inputs.userDefinedVariables = {};
end
end

function output = stringToSpaceSeparatedList(string)
if isnumeric(string)
    output = string;
    return;
end
string = strtrim(string);
output = strsplit(string, ' ');
output = str2double(output);
end

function inputs = parseDesignSettings(tree, inputs)
finalTimeRange = getFieldByName(tree, ...
    'final_time_range');
if(isstruct(finalTimeRange))
    inputs.finalTimeRange = getDoubleFromField(finalTimeRange);
end
end

