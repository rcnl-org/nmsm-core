% This function is part of the NMSM Pipeline, see file for full license.
%
% CasADi-safe (2-D only) equivalent of calcActivationsFromSynergyDesignVariables.m
% / findSynergyWeightsAndCommands.m combined. CasADi MX/SX types do not
% support N-D arrays, so this avoids the 3-D commandNodes/commands/
% activations reshapes used by the production versions.
%
% Returns weights [numSynergies x numMuscles] and activations2d
% [numTrials*numPoints x numMuscles], where activations2d's rows are
% grouped by trial (all numPoints rows for trial 1, then trial 2, ...).
%
% (Array of number, struct) -> (Array of number, Array of number)

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

function [activations2d, weights] = ...
    calcCasadiActivationsFromSynergyDesignVariables(values, inputs)
valuesIndex = 1;

% weights: [numSynergies x numMuscles], block-diagonal by synergy group
weightBlocks = cell(1, length(inputs.synergyGroups));
for i = 1:length(inputs.synergyGroups)
    numMuscleGroup = length(inputs.synergyGroups{i}.muscleNames);
    rows = [];
    for j = 1:inputs.synergyGroups{i}.numSynergies
        rows = [rows; values(valuesIndex : ...
            valuesIndex + numMuscleGroup - 1).'];
        valuesIndex = valuesIndex + numMuscleGroup;
    end
    weightBlocks{i} = rows;
end
weights = [];
muscleColumnOffset = 0;
for i = 1:length(inputs.synergyGroups)
    numSynGroup = inputs.synergyGroups{i}.numSynergies;
    numMuscleGroup = size(weightBlocks{i}, 2);
    leftZeros = zeros(numSynGroup, muscleColumnOffset);
    rightZeros = zeros(numSynGroup, ...
        inputs.numMuscles - muscleColumnOffset - numMuscleGroup);
    weights = [weights; leftZeros, weightBlocks{i}, rightZeros];
    muscleColumnOffset = muscleColumnOffset + numMuscleGroup;
end

% commandNodes2d: [numNodes x (numTrials*numSynergies)], column order:
% trial i, synergy j -> column (i-1)*numSynergies + j
commandNodeCols = cell(1, inputs.numTrials * inputs.numSynergies);
col = 1;
for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        commandNodeCols{col} = values(valuesIndex : ...
            valuesIndex + inputs.numNodes - 1);
        valuesIndex = valuesIndex + inputs.numNodes;
        col = col + 1;
    end
end
commandNodes2d = [commandNodeCols{:}];
commands2d = inputs.Bmatrix * commandNodes2d; % [numPoints x numTrials*numSynergies]

% activations2d: [numTrials*numPoints x numMuscles]
activationsBlocks = cell(1, inputs.numTrials);
for i = 1:inputs.numTrials
    columns = (i - 1) * inputs.numSynergies + 1 : i * inputs.numSynergies;
    activationsBlocks{i} = commands2d(:, columns) * weights;
end
activations2d = vertcat(activationsBlocks{:});
end
