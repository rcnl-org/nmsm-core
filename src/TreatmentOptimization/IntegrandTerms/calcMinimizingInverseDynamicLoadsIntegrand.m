% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the experimental and
% predicted inverse dynamic moments for the specified coordinate.
%
% (struct, Array of number, 2D matrix, Array of string) -> (Array of number)
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

function cost = calcMinimizingInverseDynamicLoadsIntegrand(costTerm, ...
    inputs, time, inverseDynamicsMoments, loadName)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", true);
indx = find(strcmp(inputs.inverseDynamicsMomentLabels, loadName));
cost = calcTrackingCostArrayTerm(zeros(size(inverseDynamicsMoments)), ...
    inverseDynamicsMoments, indx);
if normalizeByFinalTime
    if all(size(time) == size(inputs.collocationTimeOriginal))
        cost = cost / time(end);
    else
        cost = cost / inputs.collocationTimeOriginal(end);
    end
end
end
