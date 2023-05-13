% This function is part of the NMSM Pipeline, see file for full license.
%
% Parses XML settings for a RCNLCostTermSet, adding all fields included in 
% the xml block.  
%
% (struct) -> (struct)
% Parses settings from a RCNLCostTermSet.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2022 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function costTerms = parseRcnlConstraintTermSet(tree)
costTerms = cell(1, length(tree));
for term = 1:length(tree)
    if length(tree) == 1
        currentTerm = tree;
    else
        currentTerm = tree{term};
    end
    % Find general cost term elements
    costTerms{term}.type = getTextFromField(getFieldByNameOrError( ...
        currentTerm, 'type'));
    enabled = getTextFromField(getFieldByNameOrAlternate( ...
        currentTerm, 'is_enabled', 'false'));
    costTerms{term}.isEnabled = strcmpi(enabled, 'true');
    costTerms{term}.maxError = str2double(getTextFromField( ...
        getFieldByNameOrAlternate(currentTerm, 'max_error', '1')));
      costTerms{term}.minError = str2double(getTextFromField( ...
        getFieldByNameOrAlternate(currentTerm, 'min_error', '-1')));
    % Find other cost term elements
    termElements = fieldnames(currentTerm);
    for element = 1:length(termElements)
        if isempty(intersect(termElements{element}, ["type" ...
                "is_enabled" "max_error" "min_error"]))
            contents = getTextFromField(getFieldByNameOrError( ...
                currentTerm, termElements{element}));
            if strcmpi(contents, "true")
                contents = true;
            elseif strcmpi(contents, "false")
                contents = false;
            elseif ~isnan(str2double(contents))
                contents = str2double(contents);
            end
            costTerms{term}.(termElements{element}) = contents;
        end
    end 
end
end

