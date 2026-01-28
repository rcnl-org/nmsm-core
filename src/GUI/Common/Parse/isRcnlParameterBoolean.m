% This function is part of the NMSM Pipeline, see file for full license.
%
% Reports whether the parameter at an index is stored as the text 'true' or
% 'false' rather than as a number. A class opts a parameter in by listing it
% in a booleanParameterNames constant; a class without that property is all
% numeric, so nothing else has to change.
%
% The backend compares these settings as text -- getBooleanLogicFromField is
% strcmp(field.Text, 'true') and parseMuscleSettings uses strcmpi(text,
% "true") -- so a numeric 1 would be read as false.
%
% (handle, integer) -> (boolean)

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

function isBoolean = isRcnlParameterBoolean(object, index)
isBoolean = false;
if ~isprop(object, 'booleanParameterNames')
    return
end
isBoolean = any(strcmp(object.booleanParameterNames, ...
    object.parameterNames(index)));
end
