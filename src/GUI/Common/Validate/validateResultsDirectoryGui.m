% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates a results directory path for use in the GUI.
% If empty, the warning is cleared and false is returned. If the directory
% already exists, a warning is shown that results will be overwritten. If
% the path is set and does not yet exist, it is considered valid with no
% icon shown.
%
% (string, UIComponent, UIComponent) -> (bool)
% Validates a results directory path and wires result to GUI components

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
function isValid = validateResultsDirectoryGui(resultsDir, fieldObj, warningIcon)
clearGuiError(fieldObj, warningIcon);
if strcmp(resultsDir, "")
    isValid = false;
    return
end
if exist(resultsDir, "dir")
    throwGuiWarning("Results directory already exists and will be overwritten.", ...
        fieldObj, warningIcon);
end
isValid = true;
end
