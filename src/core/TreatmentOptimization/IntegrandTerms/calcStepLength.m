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

function stepLength = calcStepLength(normalForce, heelPosition, ...
    pelvisPosition)

normalForce = normalForce - 30;
normalForce(normalForce<0) = 0;
slope = diff(normalForce);

timePadding = round(length(slope) * 0.10);
heelStrikeEvent = [];
for i = 2 : length(slope) - timePadding
    if slope(i - 1) == 0 && all(slope(i : i + timePadding) > 0)
        heelStrikeEvent = i;
    end
end
if isempty(heelStrikeEvent)
    if normalForce(1) == 0
        heelStrikeEvent  = 1;
        stepLength = ...
            (heelPosition(heelStrikeEvent, 1) - pelvisPosition(heelStrikeEvent, :)) + ...
            (pelvisPosition(heelStrikeEvent, :) - heelPosition(heelStrikeEvent, 2));
    else
        stepLength = 0;
    end
else
    stepLength = ...
        (heelPosition(heelStrikeEvent, 1) - pelvisPosition(heelStrikeEvent, :)) + ...
        (pelvisPosition(heelStrikeEvent, :) - heelPosition(heelStrikeEvent, 2));
end
end