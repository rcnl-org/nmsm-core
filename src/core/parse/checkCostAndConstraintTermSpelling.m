% This function is part of the NMSM Pipeline, see file for full license.
%
% 
% (struct, struct) -> (None)
% If supported, validate cost and constraint names.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
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

function checkCostAndConstraintTermSpelling(inputs)
% Only use spell checking if dependencies are installed
if ~license('test', 'Text_Analytics_Toolbox') || ~inputs.checkFieldSpelling
    return
end

% Set up reference term lists
[~, allowedContinuousCostTypes] = generateCostTermStruct("continuous", ...
    inputs.controllerTypes, inputs.toolName);
[~, allowedDiscreteCostTypes] = generateCostTermStruct("discrete", ...
    inputs.controllerTypes, inputs.toolName);
allowedCostTypes = unique(["", allowedContinuousCostTypes, ...
    allowedDiscreteCostTypes]);
[~, allowedPathConstraintTypes] = generateConstraintTermStruct("path", ...
    inputs.controllerTypes, inputs.toolName);
[~, allowedTerminalConstraintTypes] = generateConstraintTermStruct( ...
    "terminal", inputs.controllerTypes, inputs.toolName);
allowedConstraintTypes = unique(["", allowedPathConstraintTypes, ...
    allowedTerminalConstraintTypes]);

% Find used term names
usedCostTypes = unique(cellfun(@(term) string(term.type), ...
    inputs.costTerms));
usedConstraintTypes = unique([cellfun(@(term) string(term.type), ...
    inputs.path), cellfun(@(term) string(term.type), inputs.terminal)]);

% Check spelling
costSearcher = editDistanceSearcher(allowedCostTypes, 8);
costIndices = knnsearch(costSearcher, usedCostTypes);
costIndices(isnan(costIndices)) = 1;
correctCosts = allowedCostTypes(costIndices);
costCorrectionIndices = ~strcmp(usedCostTypes, correctCosts);
constraintSearcher = editDistanceSearcher(allowedConstraintTypes, 8);
constraintIndices = knnsearch(constraintSearcher, usedConstraintTypes);
constraintIndices(isnan(constraintIndices)) = 1;
correctConstraints = allowedConstraintTypes(constraintIndices);
constraintCorrectionIndices = ~strcmp(usedConstraintTypes, ...
    correctConstraints);

% Report detected errors
errorString = string(newline);
for i = 1 : length(costCorrectionIndices)
    if costCorrectionIndices(i)
        if costIndices(i) == 1
            errorString = errorString + usedCostTypes(i) + " is not " + ...
                "a valid cost term type for the current tool or " + ...
                "controllers." + newline + newline;
        else
            errorString = errorString + usedCostTypes(i) + " is not " + ...
                "a valid cost term type for the current tool or " + ...
                "controllers. Did you mean " + ...
                allowedCostTypes(costIndices(i)) + "?" + ...
                newline + newline;
        end
    end
end
for i = 1 : length(constraintCorrectionIndices)
    if constraintCorrectionIndices(i)
        if constraintIndices(i) == 1
            errorString = errorString + usedConstraintTypes(i) + ...
                " is not a valid constraint term type for the " + ...
                "current tool or controllers." + newline + newline;
        else
            errorString = errorString + usedConstraintTypes(i) + ...
                " is not a valid constraint term type for the " + ...
                "current tool or controllers. Did you mean " + ...
                allowedConstraintTypes(constraintIndices(i)) + "?" + ...
                newline + newline;
        end
    end
end
if any(costCorrectionIndices) || any(constraintCorrectionIndices)
    error(errorString)
end
end
