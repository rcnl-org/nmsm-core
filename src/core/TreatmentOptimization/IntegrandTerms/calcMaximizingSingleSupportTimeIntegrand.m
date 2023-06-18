% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
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

function cost = calcMaximizingSingleSupportTimeIntegrand(values, ...
    modeledValues, params, costTerm)

for i = 1:length(params.contactSurfaces)
    if params.contactSurfaces{i}.isLeftFoot == costTerm.is_left_foot
        if i == 1
            singleSupportTime = calcSingleSupportTime( ...
                modeledValues.groundReactionsLab.forces{i + 1}(:, 2), values.time);
        else
            singleSupportTime = calcSingleSupportTime( ...
                modeledValues.groundReactionsLab.forces{i - 1}(:, 2), values.time);
        end
    end
end
cost = calcMaximizingCostArrayTerm(singleSupportTime * ...
    ones(length(values.time), 1));
end