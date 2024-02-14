% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the experimental and
% predicted ground reaction moments for the specified moment.
%
% (struct, 2D matrix, Array of number, Array of string) -> (Array of number)
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function cost = calcTrackingExternalMomentsIntegrand(costTerm, inputs, ...
    groundReactionMoments, time, loadName)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", true);
for i = 1:length(inputs.contactSurfaces)
    indx = find(strcmp(convertCharsToStrings(inputs.contactSurfaces{i}. ...
        momentColumns), loadName));
    if ~isempty(indx)
        if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
        all(time == inputs.collocationTimeOriginal)
            experimentalGroundReactions = inputs.splinedGroundReactionMoments{i};
        else
            experimentalGroundReactions = ...
                evaluateGcvSplines( ...
                inputs.splineExperimentalGroundReactionMoments{i}, 0:2, ...
                time);
        end
        cost = calcTrackingCostArrayTerm(...
            experimentalGroundReactions, groundReactionMoments{i}, ...
            indx);
    end
end
if normalizeByFinalTime
    cost = cost / time(end);
end
end