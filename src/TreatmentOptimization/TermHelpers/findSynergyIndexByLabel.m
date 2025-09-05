% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string, Array of string) -> 
% (Array of number, struct)
%
% Finds the index of a synergy name, saving an index for future calls.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function [indices, term] = findSynergyIndexByLabel(term, inputs, ...
    synergyNames)
if isfield(term, 'internalSynergyIndices')
    indices = term.internalSynergyIndices;
else
    indices = zeros(1, length(synergyNames));
    for name = 1 : length(synergyNames)
        synergyName = synergyNames(name);
        index = -1;
        nameParts = split(synergyName, "_");
        assert(length(nameParts) > 1 && ~isnan(str2double( ...
            nameParts(end))), "Synergy names are referenced in " + ...
            "terms as '<group name>_<index>', such as 'RightLeg_2'.");
        synergyGroupName = join(nameParts(1:end-1), "_");
        synergyNumber = str2double(nameParts(end));

        counter = 0;
        for i = 1 : length(inputs.synergyGroups)
            if strcmp(inputs.synergyGroups{i}.muscleGroupName, ...
                    synergyGroupName)
                index = counter + synergyNumber;
                indices(name) = index;
                break;
            end
            counter = counter + inputs.synergyGroups{i}.numSynergies;
        end

        assert(index > 0, "Unable to find synergy " + synergyName);
    end
    term.internalSynergyIndices = indices;
end
end
