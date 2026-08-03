% This function is part of the NMSM Pipeline, see file for full license.
%
% Copies the numeric settings named by a class's parameterNames constant
% out of a settings struct and onto the object. Shared by the Treatment
% Optimization controller and muscle model classes, which all expose the
% same parameterNames contract that updateParameterTableGui relies on.
% Values that do not parse as numbers are left at whatever the object
% already holds, so a malformed file cannot blank a setting.
%
% (handle, struct) -> (None)

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

function loadRcnlParametersFromStruct(object, settings)
for i = 1 : length(object.parameterNames)
    name = object.parameterNames(i);
    if ~isfield(settings, name)
        continue
    end
    number = toGuiNumber(settings.(name));
    if ~isnan(number)
        object.(name) = number;
    end
end
end
