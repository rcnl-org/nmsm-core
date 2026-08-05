% This function is part of the NMSM Pipeline, see file for full license.
%
% CasADi-safe equivalent of calcGroupedNormalizedFiberLengthCost.m,
% adapted for the 2-D activations2d layout
% [numTrials*numPoints x numMuscles] (muscle is a column here rather
% than the middle dimension of a 3-D array).
%
% (Array of number, struct) -> (Array of number)

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

function cost = calcCasadiGroupedNormalizedFiberLengthCost(activations2d, ...
    params)
cost = [];
for i = 1:length(params.normalizedFiberLengthGroups)
    groupIndex = params.normalizedFiberLengthGroups{i};
    if isempty(groupIndex)
        continue
    end
    groupActivations = activations2d(:, groupIndex);
    groupMean = sum(groupActivations, 2) / numel(groupIndex);
    groupMeanExpanded = repmat(groupMean, 1, numel(groupIndex));
    diffTerm = groupActivations - groupMeanExpanded;
    cost = [cost, reshape(diffTerm, 1, numel(diffTerm))];
end
end
