% This function is part of the NMSM Pipeline, see file for full license.
%
% This function validates a Muscle-Tendon Length Initialization
% configuration for the GUI. When MTLI is disabled all indicators are
% cleared; when enabled, the passive data directory is required and must
% exist.
%
% (MuscleTendonLengthInitializationClass, UIComponent, UIComponent,
% UIComponent) -> (logical)
% Validates the MTLI configuration and shows the result in the GUI

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
function isValid = validateMtliConfigGui(mtli, fieldObject, errorIcon, ...
    requiredIcon)
if ~strcmp(mtli.is_enabled, 'true')
    clearGuiError(fieldObject, errorIcon);
    clearGuiError([], requiredIcon);
    isValid = true;
    return
end
isValid = validateRequiredFieldGui( ...
    mtli.passive_data_input_directory, ...
    "Passive data directory is required when MTLI is enabled.", ...
    fieldObject, errorIcon, requiredIcon, @validateFileExistsGui);
end
