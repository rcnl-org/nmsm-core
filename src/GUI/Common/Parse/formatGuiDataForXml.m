% This function is part of the NMSM Pipeline, see file for full license.
%
% This function recursively converts GUI data types (MATLAB strings, string
% arrays) into the character and space-joined text format expected by
% struct2xml for writing XML settings files.
%
% (string | struct | cell) -> (char | struct | cell)
% Converts GUI data types to XML-compatible types recursively

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
function struct = formatGuiDataForXml(struct)
    if isstring(struct)
        struct = convertStringsToChars(strjoin( ...
            struct, " "));
        return
    end

    
    if isstruct(struct)
        structFields = fields(struct);
        for i = 1 : numel(structFields)
            struct.(structFields{i}) = formatGuiDataForXml(struct.(structFields{i}));
        end
    end

    if iscell(struct)
        for i = 1 : length(struct)
            struct{i} = formatGuiDataForXml(struct{i});
        end
    end
end