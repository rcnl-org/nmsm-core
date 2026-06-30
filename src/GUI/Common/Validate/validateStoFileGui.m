% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates a .sto or .mot data file for use in the GUI. If
% the filepath is empty, the error state is cleared and false is returned.
% If non-empty, the file's existence and parseability are checked via the
% OpenSim Storage class. On failure, the field and icon are highlighted as
% an error with a descriptive tooltip.
%
% (.mot files are also accepted as they share the same format.)
%
% (string, UIComponent, UIComponent) -> (bool)
% Validates a .sto/.mot data file and wires result to GUI error components

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
function isValid = validateStoFileGui(filepath, fieldObj, iconObj)
import org.opensim.modeling.Storage
if strcmp(filepath, "")
    clearGuiError(fieldObj, iconObj);
    isValid = false;
    return
end
if ~exist(filepath, "file")
    throwGuiError("The given data file does not exist. " + ...
        "Check the file path and try again.", fieldObj, iconObj);
    isValid = false;
    return
end
try
    Storage(filepath);
catch
    throwGuiError("The data file could not be loaded. " + ...
        "Verify that it is a valid .sto or .mot file.", fieldObj, iconObj);
    isValid = false;
    return
end
clearGuiError(fieldObj, iconObj);
isValid = true;
end
