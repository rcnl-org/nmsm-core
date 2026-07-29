% This function is part of the NMSM Pipeline, see file for full license.
%
% This function populates a two-column uitable ('Parameter'/'Value') from
% a paramObject's parameterNames and getParameterValueByIndex, formatting
% each value for display with formatGuiNumber.
%
% (Object with parameterNames + getParameterValueByIndex, Table) -> ()
% Populates a uitable's Data from a parameter object

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
function updateParameterTableGui(paramObject, uiTable)
options = paramObject.parameterNames;
values = strings(length(options), 1);
for i = 1 : length(options)
    values(i) = formatGuiNumber(paramObject.getParameterValueByIndex(i));
end
uiTable.Data = table(options, values);
end
