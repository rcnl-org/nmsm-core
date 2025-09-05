% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, struct) -> (Array of number, struct)
%
% Finds the indices of included muscles given a synergy index.

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

function [indices, term] = findSynergyWeightIndicesByIndex(term, inputs)
if isfield(term, 'internalSynergyWeightIndices')
    indices = term.internalSynergyWeightIndices;
else
    synergyIndices = term.internalSynergyIndices;
    indices = cell(1, length(synergyIndices));
    for i = 1 : length(synergyIndices)
        synergyIndex = synergyIndices(i);
        startSynergyIndex = 0;
        startMuscleIndex = 1;
        for j = 1 : length(inputs.synergyGroups)
            synergyGroup = inputs.synergyGroups{j};
            if synergyIndex > startSynergyIndex + synergyGroup.numSynergies
                startSynergyIndex = startSynergyIndex + ...
                    synergyGroup.numSynergies;
                startMuscleIndex = startMuscleIndex + length(synergyGroup.muscleNames);
            else
                indices{i} = [startMuscleIndex, startMuscleIndex + ...
                    length(synergyGroup.muscleNames) - 1];
            end
        end
    end
    term.internalSynergyWeightIndices = indices;
end
end
