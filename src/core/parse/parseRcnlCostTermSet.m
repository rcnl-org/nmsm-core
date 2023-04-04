% This function is part of the NMSM Pipeline, see file for full license.
%
% Parses XML settings for a RCNLCostTermSet. An array of cost term field
% names for a tool's params struct and an array of cost term types
% supported by the tool are required, with corresponding names sharing an
% index. Terms not included in the RCNLCostTermSet found in these lists are
% added to the struct with default settings and the isEnabled flag set to
% false.
%
% (struct, struct, Array of string, Array of string) -> (struct)
% Parses settings from a RCNLCostTermSet.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2022 Rice University and the Authors                      %
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

function taskStruct = parseRcnlCostTermSet(tree, taskStruct, ...
    costTermFieldNames, costTermTypes)
for term = 1:length(tree)
    costTerm = tree.RCNLCostTermSet.objects.RCNLCostTerm{term};
    index = find(strcmpi(costTermTypes, costTerm.type.Text)); 
    if isempty(index)
        throw(MException('', ['Cost term type ' costTerm.type.Text ...
            ' does not exist for this tool']))
    end
    enabled = getTextFromField(getFieldByNameOrAlternate( ...
        costTerm, 'is_enabled', 'false'));
    taskStruct.costTerms.(costTermFieldNames(index)).isEnabled = ...
        strcmpi(enabled, 'true');
    taskStruct.costTerms.(costTermFieldNames(index)).maxAllowableError =...
        str2double(getTextFromField(getFieldByNameOrAlternate(costTerm, ...
        'max_allowable_error', '1')));
    taskStruct.costTerms.(costTermFieldNames(index)).errorCenter = ...
        str2double(getTextFromField(getFieldByNameOrAlternate(costTerm, ...
        'error_center', '0')));
end
% Account for cost terms not included in settings file
for i = 1:length(costTermFieldNames)
    if ~isstruct(getFieldByName(taskStruct.costTerms, ...
            costTermFieldNames(i)))
        taskStruct.costTerms.(costTermFieldNames(i)).isEnabled = false;
        taskStruct.costTerms.(costTermFieldNames(i)).maxAllowableError = 1;
        taskStruct.costTerms.(costTermFieldNames(i)).errorCenter = 0;
    end
end
end

