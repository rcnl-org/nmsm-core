% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the belt speed and the
% error center for the specified foot. 
%
% (struct, struct, struct) -> (Array of number)
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

function cost = calcGoalBeltSpeedDiscrete(values, params, costTerm)

errorCenter = valueOrAlternate(costTerm, "errorCenter", 1);
counter = 1;
for i = 1:length(params.userDefinedVariables)
    if strcmp(params.userDefinedVariables{i}.type, 'belt_speed')
        if params.userDefinedVariables{i}.is_left_foot == ...
                costTerm.is_left_foot
            beltSpeed = values.belt_speed(counter);
        end
        counter = counter + 1;
    end
end
cost = calcTrackingCostArrayTerm(beltSpeed, errorCenter , 1);
end