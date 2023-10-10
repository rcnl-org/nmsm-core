% This function is part of the NMSM Pipeline, see file for full license.
%
% This function tracks the difference between the predicted single spport
% phase and the error center for the specified foot. On average, single 
% support phase is around 0.37 to 0.39 of the gait cycle. 
%
% (struct, struct, struct, struct) -> (Array of number)

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

function cost = calcGoalSingleSupportTimeIntegrand(time, ...
    modeledValues, params, costTerm)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", false);
errorCenter = valueOrAlternate(costTerm, "error_center", 0.38);
for i = 1:length(params.contactSurfaces)
    if params.contactSurfaces{i}.isLeftFoot == costTerm.is_left_foot
        if i == 1
            singleSupportTime = calcSingleSupportTime( ...
                modeledValues.groundReactionsLab.forces{i + 1}(:, 2), ...
                time);
        else
            singleSupportTime = calcSingleSupportTime( ...
                modeledValues.groundReactionsLab.forces{i - 1}(:, 2), ...
                time);
        end
    end
end
percentSingleSupportTime = singleSupportTime / time(end);
cost = calcTrackingCostArrayTerm(percentSingleSupportTime * ...
    ones(length(time), 1), errorCenter * ...
    ones(length(time), 1), 1);
if normalizeByFinalTime
    cost = cost / time(end);
end
end