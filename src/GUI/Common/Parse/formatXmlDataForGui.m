% This function is part of the NMSM Pipeline, see file for full license.
%
% This function recursively converts the output of xml2struct (chars and
% Text-wrapped structs) into GUI-friendly MATLAB types (strings, numeric
% values, and string arrays split on spaces).
%
% (char | struct | cell) -> (string | number | struct | cell)
% Converts XML struct data types to GUI-friendly types recursively

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
function tree = formatXmlDataForGui(tree)
    if ischar(tree) 
        tree = convertCharsToStrings(strsplit( ...
            tree, " "));
        if ~isnan(str2double(tree))
            tree = str2double(tree);
        end
        return
    end
    
    if isstruct(tree) 
        structFields = fields(tree);
        if length(structFields) == 1 && strcmp(structFields, "Text")
                tree = formatXmlDataForGui(tree.(structFields{1}));
        else
            for i = 1 : numel(structFields)
                if strcmp(structFields{i}, "Attributes")
                    return
                end
                tree.(structFields{i}) = formatXmlDataForGui(tree.(structFields{i}));
            end
        end
    end

    if iscell(tree)
        for i = 1 : length(tree)
            tree{i} = formatXmlDataForGui(tree{i});
        end
    end
end