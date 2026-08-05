% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates a list of cost terms and reflects the result in
% the GUI: invalid rows are highlighted in the cost terms table, the max
% allowable error field is highlighted when its selected term is invalid,
% and an error icon is shown describing the problem. The description
% names the kind of cost term in messages (e.g. "cost term" or "MTLI
% cost term"). The max allowable error field and error icon may be empty.
%
% (Cell Array of RCNLCostTermClass, Table, NumericEditField,
% UIComponent, string) -> (logical)
% Validates cost terms and shows the result in the GUI

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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
function isValid = validateCostTermsGui(costTerms, costTermsTable, ...
    maxAllowableErrorField, errorIcon, description)
removeStyle(costTermsTable);
clearGuiError([], errorIcon);
if ~isempty(maxAllowableErrorField)
    maxAllowableErrorField.BackgroundColor = [1 1 1];
end
[hasEnabledTerm, invalidIndices] = checkCostTermsValid(costTerms);
isValid = hasEnabledTerm && isempty(invalidIndices);
for i = invalidIndices
    addStyle(costTermsTable, ...
        uistyle('BackgroundColor', [1.00 0.67 0.67]), 'row', i);
    if ~isempty(maxAllowableErrorField) && ...
            isscalar(costTermsTable.Selection) && ...
            costTermsTable.Selection == i
        maxAllowableErrorField.BackgroundColor = [1.00 0.67 0.67];
    end
end
if ~hasEnabledTerm
    throwGuiError("At least one " + description + " must be enabled.", ...
        [], errorIcon);
elseif ~isempty(invalidIndices)
    throwGuiError("Max allowable error must be greater than zero for " + ...
        "each enabled " + description + ".", [], errorIcon);
end
end
