% This function is part of the NMSM Pipeline, see file for full license.
%
% Unpacks a flat NCP design vector into synergy weights and commands.
% Command nodes are extracted from the design vector per trial/synergy,
% then interpolated to full time points via the precomputed B-spline
% basis matrix (inputs.Bmatrix).
%
% (Array of number, struct) -> (Array of number, Array of number, Array of number)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function [weights, commands, commandNodes] = findSynergyWeightsAndCommands(values, inputs)
weights = zeros(inputs.numSynergies, inputs.numMuscles);
valuesIndex = 1;
row = 1;
column = 1; % the sum of the muscles in the previous synergy groups
for i = 1:length(inputs.synergyGroups)
    for j = 1: inputs.synergyGroups{i}.numSynergies
        weights(row, column : column + ...
            length(inputs.synergyGroups{i}.muscleNames) - 1) = ...
            values(valuesIndex : valuesIndex + ...
            length(inputs.synergyGroups{i}.muscleNames) - 1);
        valuesIndex = valuesIndex + length( ...
            inputs.synergyGroups{i}.muscleNames);
        row = row + 1;
    end
    column = column + length(inputs.synergyGroups{i}.muscleNames);
end
commandNodes = zeros(inputs.numTrials, inputs.numNodes, inputs.numSynergies);
for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        commandNodes(i, :, j) = values(valuesIndex : valuesIndex + ...
            inputs.numNodes - 1);
        valuesIndex = valuesIndex + inputs.numNodes;
    end
end
commandNodes2d = reshape(permute(commandNodes, [2 1 3]), inputs.numNodes, []);
commands2d  = inputs.Bmatrix * commandNodes2d;
commands = permute(reshape(commands2d, inputs.numPoints, inputs.numTrials, ...
    inputs.numSynergies), [2 1 3]);
end