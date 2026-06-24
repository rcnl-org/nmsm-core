% This function is part of the NMSM Pipeline, see file for full license.
%
% This function displays a GUI warning state by highlighting a field
% component in yellow and showing an associated warning icon with a tooltip
% containing the warning message.
%
% (string, UIComponent, UIComponent) -> ()
% Highlights a GUI field in yellow and shows a warning icon with a tooltip

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
function throwGuiWarning(message, fieldObject, iconObject)
    if ~isempty(fieldObject)
        fieldObject.BackgroundColor = [1.00,1.00,0.67];
    end
    if ~isempty(iconObject)
        iconObject.Visible = 'on';
        iconObject.Tooltip = message;
    end
end