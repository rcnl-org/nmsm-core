% This function is part of the NMSM Pipeline, see file for full license.
%
% This function sets the validation status of a GUI input field using a
% single status icon. The icon's image, tooltip, and visibility, and the
% field's background color, are all set from the given status so a field
% always displays exactly one state: "error" (red highlight), "warning"
% (yellow highlight), "required" (asterisk, no highlight), or "none"
% (icon hidden, default background).
%
% (UIComponent, UIComponent, string, string) -> ()
% Sets a field's status icon and highlight for the given status

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
function setGuiFieldStatus(fieldObject, iconObject, status, message)
if nargin < 4
    message = "";
end
imageDir = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'Images');
defaultColor = get(groot, 'defaultUicontrolBackgroundColor');
switch string(status)
    case "error"
        iconFile = 'error.png';
        fieldColor = [1.00, 0.67, 0.67];
    case "warning"
        iconFile = 'warning.png';
        fieldColor = [1.00, 1.00, 0.67];
    case "required"
        iconFile = 'required.png';
        fieldColor = defaultColor;
    case "none"
        iconFile = '';
        fieldColor = defaultColor;
    otherwise
        error("setGuiFieldStatus:badStatus", ...
            "Unknown field status ""%s""", status);
end
if ~isempty(fieldObject)
    fieldObject.BackgroundColor = fieldColor;
end
if ~isempty(iconObject)
    if isempty(iconFile)
        iconObject.Visible = 'off';
    else
        iconObject.ImageSource = fullfile(imageDir, iconFile);
        iconObject.Tooltip = message;
        iconObject.Visible = 'on';
    end
end
end
