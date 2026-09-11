% This function is part of the NMSM Pipeline, see file for full license.
%
% Packs synergy weights and B-spline command nodes into a single flat
% design vector, the inverse of findSynergyWeightsAndCommands.m's
% unpacking.
%
% (Array of number, Array of number, struct) -> (Array of number)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
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

function values = repackDesignVariables(weights, commands, inputs)
% design variables size
length_weights   = sum(inputs.numWeightsPerGroup);
length_commands = inputs.numTrials*inputs.numNodes*inputs.numSynergies;
values = zeros(length_weights + length_commands, 1);

idx = 1;
row = 1;
idx_group = 1;

% weights
for i = 1:numel(inputs.synergyGroups)
    numMuscleOneLeg = length(inputs.synergyGroups{i}.muscleNames);
    for j = 1:inputs.synergyGroups{i}.numSynergies
        weight_list = weights(row, idx_group:idx_group+numMuscleOneLeg-1);
        values(idx:idx+numMuscleOneLeg-1) = weight_list(:);
        idx  = idx + numMuscleOneLeg;
        row  = row + 1;
    end
    idx_group = idx_group + numMuscleOneLeg;
end

% commands
for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        command_list = squeeze(commands(i,:,j));
        values(idx:idx+inputs.numNodes-1) = command_list(:);
        idx = idx + inputs.numNodes;
    end
end
end
