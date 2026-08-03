% This function is part of the NMSM Pipeline, see file for full license.
%
% Normalizes a single value read from an XML settings file into the scalar
% string the GUI holds paths and names in. formatXmlDataForGui splits every
% element on spaces and converts numeric looking text to doubles, so a name
% can arrive as a one element string array, a char row, or a number.
%
% (any) -> (string)

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

function text = toGuiText(value)
values = toGuiStringList(value);
if isempty(values)
    text = "";
    return
end
% A path split on spaces is rejoined, since the split was not meaningful
text = strjoin(values, " ");
end
