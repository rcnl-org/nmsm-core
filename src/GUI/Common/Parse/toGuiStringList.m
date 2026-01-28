% This function is part of the NMSM Pipeline, see file for full license.
%
% Normalizes a value read from an XML settings file into the string array
% the GUI holds lists in. formatXmlDataForGui already splits most elements,
% but it converts numeric looking text to doubles and returns early on any
% struct carrying an Attributes field, so a list can arrive as a string
% array, a char row, or a number.
%
% (any) -> (Array of string)

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

function values = toGuiStringList(value)
if isstruct(value)
    if isfield(value, 'Text')
        value = value.Text;
    else
        values = string([]);
        return
    end
end
if ischar(value)
    values = string(strsplit(value, " "));
elseif isstring(value)
    values = value(:)';
else
    values = string(value(:)');
end
values = values(~strcmp(values, ""));
end
