% This function is part of the NMSM Pipeline, see file for full license.
%
% This function finds the synergy weights from the design variables and
% arranges them in an array where the first index indicates the synergy
% group a set of weights belongs to. This is used in the bilateral symmetry
% cost term. 
%
% (Array of double, struct) -> (Array of double)
% Finds synergy weights from design variables array

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

function weights = findSynergyWeightsByGroup(values, inputs)
weights = zeros(length(inputs.synergyGroups), ...
    inputs.synergyGroups{1}.numSynergies, ...
    length(inputs.synergyGroups{1}.muscleNames));
valuesIndex = 1;
for i = 1:length(inputs.synergyGroups)
    weights(i, :, :) = ...
        reshape(values(valuesIndex : valuesIndex + ...
        length(inputs.synergyGroups{i}.muscleNames) * ...
        inputs.synergyGroups{i}.numSynergies - 1), size(weights, 2), []);
    valuesIndex = valuesIndex + ...
        length(inputs.synergyGroups{i}.muscleNames) * ...
        inputs.synergyGroups{i}.numSynergies;
end
end
