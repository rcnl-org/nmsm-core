% This function is part of the NMSM Pipeline, see file for full license.
%
% Parses XML settings for a RCNLCostTermSet. An array of cost term types
% supported by the tool is required, and the program will end if the
% settings file contains a cost term not supported by the current tool. 
%
% (struct, Array of string) -> (struct)
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

function costTerms = parseRcnlCostTermSet(tree, costTermTypes)
costTerms = cell(1, length(tree));
for term = 1:length(tree)
    currentTerm = tree{term};
    % Find general cost term elements
    costTerms{term}.type = getTextFromField(getFieldByNameOrError( ...
        currentTerm, 'type'));
    % Check that cost term exists for tool
    index = find(strcmpi(costTermTypes, costTerms{term}.type), 1);
    if isempty(index)
        throw(MException('', ['Cost term type ' costTerms{term}.type ...
            ' does not exist for this tool']))
    end
    enabled = getTextFromField(getFieldByNameOrAlternate( ...
        currentTerm, 'is_enabled', 'false'));
    costTerms{term}.isEnabled = strcmpi(enabled, 'true');
    costTerms{term}.maxAllowableError = str2double(getTextFromField( ...
        getFieldByNameOrAlternate(currentTerm, ...
        'max_allowable_error', '1')));
    costTerms{term}.errorCenter = str2double(getTextFromField( ...
        getFieldByNameOrAlternate(currentTerm, 'error_center', '0')));
    % Find context-specific cost term elements
    try
        costTerms{term}.coordinate = getTextFromField( ...
            getFieldByNameOrError(currentTerm, 'coordinate'));
    catch
    end
end
end

