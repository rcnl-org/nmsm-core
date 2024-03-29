% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reformats synergy weights from a number array to a 2D
% matrix.
%
% (Array of number, struct) -> (2D matrix)
% Returns synergy weights as a 2D matrix

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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

function synergyWeightsReformatted = getSynergyWeightsFromGroups(...
    synergyWeights, inputs)
synergyWeightsReformatted = zeros(inputs.numSynergies, inputs.numMuscles);
valuesIndex = 1;
row = 1;
column = 1; % the sum of the muscles in the previous synergy groups
for i = 1:length(inputs.synergyGroups)
    for j = 1: inputs.synergyGroups{i}.numSynergies
        synergyWeightsReformatted(row, column : ...
            column + length(inputs.synergyGroups{i}.muscleNames) - 1) = ...
            synergyWeights(valuesIndex : ...
            valuesIndex + length(inputs.synergyGroups{i}.muscleNames) - 1);
        valuesIndex = valuesIndex + length(inputs.synergyGroups{i}.muscleNames);
        row = row + 1;
    end
    column = column + length(inputs.synergyGroups{i}.muscleNames);
end
end