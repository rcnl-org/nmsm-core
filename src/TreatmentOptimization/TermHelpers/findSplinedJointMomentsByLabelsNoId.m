% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string) -> (Array of number)
%
% Finds splined joint moments given labels, saving indices.

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

function [experimentalJointMoments, term] = ...
    findSplinedJointMomentsByLabelsNoId(term, inputs, time, ...
    momentLabels)
if isfield(term, 'internalExperimentalDataIndices')
    indices = term.internalExperimentalDataIndices;
else
    momentLabels = convertCharsToStrings(momentLabels);
    indices = zeros(1, length(momentLabels));
    for i = 1 : length(momentLabels)
        index = find(strcmp(convertCharsToStrings( ...
            inputs.inverseDynamicsMomentLabels), momentLabels(i)));
        assert(~isempty(index), momentLabels(i) + " is not an " + ...
            "inverse dynamics load label.")
        indices(i) = index;
    end
    term.internalExperimentalDataIndices = indices;
end
if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
        max(abs(time - inputs.collocationTimeOriginal)) < 1e-6
    experimentalJointMoments = inputs.splinedJointMoments(:, indices);
elseif all(size(time) == size(inputs.collocationTimeOriginalWithEnd)) &&...
        max(abs(time - inputs.collocationTimeOriginalWithEnd)) < 1e-6
    experimentalJointMoments = inputs.splinedJointMoments(:, indices);
    experimentalJointMoments(end+1, :) = ...
        inputs.experimentalJointMoments(end, indices);
elseif size(time) == [2, 1]
    experimentalJointMoments = inputs.experimentalJointMoments([1 end], ...
        indices);
else
    experimentalJointMoments = evaluateGcvSplines( ...
        inputs.splineJointMoments, indices - 1, time);
end
end
