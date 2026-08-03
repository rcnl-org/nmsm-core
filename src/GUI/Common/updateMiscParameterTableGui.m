% This function is part of the NMSM Pipeline, see file for full license.
%
% This function fills a parameter GUI table from a struct of parameter
% names and values. Unlike updateParameterTableGui, which is driven by a
% fixed parameterNames constant on a settings object, this one is driven
% by the fields of the struct it is given, so the set of rows can differ
% from one selection to the next.
%
% Values are shown as text so that lists such as "x y z" survive being
% displayed and edited.
%
% (struct, Table) -> ()
% Fills a parameter GUI table from a struct of parameters

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
function updateMiscParameterTableGui(parameters, uiTable)
if isempty(parameters) || ~isstruct(parameters)
    parameters = struct();
end
options = string(fieldnames(parameters));
values = strings(length(options), 1);
for i = 1 : length(options)
    values(i) = formatParameterValue(parameters.(options(i)));
end
uiTable.Data = table(options, values);
end

function text = formatParameterValue(value)
if isnumeric(value) || islogical(value)
    text = strjoin(arrayfun(@formatGuiNumber, value(:)'), " ");
elseif ischar(value)
    text = string(value);
else
    text = strjoin(string(value(:)'), " ");
end
if isempty(text)
    text = "";
end
end
