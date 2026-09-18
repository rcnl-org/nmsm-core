% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates an optional .osimx file for use in the GUI. If
% the filepath is empty, the error state is cleared and false is returned.
% On parse failure a warning (not error) is shown since the .osimx file is
% optional in all current tools.
%
% (App, string, string, UIComponent, UIComponent) -> (bool)
% Validates an .osimx file and wires result to GUI warning component

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
function isValid = validateOsimxFileGui(app, osimxPath, modelPath, fieldObj, iconObj)
if strcmp(osimxPath, "")
    clearGuiError(fieldObj, iconObj);
    isValid = false;
    return
end
[errorFlag, message] = parseOsimxFileGui(app, osimxPath, modelPath);
if errorFlag
    throwGuiWarning(message, fieldObj, iconObj);
    isValid = false;
else
    clearGuiError(fieldObj, iconObj);
    isValid = true;
end
end
