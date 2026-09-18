% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates a tool's advanced (optimization) settings,
% which must all be positive numbers. Invalid rows are highlighted in
% the settings table and an error icon and tooltip describe the problem.
%
% (Table, Array of string, Array of double, UIComponent) -> (logical)
% Validates advanced settings values and shows the result in the GUI

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
function isValid = validateAdvancedSettingsGui(settingsTable, ...
    settingNames, settingValues, errorIcon)
removeStyle(settingsTable);
clearGuiError([], errorIcon);
settingsTable.Tooltip = '';
invalidRows = find(isnan(settingValues) | settingValues <= 0);
isValid = isempty(invalidRows);
if isValid
    return
end
messages = strings(length(invalidRows), 1);
for i = 1:length(invalidRows)
    addStyle(settingsTable, ...
        uistyle('BackgroundColor', [1.00 0.67 0.67]), ...
        'row', invalidRows(i));
    messages(i) = settingNames(invalidRows(i)) + ...
        ": must be a positive number";
end
errorMessage = strjoin(messages, newline);
settingsTable.Tooltip = errorMessage;
throwGuiError(errorMessage, [], errorIcon);
end
