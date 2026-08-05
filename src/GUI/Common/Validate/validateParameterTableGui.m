% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates the parameters of a settings object (such as
% MuscleTendonLengthInitializationClass or SynergyExtrapolationClass)
% and reflects the result in its parameter table: invalid rows are
% highlighted and an error icon and tooltip describe the problems. The
% object must implement validateParameters() returning the indices of
% invalid parameters and a message for each.
%
% (settings object, Table, UIComponent) -> (logical)
% Validates a settings object's parameters and shows the result

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
function isValid = validateParameterTableGui(parameterObject, ...
    settingsTable, errorIcon)
removeStyle(settingsTable);
clearGuiError([], errorIcon);
settingsTable.Tooltip = '';
[invalidIndices, messages] = parameterObject.validateParameters();
isValid = isempty(invalidIndices);
if isValid
    return
end
for i = 1:length(invalidIndices)
    addStyle(settingsTable, ...
        uistyle('BackgroundColor', [1.00 0.67 0.67]), ...
        'row', invalidIndices(i));
end
errorMessage = strjoin(messages, newline);
settingsTable.Tooltip = errorMessage;
throwGuiError(errorMessage, [], errorIcon);
end
