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
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function [path, terminal] = parseRcnlConstraintTermSet(tree, toolName, ...
    controllerType)
path = {};
terminal = {};
for term = 1:length(tree)
    if length(tree) == 1
        currentTerm = tree;
    else
        currentTerm = tree{term};
    end
    tempTerm = struct();
    % Find general cost term elements
    tempTerm = struct();
    tempTerm.type = getTextFromField(getFieldByNameOrError( ...
        currentTerm, 'type'));
    [isValid, isPath] = isTypeValid(tempTerm.type, toolName, ...
        controllerType, currentTerm);
    if ~isValid
        throw(MException("ConstraintTermSet:InvalidType", ...
            strcat(tempTerm.type, " is not a valid constraint", ...
            " term for tool ", toolName)));
    end
    enabled = getTextFromField(getFieldByNameOrAlternate( ...
        currentTerm, 'is_enabled', 'false'));
    tempTerm.isEnabled = strcmpi(enabled, 'true');
    tempTerm.maxError = str2double(getTextFromField( ...
        getFieldByNameOrAlternate(currentTerm, 'max_error', '1')));
    tempTerm.minError = str2double(getTextFromField( ...
        getFieldByNameOrAlternate(currentTerm, 'min_error', '-1')));
    % Find other cost term elements
    termElements = fieldnames(currentTerm);
    for element = 1:length(termElements)
        if strcmp(termElements{element}, "Attributes")
            continue
        end
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
            elseif any(isspace(convertStringsToChars(contents)))
                contents = parseSpaceSeparatedList(currentTerm, ...
                    termElements{element});
            end
            tempTerm.(termElements{element}) = contents;
        end
    end
    if isPath
        path{end + 1} = tempTerm;
    else
        terminal{end + 1} = tempTerm;
    end
end
end

function [isValid, isPath] = isTypeValid(type, toolName, ...
    controllerType, currentTerm)
[~, allowedTypes] = ...
    generateConstraintTermStruct("path", controllerType, ...
    toolName);
isPath = true;
isValid = any(strcmp(type, allowedTypes));
if strcmp(type, "user_defined")
    currentTerm.type = type;
    constraintType = getTermFieldOrError(currentTerm, ...
        "constraint_term_type").Text;
    if strcmpi(constraintType, "terminal")
        isPath = false;
    end
end
if ~isValid
    [~, allowedTypes] = ...
        generateConstraintTermStruct("terminal", controllerType, ...
        toolName);
    isPath = false;
    isValid = any(strcmp(type, allowedTypes));
end
end
