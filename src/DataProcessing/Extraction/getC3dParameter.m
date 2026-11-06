% This function is part of the NMSM Pipeline, see file for full license.
%
% Returns a parameter from the struct made by readC3dParameters, joining
% numbered continuations (e.g. LABELS, LABELS2, LABELS3) that c3d files use
% when a list is longer than 255 entries. Returns an empty array if the
% group or parameter does not exist.
%
% (struct, string, string) -> (Array of string or double)
% Returns a c3d parameter, or empty if missing

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

function value = getC3dParameter(parameters, groupName, parameterName)
value = [];
if ~isfield(parameters, groupName) || ...
        ~isfield(parameters.(groupName), parameterName)
    return
end
group = parameters.(groupName);
value = group.(parameterName);
continuation = 2;
while isfield(group, parameterName + continuation)
    value = [value(:); group.(parameterName + continuation)(:)];
    continuation = continuation + 1;
end
if isstring(value)
    value = value(:)';
end
end
